#!/usr/bin/perl
#
# garble.pl - reads plain text on standard input and puts out garbled
#             English text on standard output.
#

while ($line = <>) {
   @words = split(" ",$line);
   for $word (@words) {
      $word =~ tr/A-Z/B-ZA/;
      $word =~ tr/a-z/b-za/;
   }
   print join(" ",@words),"\n";
}
