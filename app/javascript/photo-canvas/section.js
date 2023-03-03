import { render_section } from './album_builder'

document.addEventListener("turbo:load", function() {
  render_section();
});
