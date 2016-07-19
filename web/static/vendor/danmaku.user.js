// ==UserScript==
// @match https://anime.soruly.hk/
// @match https://anime.soruly.hk/*
// ==/UserScript==

var elmTag = document.createElement('script');
elmTag.src = "https://danmaku.b123400.net/js/menu.js";
window.document.body.appendChild(elmTag);

var scriptTag = document.createElement('script');
scriptTag.src = "https://danmaku.b123400.net/js/danmaku.js";
window.document.body.appendChild(scriptTag);
