import render_setup from './render_setup.js'
import { section_sketch } from '../sketches/section-sketch.js'

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.section-page').forEach(function(canvas_tag) {
    render_setup(section_sketch, canvas_tag);
  });
});
