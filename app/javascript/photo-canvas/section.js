import { render_section } from '../album_builder.js'

document.addEventListener("turbo:load", function() {
  render_section();
});
