$("#form-search").submit(function(event) {
  var searchtext = $("#input-search").first().val().replace(/\b(\w+)/g,'+$1');
  var results = idx.search(searchtext);
  // put 'releases' matches at end
  results.sort(function(first, second) {
    if (first.ref.match(/^releases\.html/)) {
      return 1 ;
    } else {
      return second.score - first.score ;
    }
  });
  $("#search-data").html("<p>" + results.length + " matches.</p>");
  for (var i = 0; i < results.length; i++) {
    var result = results[i];
    $("#search-data").append('<p><a href="' + result.ref + '"</a>' + (titles[result.ref].replace(/^Pandoc - /,'') || result.ref) + '</p>');
  }
  $("#search-results").modal();
  event.preventDefault();
});
