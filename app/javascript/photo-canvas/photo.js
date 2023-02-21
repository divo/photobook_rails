import { render_photo } from '../album_builder.js'
import render_setup from './render_setup.js'
import { photo_sketch } from '../sketches/photo-sketch.js'

document.addEventListener("turbo:load", function() {
  render_photo();
});

document.addEventListener("turbo:frame-render", function(event) {
  const canvas_tag = event.target.querySelectorAll('.photo-content')[0]
  render_setup(photo_sketch, canvas_tag);
  $('[data-toggle="tooltip"]').tooltip()
});
