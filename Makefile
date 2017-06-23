SITE = site
DEMO = $(SITE)/demo
CSS = $(patsubst %,css/%, print.css  screen.css)
JS = js/nav.js
ALL = $(patsubst %,$(SITE)/%,index.html installing.html MANUAL.html MANUAL.pdf CONTRIBUTING.html demos.html releases.html changelog.txt scripting.html scripting-1.11.html scripting-1.12.html help.html epub.html faqs.html diagram.jpg getting-started.html donate.html press.html css js $(CSS) $(JS))
PANDOC_SRC ?= ${HOME}/src/pandoc
PANDOC = pandoc
MKPAGE = $(PANDOC) -t html5 --toc -s -B nav.html --template=template.html
VERSION = $(shell pandoc --version | head -1 | awk '{print $$2}')

.PHONY: all
all : $(SITE) $(ALL)

$(SITE):
	mkdir $@

$(SITE)/js:
	mkdir -p $@

$(SITE)/css:
	mkdir -p $@

$(SITE)/% : %
	cp $< $@

.PHONY: clean
clean:
	rm -rf $(SITE)

DEMOFILES = $(patsubst %, $(DEMO)/%, MANUAL.txt code.text math.text math.tex mytemplate.tex pandoc.1.md footer.html haskell.wiki SLIDES pandoc.css chicago-author-date.csl ieee.csl chicago-fullnote-bibliography.csl biblio.bib CITATIONS howto.xml sample.lua example33.text twocolumns.docx biblio.json biblio.yaml)

$(DEMO)/% : %
	cp $< $@

$(SITE)/demos.txt : demos $(DEMO) $(DEMO)/reveal.js $(DEMOFILES) mkdemos.pl
	perl mkdemos.pl $< $@ $(DEMO)

$(DEMO)/biblio.json: $(DEMO)/biblio.bib
	pandoc-citeproc --bib2json $< > $@

$(DEMO)/biblio.yaml: $(DEMO)/biblio.bib
	pandoc-citeproc --bib2yaml $< > $@

$(DEMO)/reveal.js:
	git clone https://github.com/hakimel/reveal.js $@

$(DEMO):
	mkdir $(DEMO)

$(SITE)/installing.txt : INSTALL.md
	sed -e '1s/#/%/' $< > $@

$(SITE)/CONTRIBUTING.txt : CONTRIBUTING.md
	cp $< $@

$(SITE)/changelog.txt : changelog
	cp $< $@

$(SITE)/diagram.dot :
	runghc make-diagram.hs > $@ || rm $@

$(SITE)/diagram.jpg : $(SITE)/diagram.png
	convert -quality 70% $< $@

$(SITE)/diagram.png : $(SITE)/diagram.dot
	dot -Tpng -o$@ $<

$(SITE)/% : %
	cp $< $@

# 'make update' pulls in source files from the pandoc source directory
SOURCES = $(patsubst %, $(PANDOC_SRC)/%, changelog MANUAL.txt INSTALL.md CONTRIBUTING.md) \
          $(PANDOC_SRC)/man/pandoc.1

update :
	cp -r $(SOURCES) .

%.1.html : %.1
	groff -Txhtml -mandoc $< > $@

%.5.html : %.5
	groff -Txhtml -mandoc $< > $@

%.html : %.txt nav.html template.html
	$(MKPAGE) $< -o $@

$(SITE)/MANUAL.pdf : MANUAL.txt template.tex
	$(PANDOC) $< -o $@ --toc -s --template template.tex \
		--variable mainfont="Georgia" --variable sansfont="Arial" \
		--variable monofont="Menlo" \
		--variable fontsize=11pt --variable version="$(VERSION)" \
		--variable geometry='margin=1.2in' \
		--latex-engine=xelatex

upload :
	rsync -avz --delete --copy-links -e "ssh"  --exclude 'demo/reveal.js/.git' $(SITE)/* website:pandoc.org/
