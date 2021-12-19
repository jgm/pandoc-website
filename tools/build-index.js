// npm install lunr jsdom glob

var lunr = require('lunr'),
    jsdom = require('jsdom'),
    glob = require('glob'),
    fs = require('fs'),
    process = require('process'),
    stdin = process.stdin,
    stdout = process.stdout,
    stderr = process.stderr,
    buffer = [];

const { JSDOM } = jsdom;

function getHtmlText(fp) {
  try {
    var raw = fs.readFileSync(fp, 'utf8');
    const dom = new JSDOM(raw);
    const title = dom.window.document.querySelector("title").textContent.replace(/^Pandoc - /,'');
    const matches = dom.window.document.querySelectorAll("section");
    const toplevel = dom.window.document.querySelector("main > p");
    const basename = fp.replace(/^site\//,'');
    var results = [];
    if (toplevel) {
      results.push({ name: basename,
                     title: title,
                     text: toplevel.textContent });
    }
    matches.forEach(function(el) {
      const sectident = el.getAttribute("id");
      const secttitle = el.querySelector("h1") || el.querySelector("h2") ||
                        el.querySelector("h3") || el.querySelector("h4") ||
                        el.querySelector("p");
      results.push({ name: basename + "#" + sectident,
                     title: title,
                     sectionTitle: secttitle ? secttitle.textContent.substring(0,80) : null,
                     text: el.textContent });
    });
    return results;
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

var searchCode;

try {
  searchCode = fs.readFileSync('js/search.js', 'utf8');
} catch (err) {
  console.error(err);
  process.exit(1);
}

var documents = [];
var titles = {};

var files = glob.sync("site/*.html");
files.forEach(function(file) {
  // stderr.write("Processing " + file + "\n");
  var doc = getHtmlText(file);
  documents = documents.concat(doc);
  doc.forEach(function(d) {
    if (d.sectionTitle) {
      // stderr.write("  " + d.sectionTitle + "\n");
      titles[d.name] = d.title + " - " + d.sectionTitle ;
    } else {
      // stderr.write(  "(top)\n");
      titles[d.name] = d.title ;
    }
  });
});

var idx = lunr(function () {
    this.ref('name')
    this.field('text')

    documents.forEach(function (doc) {
      this.add(doc)
    }, this)
});

stdout.write('(function(){' +
    'var idx = lunr.Index.load(' + JSON.stringify(idx) + ');\n' +
    'var titles = ' + JSON.stringify(titles) + ';\n' +
    searchCode + '})();');
