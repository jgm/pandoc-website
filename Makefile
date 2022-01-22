SITE = site
DEMO = $(SITE)/demo
CSS = $(patsubst %,css/%, print.css  screen.css)
JS = js/downloadInstallerBtn.js js/collapseTOC.js js/index.js js/dropdown.js
TIME := $(shell date +"%Y%m%d%H%M%S")
ALL = $(patsubst %,$(SITE)/%,index.html installing.html extras.html MANUAL.html MANUAL.pdf CONTRIBUTING.html demos.html releases.html changelog.md filters.html lua-filters.html custom-writers.html custom-readers.html jats.html org.html using-the-pandoc-api.html help.html epub.html faqs.html diagram.svg getting-started.html press.html .htaccess css js $(CSS) $(JS))
PANDOC_SRC ?= ${HOME}/src/pandoc
PANDOC = pandoc
MKPAGE = $(PANDOC) --toc --standalone \
	--to=html5 \
	--section-divs \
	--highlight-style=tango \
	--template=template.html \
	--lua-filter=tools/option-anchors.lua \
	--lua-filter=tools/faq-panels.lua \
	--lua-filter=tools/nowrap.lua \
	--lua-filter=tools/extension-support.lua \
	--lua-filter=tools/anchor-links.lua \
	--lua-filter=tools/include-code-files.lua \
	--variable time=${TIME}
VERSION = $(shell pandoc --version | head -1 | awk '{print $$2}')

.PHONY: all
all : $(SITE) $(ALL) $(SITE)/js/index.js

.PHONY: css
css : $(patsubst %,$(SITE)/%,css $(CSS))

$(SITE):
	mkdir -p $@

$(SITE)/js:
	mkdir -p $@

$(SITE)/css:
	mkdir -p $@

$(SITE)/js/index.js: tools/build-index.js js/search.js
	node tools/build-index.js > $@

$(SITE)/% : %
	cp $< $@

.PHONY: clean
clean:
	-rm -rf $(SITE)
	-rm extension-support.txt

DEMOFILES = $(patsubst %, $(DEMO)/%, MANUAL.txt code.text math.text math.tex template.tex pandoc.1.md footer.html haskell.wiki SLIDES pandoc.css chicago-author-date.csl ieee.csl chicago-fullnote-bibliography.csl biblio.bib CITATIONS howto.xml sample.lua creole.lua example15.md example15.png example33.text twocolumns.docx biblio.json biblio.yaml fishtable.rst species.rst fishwatch.yaml)

$(DEMO)/% : %
	mkdir -p $(DEMO)
	cp $< $@

$(SITE)/demos.txt : demos $(DEMOFILES) mkdemos.pl
	perl mkdemos.pl $< $@ $(DEMO)

$(DEMO)/biblio.json: $(DEMO)/biblio.bib
	pandoc -f biblatex -t csljson -s $< > $@

$(DEMO)/biblio.yaml: $(DEMO)/biblio.bib
	pandoc -f biblatex -t markdown -s $< > $@

$(SITE)/installing.txt : INSTALL.md
	sed -e '1s/#/%/' $< > $@

$(SITE)/CONTRIBUTING.txt : CONTRIBUTING.md
	cp $< $@

$(SITE)/diagram.dot : changelog.md
	sh tools/make-diagram.sh > $@

$(SITE)/diagram.jpg : $(SITE)/diagram.png
	convert -quality 70% $< $@

$(SITE)/diagram.png : $(SITE)/diagram.dot
	dot -Tpng -o$@ $<

$(SITE)/diagram.svg : $(SITE)/diagram.dot
	dot -Tsvg -o$@ $<


# 'make update' pulls in source files from the pandoc source directory
SOURCES = $(patsubst %, $(PANDOC_SRC)/%, changelog.md MANUAL.txt INSTALL.md CONTRIBUTING.md doc/filters.md doc/org.md doc/faqs.md doc/custom-readers.md doc/custom-writers.md doc/lua-filters.md doc/jats.md doc/using-the-pandoc-api.md doc/getting-started.md doc/epub.md) $(PANDOC_SRC)/man/pandoc.1 $(PANDOC_SRC)/data/sample.lua $(PANDOC_SRC)/data/creole.lua

update :
	cp $(SOURCES) .

$(SITE)/releases.html : release-preamble.md changelog.md
	$(MKPAGE) $^ -o $@ --metadata title=Releases --lua-filter=tools/linkify-issues-in-changelog.lua

%.1.html : %.1
	groff -Txhtml -mandoc $< > $@

%.5.html : %.5
	groff -Txhtml -mandoc $< > $@

$(SITE)/installing.html : $(SITE)/installing.txt template.html
	$(MKPAGE) $< -o $@ -V installbtn

%.html : %.txt template.html sample.lua extension-support.txt
	$(MKPAGE) $< -o $@

%.html : %.md template.html
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

extension-support.txt:
	sh tools/list-extension-support.sh > $@

upload :
	rsync -avz --delete --copy-links -e "ssh" $(SITE)/* $(SITE)/.htaccess website:pandoc.org/
