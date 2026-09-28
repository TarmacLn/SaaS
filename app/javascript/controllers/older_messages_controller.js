import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Sits at the top of a conversation's messages. When it scrolls into view,
// it loads the previous batch of messages (Private::MessagesController#index),
// which replaces it with those messages and, if there are more, a new loader.
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.observer = new IntersectionObserver(entries => {
      if (entries.some(entry => entry.isIntersecting)) this.load()
    }, { root: this.element.closest(".messages-list"), rootMargin: "150px 0px 0px 0px" })
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer.disconnect()
  }

  async load() {
    if (this.loading) return
    this.loading = true
    this.observer.disconnect()

    try {
      const response = await fetch(this.urlValue, { headers: { Accept: "text/vnd.turbo-stream.html" } })
      if (!response.ok) throw new Error(response.statusText)
      Turbo.renderStreamMessage(await response.text())
    } catch {
      // try again the next time it scrolls into view
      this.loading = false
      if (this.element.isConnected) this.observer.observe(this.element)
    }
  }
}
