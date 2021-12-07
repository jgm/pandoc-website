$("#form-search").submit(function(event) {
  var results = idx.search($("#input-search").first().val());
  $("#search-data").html("<p>" + results.length + " matches.</p>");
  for (var i = 0; i < results.length; i++) {
    var result = results[i];
    $("#search-data").append('<p><a href="' + result.ref + '"</a>' + result.ref + '</p>');
  }
  $("#search-results").modal();
  event.preventDefault();
});
