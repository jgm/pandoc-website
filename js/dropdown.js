function toggleDropdown(el) {
  el.parentNode.querySelectorAll('.dropdown-menu').forEach(function(div) {
    div.classList.toggle("show");
  });
  el.classList.toggle("expanded");
}

window.onclick = function(event) {
  if (!event.target.matches('.dropdown-menu') &&
      !event.target.matches('.dropdown-toggle')) {
    document.querySelectorAll('.dropdown-menu').forEach(function(el) {-
       el.classList.remove("show");
    })
  }
}
