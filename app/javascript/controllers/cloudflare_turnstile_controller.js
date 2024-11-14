import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cloudflare-turnstile"
export default class extends Controller {
  connect() {
    // window.turnstile is available thanks to the js script you added in the head.
    if (document.querySelector('.cf-turnstile') && window.turnstile) {
      window.turnstile.render(".cf-turnstile")
    }
  }
}
