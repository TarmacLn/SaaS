import { Controller } from "@hotwired/stimulus"

// One conversation window: expand/collapse by clicking its heading,
// keep the newest message in view, send with Enter (Shift+Enter for a new line).
export default class extends Controller {
  static targets = [ "body", "toggle", "messages", "input" ]
  static values = { expanded: Boolean }

  connect() {
    this.observer = new MutationObserver(() => this.scrollToBottom())
    this.observer.observe(this.messagesTarget, { childList: true, subtree: true })
    if (this.expandedValue) this.expand()
  }

  disconnect() {
    this.observer.disconnect()
  }

  toggle() {
    this.bodyTarget.hidden ? this.expand() : this.collapse()
  }

  expand() {
    this.bodyTarget.hidden = false
    this.toggleTarget.setAttribute("aria-expanded", "true")
    this.scrollToBottom()
    this.focusInput()
  }

  collapse() {
    this.bodyTarget.hidden = true
    this.toggleTarget.setAttribute("aria-expanded", "false")
  }

  submitOnEnter(event) {
    if (event.shiftKey || event.isComposing) return
    event.preventDefault()
    if (event.target.value.trim() !== "") event.target.form.requestSubmit()
  }

  // The form is replaced after each message; keep typing in the new one
  inputTargetConnected() {
    if (!this.hasBodyTarget || this.bodyTarget.hidden) return
    const active = document.activeElement
    if (!active || active === document.body || this.element.contains(active)) this.focusInput()
  }

  focusInput() {
    if (this.hasInputTarget && !this.bodyTarget.hidden) this.inputTarget.focus()
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}
