var _user$project$Native_TextMeasure = (function() {

  var canvas = null;

  function getCanvas() {
    if (!canvas) canvas = document.createElement('canvas');
    return canvas;
  }

  function measureText(font, string) {
    var canvas = getCanvas();
    canvas.font = font;
    return canvas.getContext('2d')
      .measureText(string)
      .width;
  }

  return {
    measureText: F2(measureText)
  };
})();
