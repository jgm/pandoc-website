(function() {
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
    target = '-x86_64-macOS.pkg';
  } else if (iosPlatforms.indexOf(platform) !== -1) {
  } else if (windowsPlatforms.indexOf(platform) !== -1) {
    if (userAgent.indexOf("WOW64") !== -1 || userAgent.indexOf("Win64") !== -1){
      detected = 'Windows (64-bit)';
      target = '-windows-x86_64.msi';
    } else {
      detected = 'Windows (32-bit)';
      target = '-windows-i386.msi';
    }
  } else if (/Android/.test(userAgent)) {
  } else if (/Linux/.test(platform)) {
    if (/aarch64|armv8/i.test(platform)) {
      detected = 'Linux (ARM 64-bit)';
      target = '-arm64.deb';
    } else {
      detected = 'Linux (64-bit)';
      target = '-amd64.deb';
    }
  }

  // On macOS, try to detect Apple Silicon via userAgentData
  // (available in Chromium-based browsers). Falls back to x86_64
  // which works on Apple Silicon via Rosetta 2.
  if (detected === 'macOS' && navigator.userAgentData) {
    navigator.userAgentData.getHighEntropyValues(['architecture'])
    .then(function(ua) {
      if (ua.architecture === 'arm') {
        target = '-arm64-macOS.pkg';
        detected = 'macOS (Apple Silicon)';
      }
      fetchInstaller(target, detected);
    });
  } else if (target) {
    fetchInstaller(target, detected);
  }

  function fetchInstaller(target, detected) {
    fetch("https://api.github.com/repos/jgm/pandoc/releases?per_page=1")
    .then(function(data) {
        return data.json();
    })
    .then(function(json) {
      var assets = json[0].assets.filter(function(a){
        return a.name.endsWith(target);
      });
      if (assets[0]) {
        var btn = document.getElementById('downloadInstallerBtn');
        btn.setAttribute('href', assets[0].browser_download_url);
        btn.innerHTML = 'Download the latest installer for ' + detected;
      }
    });
  }
})();
