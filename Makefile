SITE = site
DEMO = $(SITE)/demo
CSS = $(patsubst %,css/%, print.css  screen.css)
JS = js/downloadInstallerBtn.js js/collapseTOC.js
ALL = $(patsubst %,$(SITE)/%,index.html installing.html MANUAL.html MANUAL.pdf CONTRIBUTING.html demos.html releases.html changelog.txt filters.html lua-filters.html org.html using-the-pandoc-api.html help.html epub.html faqs.html diagram.jpg getting-started.html donate.html press.html .htaccess css js $(CSS) $(JS))
PANDOC_SRC ?= ${HOME}/src/pandoc
PANDOC = pandoc
MKPAGE = $(PANDOC) -t html5 --toc -s --highlight-style tango -B nav.html --template=template.html --lua-filter tools/option-anchors.lua --lua-filter tools/faq-panels.lua --lua-filter tools/nowrap.lua
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

DEMOFILES = $(patsubst %, $(DEMO)/%, MANUAL.txt code.text math.text math.tex template.tex pandoc.1.md footer.html haskell.wiki SLIDES pandoc.css chicago-author-date.csl ieee.csl chicago-fullnote-bibliography.csl biblio.bib CITATIONS howto.xml sample.lua example15.md example15.png example33.text twocolumns.docx biblio.json biblio.yaml)

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
	stack runghc --stack-yaml=$$HOME/src/pandoc/stack.yaml --package pandoc -- make-diagram.hs > $@ || rm $@

$(SITE)/diagram.jpg : $(SITE)/diagram.png
	convert -quality 70% $< $@

$(SITE)/diagram.png : $(SITE)/diagram.dot
	dot -Tpng -o$@ $<


# 'make update' pulls in source files from the pandoc source directory
SOURCES = $(patsubst %, $(PANDOC_SRC)/%, changelog MANUAL.txt INSTALL.md CONTRIBUTING.md doc/filters.md doc/org.md doc/lua-filters.md doc/using-the-pandoc-api.md doc/getting-started.md doc/epub.md) $(PANDOC_SRC)/man/pandoc.1 $(PANDOC_SRC)/data/sample.lua

update :
	cp $(SOURCES) . ; \
         tmpfile=$$(mktemp /tmp/newreleases.XXXXXX) ; \
         (perl -pe 'if (/^#/) {exit};' releases.txt ; \
          perl -pe 'use POSIX; my $$date=strftime("%e %B %Y", localtime); if (/^p/){ $$x++ }  ; if ($$x == 2){ exit }; s/^pandoc \(([^)]*)\)/# pandoc \1 ($$date)/;' changelog ; \
          perl -ne 'if (/^# pandoc ([0-9.]*)/) {if ($$1 ne "$(VERSION)") {$$x=1}}; print if $$x;' releases.txt \
         ) > $$tmpfile ; \
         cp $$tmpfile releases.txt

%.1.html : %.1
	groff -Txhtml -mandoc $< > $@

%.5.html : %.5
	groff -Txhtml -mandoc $< > $@

$(SITE)/installing.html : $(SITE)/installing.txt template.html
	$(MKPAGE) $< -o $@ -V installbtn

%.html : %.txt nav.html template.html
	$(MKPAGE) $< -o $@

%.html : %.md nav.html template.html
	$(MKPAGE) $< -o $@

$(SITE)/MANUAL.pdf : MANUAL.txt template.tex
	$(PANDOC) $< -o $@ --toc -s --template template.tex \
		--variable mainfont="Georgia" --variable sansfont="Arial" \
		--variable monofont="Menlo" \
		--variable fontsize=11pt --variable version="$(VERSION)" \
		--variable geometry='margin=1.2in' \
		--pdf-engine=xelatex

upload :
	rsync -avz --delete --copy-links -e "ssh"  --exclude 'demo/reveal.js/.git' $(SITE)/* $(SITE)/.htaccess website:pandoc.org/
