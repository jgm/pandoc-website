(function() {
  /* Make TOC headings collapse */
  document.querySelectorAll('#toc > ul > li').forEach( function(li) {
    if (li.children.length > 1) {
      var toggle = document.createElement('span');
      toggle.className = 'toggle';
      toggle.innerHTML = '▸';
      toggle.onclick = function() {
        var sublist = li.getElementsByTagName('ul')[0];
        if (sublist) {
          if (sublist.style.display === 'none') {
            sublist.style.display = 'block'
            toggle.innerHTML = '▾';
          } else {
            sublist.style.display = 'none';
            toggle.innerHTML = '▸';
          }
        }
      };
      li.appendChild(toggle);
      toggle.click();
    }
  });

  /* The dropdown menu should go away when someone clicks outside it */
  window.onclick = function(event) {
    if (!event.target ||
        (!event.target.matches('.dropdown-menu') &&
         !event.target.matches('.dropdown-toggle'))) {
      document.querySelectorAll('.dropdown-menu').forEach(function(el) {-
         el.classList.remove("show");
      })
    }
  }

  /* Add dropdown menu to items with dropdown-toggle class */
  document.querySelectorAll('.dropdown-toggle').forEach( function(el) {
    el.addEventListener("click", function(event) {
    el.parentNode.querySelectorAll('.dropdown-menu').forEach(function(div) {
      div.classList.toggle("show");
      });
    el.classList.toggle("expanded");
    })
  })

  document.querySelectorAll('section.card').forEach( function(el) {
    el.addEventListener("click", function(event) {
      el.classList.toggle("show");
    })
  })

})();
