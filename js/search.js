function removeAllChildNodes(parent) {
    while (parent.firstChild) {
        parent.removeChild(parent.firstChild);
    }
}
var formSearch = document.querySelector("#form-search");
formSearch.addEventListener("submit", function(event) {
  var searchtext = this.querySelector("#input-search").value.replace(/\b(\w+)/g,'+$1');
  var results = idx.search(searchtext);
  // put 'releases' matches at end
  results.sort(function(first, second) {
    if (first.ref.match(/releases\.html/)) {
      return 1 ;
    } else if (second.ref.match(/releases\.html/)) {
      return -1 ;
    } else {
      return second.score - first.score ;
    }
  });
  var searchData = document.querySelector("#search-data");
  var matches = document.querySelector("#search-results .modal-title");
  matches.textContent = results.length + " matches";
  removeAllChildNodes(searchData);
  for (var i = 0; i < results.length; i++) {
    var result = results[i];
    var par = document.createElement("p");
    var a = document.createElement("a");
    a.setAttribute("href", result.ref);
    a.textContent = titles[result.ref].replace(/^Pandoc - /,'') || result.ref;
    par.appendChild(a);
    searchData.appendChild(par);
  }
  var results = document.querySelector("#search-results");
  results.classList.add("show");
  results.querySelector(".modal-header button")
         .addEventListener("click",
                           function() {
                             results.classList.remove("show");
                           });
  event.preventDefault();
});
