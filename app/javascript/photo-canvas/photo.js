import render_setup from './render_setup.js'
import { photo_sketch } from '../sketches/photo-sketch.js'

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.photo-content').forEach(function(canvas_tag) {
    render_setup(photo_sketch, canvas_tag);
  });
});
