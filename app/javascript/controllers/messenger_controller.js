import { Controller } from "@hotwired/stimulus"

// Messenger page: the conversations list is replaced live when messages arrive,
// so re-mark the conversation that's open on the right.
export default class extends Controller {
  static targets = [ "list" ]
  static values = { selected: Number }

  listTargetConnected(list) {
    this.observer = new MutationObserver(() => this.highlightSelected())
    this.observer.observe(list, { childList: true })
    this.highlightSelected()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  highlightSelected() {
    this.listTarget.querySelectorAll("[data-conversation-id]").forEach(item => {
      const selected = Number(item.dataset.conversationId) === this.selectedValue
      item.classList.toggle("selected", selected)
      if (selected) item.setAttribute("aria-current", "page")
      else item.removeAttribute("aria-current")
    })
  }
}
