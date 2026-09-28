import { Controller } from "@hotwired/stimulus"

// Messenger page: the conversations list is replaced live when messages arrive,
// so re-mark the conversation that's open on the right ("pc5" private, "gc3" group).
export default class extends Controller {
  static targets = [ "list" ]
  static values = { selected: String }

  listTargetConnected(list) {
    this.observer = new MutationObserver(() => this.highlightSelected())
    this.observer.observe(list, { childList: true })
    this.highlightSelected()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  highlightSelected() {
    this.listTarget.querySelectorAll("[data-conversation-key]").forEach(item => {
      const selected = item.dataset.conversationKey === this.selectedValue
      item.classList.toggle("selected", selected)
      if (selected) item.setAttribute("aria-current", "page")
      else item.removeAttribute("aria-current")
    })
  }
}
