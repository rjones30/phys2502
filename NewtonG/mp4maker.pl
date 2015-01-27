# 
# mp4maker.pl - script to automate stringing together a set of images
# 		to form a movie.
#
# author: richard.t.jones at uconn.edu
# version: April 8, 2011
#

use Cwd;
use Time::Local;

sub usage
{
   print "Usage: mp4maker.pl <input_file_pattern> <output_file>\n",
         "  where <input_file_pattern> has # in place of image numbers.\n";
   exit(0);
}

if (@ARGV != 2) {
   usage();
}


our $cwd = getcwd();
our $inputfiles = $ARGV[0];
our $outputfile = $ARGV[1];
our $workdir = $inputfiles;
$workdir =~ s/\\[^\\]+//;
chdir $workdir;
our $tempdir = "work_$$";
mkdir $tempdir;

$inputfiles =~ s/.*\\//;
our $filepat = $inputfiles;
our $ext = $filepat;
$ext =~ s/.*\.//;
$filepat =~ s/#/*/;
open(FLIST,"dir \"$filepat\" |") || die;
our @images;
our $images = 0;
our @datetime;
our @tseconds;
while (<FLIST>) {
   if (/^[0-9]/) {
      my ($date,$time,$ampm,$size,@name) = split(" ",$_);
      my $filename = join(" ",@name);
      $images[++$images] = $filename;
      open(INFO,"identify -verbose $filename|") || die;
      while (<INFO>) {
         if (/exif:DateTimeOriginal: (.+)/) {
            $datetime[$images] = $1;
            my ($yr,$mo,$da,$hr,$mi,$se) = split(/[: ]/,$1);
	    print "$se,$mi,$hr,$da,$mo,$yr\n";
	    $tseconds[$images] = timelocal($se,$mi,$hr,$da,$mo,$yr);
	    last;
	 }
      }
      close(INFO);
      if ($images > 1) {
         print "$filename $datetime[$images]",
	       " interval ",$tseconds[$images]-$tseconds[$images-1]," s,",
	       " average ",($tseconds[$images]-$tseconds[1])/($images-1),
	       " s\n";
      }
      else {
         print "$filename $datetime[$images]\n";
      }
      rename("$images[$images]","$tempdir\\img$images.$ext");
   }
}
close(FLIST);

if ($images > 0) {
   chdir $tempdir;
   system("ffmpeg -f image2 -i img%d.$ext $outputfile");
   rename($outputfile,"$cwd/$outputfile");
   chdir "..";
}

for (my $image=1; $image<=$images; ++$image) {
   my $filename = $images[$image];
   rename("$tempdir\\img$image.$ext","$filename");
}
rmdir $tempdir;
