import render_setup from './render_setup.js'
import { cover_sketch } from '../sketches/cover-sketch.js';

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.cover-page').forEach(function(canvas_tag) {
    render_setup(cover_sketch, canvas_tag);
  });
});
