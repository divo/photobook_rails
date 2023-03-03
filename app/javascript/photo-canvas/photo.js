import { render_photo } from 'photo-canvas/album_builder'
import render_setup from 'photo-canvas/render_setup'
import { photo_sketch } from '@divo/photobook-sketches'

document.addEventListener("turbo:load", function() {
  render_photo();
});

document.addEventListener("turbo:frame-render", function(event) {
  const canvas_tag = event.target.querySelectorAll('.photo-content')[0]
  render_setup(photo_sketch, canvas_tag);
  $('[data-toggle="tooltip"]').tooltip()
});
