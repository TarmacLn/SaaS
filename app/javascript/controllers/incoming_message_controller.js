import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Broadcast to a message's recipient. If that conversation's window isn't open yet,
// open it (Private::ConversationsController#open, which also remembers it in the session).
// If it is open, the message itself was already appended to it by its own broadcast.
export default class extends Controller {
  static values = { windowId: String, openUrl: String }

  async connect() {
    try {
      // No window area on the messenger page; the conversation list there updates by itself
      const hasWindows = document.getElementById("conversations-windows")
      if (hasWindows && !document.getElementById(this.windowIdValue)) await this.openWindow()
    } finally {
      this.element.remove()
    }
  }

  async openWindow() {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    const response = await fetch(this.openUrlValue, {
      method: "POST",
      headers: { Accept: "text/vnd.turbo-stream.html", "X-CSRF-Token": token }
    })
    if (response.ok) Turbo.renderStreamMessage(await response.text())
  }
}
