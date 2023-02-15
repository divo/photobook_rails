import render_setup from './render_setup.js'
import { photo_sketch } from '../sketches/photo-sketch.js'

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.photo-content').forEach(function(canvas_tag) {
    render_setup(photo_sketch, canvas_tag);
  });
});

document.addEventListener("turbo:frame-render", function(event) {
  const canvas_tag = event.target.querySelectorAll('.photo-content')[0]
  render_setup(photo_sketch, canvas_tag);
});
