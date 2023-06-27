// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//= require jquery3
//= require popper
//= require bootstrap-sprockets
import "@hotwired/turbo-rails"
import "controllers"

import "photo-canvas/album_builder"
import "photo-canvas/photo"
import "photo-canvas/cover"
import "photo-canvas/section"
import "@divo/photobook-sketches"

Turbo.setConfirmMethod((message, element) => {
  let dialog = document.getElementById("turbo-confirm")
  document.getElementById('dialog-message').innerHTML = message
  dialog.showModal()

  return new Promise((resolve, reject) => {
    dialog.addEventListener("close", () => {
      resolve(dialog.returnValue == "confirm")
    }, { once: true })
  })
})
