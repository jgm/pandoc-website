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
    const text = dom.window.document.querySelector("main").textContent;
    return { name: fp.replace(/^site\//,''), text: text };
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

var files = glob.sync("site/*.html");
files.forEach(function(file) {
    documents.push(getHtmlText(file));
});

var idx = lunr(function () {
    this.ref('name')
    this.field('text')

    documents.forEach(function (doc) {
      this.add(doc)
    }, this)
});

stdout.write('(function(){' +
    'idx = lunr.Index.load(' + JSON.stringify(idx) + ');\n' +
    searchCode + '})();');
