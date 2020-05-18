---
title: Pandoc Extras
author: John MacFarlane
---

This is a curated list of some of the most useful third-party
software that extends pandoc's capabilities.  For a more
complete list, see the [Pandoc Extras wiki page]( https://github.com/jgm/pandoc/wiki/Pandoc-Extras).


- GUI
  - [PanWriter](https://github.com/mb21/panwriter/#panwriter) is
    a Markdown editor with live preview that can import and export
    using pandoc.
  - [Pandoc Mac OS X
    Services](https://github.com/mb21/Pandoc-Mac-OS-X-Services)
    allows you to invoke pandoc from any text editor with the
    opened file as input.

- Editor support
  - [pandoc-mode](http://joostkremers.github.com/pandoc-mode/) for Emacs
  - [vim-pandoc](https://github.com/vim-pandoc) for Vim

- CLI wrappers
  - [panzer](https://github.com/msprev/panzer) allows you to
    specify command-line options and styles in the Markdown file's YAML
    metadata.
  - [pandocomatic](https://heerdebeer.org/Software/markdown/pandocomatic/)
    is similar to panzer but also provides support for
    converting directory trees.
  - [panrun](https://github.com/mb21/panrun) is a more
    minimalistic alternative to panzer and pandocomatic.

- Editing/document changes
  - [pandiff](https://github.com/davidar/pandiff) creates prose
    diffs for any document format supported by pandoc.
  - [pancritic](https://github.com/ickc/pancritic) allows using
    [CriticMarkup](http://criticmarkup.com/spec.php#caveats) with pandoc.

- Data science
  - [R Markdown](https://rmarkdown.rstudio.com) allows you to
    process Markdown documents with integrated data and charts
    (integrates pandoc).

- Citations and cross-references
  - [zotxt](https://github.com/egh/zotxt) is Zotero extension
    for working with pandoc
  - [pandoc-citeproc](https://github.com/jgm/pandoc-citeproc)
    supports citation and bibliography generation
    (note that the pandoc binary packages include this program).
  - [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref)
    is a filter that adds support for figure, table, and
    equation numbers and cross-references.

- Academic publishing workflows
  - [Manubot](https://manubot.org) is a workflow and set of tools for the next
    generation of scholarly publishing, including citation support and
    support for multiple output formats.
  - [Scholarly Markdown](http://scholarlymarkdown.com) is a set of
    tools whose main goal is to produce a semantically model of a scholarly
    article based on Markdown input and translate it to a variety of formats
    that is suitable for both online scholarly communication, archiving, and
    publication.

- Containers
  - [pandoc docker images](https://github.com/pandoc/dockerfiles)

- Lua filters (for a fuller list, see
  [the lua-filters
  repository](https://github.com/pandoc/lua-filters)
  - [Spell
    checking](https://github.com/pandoc/lua-filters/tree/master/spellcheck)
  - [Word count](https://github.com/pandoc/lua-filters/tree/master/wordcount).
  - [Embed textually-specified
    diagrams](https://github.com/pandoc/lua-filters/tree/master/diagram-generator) in PlantUML, Graphviz, TikZ, and Python.
  - [Handle scholarly
    metadata](https://github.com/pandoc/lua-filters/tree/master/scholarly-metadata).

