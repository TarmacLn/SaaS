import { Controller } from "@hotwired/stimulus"

// A chat message is broadcast once to both users, so the server can't know whether
// it's "yours". Each browser compares the author with the signed-in user instead.
export default class extends Controller {
  connect() {
    const currentUserId = document.querySelector('meta[name="current-user-id"]')?.content
    const sentByMe = currentUserId !== "" && this.element.dataset.userId === currentUserId

    this.element.classList.toggle("message-sent", sentByMe)
    this.element.classList.toggle("message-received", !sentByMe)
  }
}
