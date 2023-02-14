import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect(event) {
    $('[data-toggle="tooltip"]').tooltip()
  }

  update_address(event) {
    const album_id = event.target.dataset.albumId
    const image_id = event.target.dataset.id
    const csrfToken = document.querySelector("[name='csrf-token']").content

    fetch(`/photo_albums/${album_id}/pages/${image_id}/set_caption`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({ caption: event.target.value, image_id: image_id })
    }).then(response => {
      debugger
    })
  }
}
