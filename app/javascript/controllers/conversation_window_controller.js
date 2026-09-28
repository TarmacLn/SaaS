import { Controller } from "@hotwired/stimulus"

// One conversation (a window, or the messenger page): expand/collapse by clicking its heading,
// keep the newest message in view, send with Enter (Shift+Enter for a new line).
// When older messages are added above, keep the view where it was instead of jumping.
// Reading the conversation marks the other person's messages as seen (the tutorial's set_as_seen).
export default class extends Controller {
  static targets = [ "body", "toggle", "messages", "input" ]
  static values = { expanded: Boolean, markSeenUrl: String }

  connect() {
    this.rememberScroll = this.rememberScroll.bind(this)
    this.markSeen = this.markSeen.bind(this)
    this.messagesTarget.addEventListener("scroll", this.rememberScroll, { passive: true })
    document.addEventListener("visibilitychange", this.markSeen)
    this.observer = new MutationObserver(() => this.messagesChanged())
    this.observer.observe(this.messagesTarget, { childList: true, subtree: true })
    this.rememberScroll()
    this.showUnseen()
    if (this.expandedValue) this.expand()
  }

  disconnect() {
    this.messagesTarget.removeEventListener("scroll", this.rememberScroll)
    document.removeEventListener("visibilitychange", this.markSeen)
    this.observer.disconnect()
  }

  messagesChanged() {
    const list = this.messagesTarget
    const lastMessage = list.querySelector("ul > li:last-child")
    this.showUnseen()
    if (lastMessage !== this.lastMessage) {
      // a new message at the bottom
      this.scrollToBottom()
      this.markSeen()
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
    if (this.hasToggleTarget) this.toggleTarget.setAttribute("aria-expanded", "true")
    this.scrollToBottom()
    this.focusInput()
    this.markSeen()
  }

  collapse() {
    this.bodyTarget.hidden = true
    if (this.hasToggleTarget) this.toggleTarget.setAttribute("aria-expanded", "false")
  }

  // Only when the conversation is actually visible to the user
  async markSeen() {
    if (!this.hasMarkSeenUrlValue || this.bodyTarget.hidden || document.hidden || this.markingSeen) return
    if (this.unseenMessages.length === 0) return

    this.markingSeen = true
    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content
      const response = await fetch(this.markSeenUrlValue, { method: "POST", headers: { "X-CSRF-Token": token } })
      if (response.ok) {
        this.unseenMessages.forEach(message => message.classList.remove("unseen"))
        this.showUnseen()
      }
    } finally {
      this.markingSeen = false
    }
  }

  // Highlights the heading while the other person's messages are unread
  showUnseen() {
    this.element.classList.toggle("has-unseen", this.unseenMessages.length > 0)
  }

  // Unseen messages written by the other person (by author, so it works before
  // the message controller has set message-received on a just-arrived message)
  get unseenMessages() {
    const currentUserId = document.querySelector('meta[name="current-user-id"]')?.content
    return Array.from(this.messagesTarget.querySelectorAll("li.unseen[data-user-id]"))
      .filter(message => message.dataset.userId !== currentUserId)
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
