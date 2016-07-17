// ==UserScript==
// @match https://anime.soruly.hk/
// @match https://anime.soruly.hk/*
// ==/UserScript==

var elmTag = document.createElement('script');
elmTag.src = "http://localhost:4000/js/menu.js";
window.document.body.appendChild(elmTag);

var scriptTag = document.createElement('script');
scriptTag.src = "http://localhost:4000/js/danmaku.js";
window.document.body.appendChild(scriptTag);
