var lunr = require('lunr'),
    fs = require('fs'),
    stdin = process.stdin,
    stdout = process.stdout,
    buffer = [];

stdin.resume();
stdin.setEncoding('utf8');

stdin.on('data', function (data) {
  buffer.push(data)
});

stdin.on('end', function () {

  var documents = JSON.parse(buffer.join(''));

  var idx = lunr(function () {
    this.ref('name')
    this.field('text')

    documents.forEach(function (doc) {
      this.add(doc)
    }, this)
  });

  stdout.write('(function(){ idx = lunr.Index.load(' + JSON.stringify(idx) + '); $("#form-search").submit(function(event) { console.log(idx.search($("#input-search").first().val())); event.preventDefault(); })})();');
});
