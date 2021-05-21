SITE = site
DEMO = $(SITE)/demo
CSS = $(patsubst %,css/%, print.css  screen.css)
JS = js/downloadInstallerBtn.js js/collapseTOC.js
ALL = $(patsubst %,$(SITE)/%,index.html installing.html extras.html MANUAL.html MANUAL.pdf CONTRIBUTING.html demos.html releases.html changelog.md filters.html lua-filters.html jats.html org.html using-the-pandoc-api.html help.html epub.html faqs.html diagram.jpg getting-started.html donate.html press.html .htaccess css js $(CSS) $(JS))
PANDOC_SRC ?= ${HOME}/src/pandoc
PANDOC = pandoc
MKPAGE = $(PANDOC) --toc --standalone \
	--to=html5 \
	--highlight-style=tango \
	--include-before=nav.html \
	--template=template.html \
	--lua-filter=tools/option-anchors.lua \
	--lua-filter=tools/faq-panels.lua \
	--lua-filter=tools/nowrap.lua \
	--lua-filter=tools/anchor-links.lua
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

DEMOFILES = $(patsubst %, $(DEMO)/%, MANUAL.txt code.text math.text math.tex template.tex pandoc.1.md footer.html haskell.wiki SLIDES pandoc.css chicago-author-date.csl ieee.csl chicago-fullnote-bibliography.csl biblio.bib CITATIONS howto.xml sample.lua example15.md example15.png example33.text twocolumns.docx biblio.json biblio.yaml fishtable.rst species.rst fishwatch.yaml)

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


$(SITE)/diagram.dot :
	stack runghc --stack-yaml=$$HOME/src/pandoc/stack.yaml --package pandoc --package text -- make-diagram.hs > $@ || rm $@

$(SITE)/diagram.jpg : $(SITE)/diagram.png
	convert -quality 70% $< $@

$(SITE)/diagram.png : $(SITE)/diagram.dot
	dot -Tpng -o$@ $<


# 'make update' pulls in source files from the pandoc source directory
SOURCES = $(patsubst %, $(PANDOC_SRC)/%, changelog.md MANUAL.txt INSTALL.md CONTRIBUTING.md doc/filters.md doc/org.md doc/lua-filters.md doc/jats.md doc/using-the-pandoc-api.md doc/getting-started.md doc/epub.md) $(PANDOC_SRC)/man/pandoc.1 $(PANDOC_SRC)/data/sample.lua

update :
	cp $(SOURCES) .

$(SITE)/releases.html : release-preamble.md changelog.md
	$(MKPAGE) $^ -o $@ --metadata title=Releases

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
	$(PANDOC) $< -o $@ --toc -s \
	        --variable papersize=letter \
		--variable geometry='total={6in,9in}' \
	        --variable documentclass=scrbook \
		--variable mainfont="Palatino" \
		--variable sansfont="Arial" \
		--variable monofont="Menlo" \
		--variable fontsize=11pt \
		--variable linestretch=1.1 \
		--variable version="$(VERSION)" \
		--pdf-engine=xelatex

upload :
	rsync -avz --delete --copy-links -e "ssh"  --exclude 'demo/reveal.js/.git' $(SITE)/* $(SITE)/.htaccess website:pandoc.org/
