import { render_cover } from '../album_builder.js'

document.addEventListener("turbo:load", function(e) {
  render_cover();
});

document.addEventListener("turbo:before-cache", function() {
  // Remove canvas from DOM so turbo doesn't cache it
  // It doesn't cache the image correctly anyway
  document.querySelectorAll('.cover-page').forEach(function(canvas_tag) {
    canvas_tag.innerHTML = '';
  });
});
