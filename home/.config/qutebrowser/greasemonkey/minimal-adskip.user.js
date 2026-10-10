// ==UserScript==
// @name        YouTube ad skip
// @description Based on adcott's script from r/qutebrowser
// @match       *://*.youtube.com/*
// ==/UserScript==

new MutationObserver(mutations => {
  for (const m of mutations) {
    for (const node of m.addedNodes) {
      if (node.nodeType !== 1) continue;
      if (!node.classList.contains('ytp-ad-persistent-progress-bar-container')) continue;
      const video = document.querySelector('.html5-main-video');
      if (video && isFinite(video.duration)) video.currentTime = video.duration;
    }
  }
}).observe(document.documentElement, { childList: true, subtree: true });
