// ==UserScript==
// @name        Minimal YouTube
// @match       *://*.youtube.com/*
// @run-at      document-start
// ==/UserScript==

const css = `
  /* home page feed */
  ytd-browse[page-subtype="home"] #contents { display: none !important; }

  /* sponsored / ads */
  ytd-ad-slot-renderer,
  ytd-in-feed-ad-layout-renderer,
  ytd-rich-item-renderer:has(ytd-ad-slot-renderer),
  ytd-promoted-sparkles-web-renderer,
  ytd-banner-promo-renderer,
  ytd-statement-banner-renderer,
  #masthead-ad, #player-ads { display: none !important; }

  /* shorts */
  ytd-reel-shelf-renderer,
  ytd-rich-shelf-renderer[is-shorts],
  ytd-rich-section-renderer:has(ytd-rich-shelf-renderer[is-shorts]),
  ytd-rich-item-renderer:has(a[href^="/shorts"]),
  ytd-video-renderer:has(a[href^="/shorts"]),
  ytd-guide-entry-renderer:has(a[title="Shorts"]),
  ytd-mini-guide-entry-renderer:has(a[title="Shorts"]),
  a[href^="/shorts"] { display: none !important; }

  /* recommendations beside/below the video */
  #secondary, #related { display: none !important; }

  /* comments */
  #comments, ytd-comments { display: none !important; }

  /* suggestions at the end of a video */
  .ytp-endscreen-content, .ytp-ce-element { display: none !important; }

    /* YouTube Premium popup */
  yt-mealbar-promo-renderer,
  ytd-mealbar-promo-renderer { display: none !important; }

  /* category chips on the home page */
  ytd-feed-filter-chip-bar-renderer { display: none !important; }

  /* Shorts shelf in search results */
  grid-shelf-view-model:has(a[href^="/shorts"]),
  ytm-shorts-lockup-view-model,
  ytm-shorts-lockup-view-model-v2 { display: none !important; }

  /* chip row in search (All / Shorts / Unwatched ...) */
  ytd-search-header-renderer chip-bar-view-model,
  ytd-search-header-renderer yt-chip-cloud-renderer { display: none !important; }

  /* voice search button */
  #voice-search-button { display: none !important; }
`;

function inject() {
  const root = document.head || document.documentElement;
  if (!root) return setTimeout(inject, 10);
  const style = document.createElement('style');
  style.textContent = css;
  root.appendChild(style);
}
inject();
