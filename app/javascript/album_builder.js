import render_setup from './photo-canvas/render_setup.js'
import { cover_sketch } from './sketches/cover-sketch.js';
import { photo_sketch } from './sketches/photo-sketch.js'
import { section_sketch } from './sketches/section-sketch.js'

export const render_cover = () => {
  document.querySelectorAll('.cover-page').forEach(function(canvas_tag) {
    render_setup(cover_sketch, canvas_tag);
  });
}

export const render_photo = () => {
  document.querySelectorAll('.photo-content').forEach(function(canvas_tag) {
    render_setup(photo_sketch, canvas_tag);
  });
}

export const render_section = () => {
  document.querySelectorAll('.section-page').forEach(function(canvas_tag) {
    render_setup(section_sketch, canvas_tag);
  });
}

addEventListener("turbo:before-stream-render", ((event) => {
  event.detail.render = function (streamElement) {
    if (streamElement.action == "build_complete") {
      $("#album_building").bind("transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", function(){
        $('#album_building').remove();
      });

      $('#album_building').toggleClass('fadedOut');
      $('#photo_album_content').html(event.srcElement.children[0].innerHTML); //ugh
      render_cover();
      render_section();
      render_photo();
    }
  }
}));
