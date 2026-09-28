import { Controller } from "@hotwired/stimulus"

// Lays out the conversation windows along the bottom of the screen (newest on the right,
// via CSS) and hides the oldest ones when they no longer fit, like the tutorial's
// positionChatWindows/hideShowChatWindow, without the manual pixel positioning.
const WINDOW_WIDTH = 320
const GAP = 10

export default class extends Controller {
  connect() {
    this.layout = this.layout.bind(this)
    window.addEventListener("resize", this.layout)
    this.observer = new MutationObserver(this.layout)
    this.observer.observe(this.element, { childList: true })
    this.layout()
  }

  disconnect() {
    window.removeEventListener("resize", this.layout)
    this.observer.disconnect()
  }

  layout() {
    const fits = Math.max(1, Math.floor((window.innerWidth - GAP) / (WINDOW_WIDTH + GAP)))
    this.windows.forEach((chatWindow, index) => { chatWindow.hidden = index >= fits })
  }

  get windows() {
    return Array.from(this.element.querySelectorAll(":scope > .conversation-window"))
  }
}
