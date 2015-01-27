all: example.pdf example.zip

%.pdf: %.ps
	ps2pdf $^ $@

%.gz: %
	gzip $^

%.ps: %.dvi
	dvips -Ppdf -o $@ $^

%.dvi: %.tex
	latex $^
	latex $^

%.tar: %.tex $(wildcard %.eps)
	tar -zcf $@ $^

example.zip: example.pdf example.tex examplefig.eps linearfit.eps
	zip $@ $^

