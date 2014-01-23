(function() {
  "use strict";
  chrome.app.runtime.onLaunched.addListener(function() {
    var height, width;
    width = 500;
    height = 300;
    chrome.app.window.create("index.html", {
      id: "main",
      bounds: {
        width: width,
        height: height,
        left: Math.round((screen.availWidth - width) / 2),
        top: Math.round((screen.availHeight - height) / 2)
      }
    });
  });

}).call(this);
