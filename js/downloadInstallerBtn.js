(function() {
  // from https://stackoverflow.com/a/38241481/214446
  var userAgent = window.navigator.userAgent
    , platform = window.navigator.platform
    , macosPlatforms = ['Macintosh', 'MacIntel']
    , windowsPlatforms = ['Win32', 'Win64', 'Windows', 'WinCE']
    , iosPlatforms = ['iPhone', 'iPad', 'iPod']
    , target = null
    , detected
    ;
  if (macosPlatforms.indexOf(platform) !== -1) {
    detected = 'macOS';
    target = '-macOS.pkg';
  } else if (iosPlatforms.indexOf(platform) !== -1) {
  } else if (windowsPlatforms.indexOf(platform) !== -1) {
    if (userAgent.indexOf("WOW64") !== -1 || userAgent.indexOf("Win64") !== -1){
      // from https://stackoverflow.com/a/6866569/214446
      detected = 'Windows (64-bit)';
      target = '-windows-x86_64.msi';
    } else {
      detected = 'Windows (32-bit)';
      target = '-windows-i386.msi';
    }
  } else if (/Android/.test(userAgent)) {
  } else if (!os && /Linux/.test(platform)) {
    detected = 'Linux (64-bit)';
    target = '-amd64.deb';
  }

  if (target) {
    fetch("https://api.github.com/repos/jgm/pandoc/releases")
    .then(function(data) {
        return data.json();
    })
    .then(function(json) {
      var assets = json[0].assets.filter(function(a){
        return a.name.endsWith(target)
      });
      if (assets[0]) {
        var btn = document.getElementById('downloadInstallerBtn');
        btn.setAttribute('href', assets[0].browser_download_url);
        btn.innerHTML = 'Download the latest installer for ' + detected;
      }
    });
  }
})();
