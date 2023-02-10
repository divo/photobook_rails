import render_setup from './render_setup.js'
import { cover_sketch } from '../sketches/cover-sketch.js';

document.addEventListener("turbo:load", function(e) {
  document.querySelectorAll('.cover-page').forEach(function(canvas_tag) {
    render_setup(cover_sketch, canvas_tag);
  });
});

document.addEventListener("turbo:before-cache", function() {
  // Remove canvas from DOM so turbo doesn't cache it
  // It doesn't cache the image correctly anyway
  document.querySelectorAll('.cover-page').forEach(function(canvas_tag) {
    canvas_tag.innerHTML = '';
  });
});
