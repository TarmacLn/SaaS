import { Controller } from "@hotwired/stimulus"

// One conversation window: expand/collapse by clicking its heading,
// keep the newest message in view, send with Enter (Shift+Enter for a new line).
// When older messages are added above, keep the view where it was instead of jumping.
export default class extends Controller {
  static targets = [ "body", "toggle", "messages", "input" ]
  static values = { expanded: Boolean }

  connect() {
    this.rememberScroll = this.rememberScroll.bind(this)
    this.messagesTarget.addEventListener("scroll", this.rememberScroll, { passive: true })
    this.observer = new MutationObserver(() => this.messagesChanged())
    this.observer.observe(this.messagesTarget, { childList: true, subtree: true })
    this.rememberScroll()
    if (this.expandedValue) this.expand()
  }

  disconnect() {
    this.messagesTarget.removeEventListener("scroll", this.rememberScroll)
    this.observer.disconnect()
  }

  messagesChanged() {
    const list = this.messagesTarget
    const lastMessage = list.querySelector("ul > li:last-child")
    if (lastMessage !== this.lastMessage) {
      // a new message at the bottom
      this.scrollToBottom()
    } else {
      // older messages or date lines added above: stay on the same messages
      list.scrollTop = this.scrollTop + (list.scrollHeight - this.scrollHeight)
    }
    this.rememberScroll()
  }

  rememberScroll() {
    const list = this.messagesTarget
    this.scrollTop = list.scrollTop
    this.scrollHeight = list.scrollHeight
    this.lastMessage = list.querySelector("ul > li:last-child")
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
    this.rememberScroll()
  }
}
