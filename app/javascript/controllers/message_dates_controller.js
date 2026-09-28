import { Controller } from "@hotwired/stimulus"

// Adds a date line ("Today", "Yesterday", "28 September") above the first message
// of each day, using the viewer's own time zone. Runs again whenever messages are
// added, so messages that arrive later get their date lines too.
// (The tutorial's private_message_date_check helper, done in the browser.)
export default class extends Controller {
  connect() {
    this.observer = new MutationObserver(() => this.refresh())
    this.refresh()
  }

  disconnect() {
    this.observer.disconnect()
  }

  refresh() {
    this.observer.disconnect()

    this.element.querySelectorAll(":scope > .messages-date").forEach(line => line.remove())
    let previousDay = null
    this.messages.forEach(message => {
      const date = this.dateOf(message)
      if (!date) return

      const day = date.toDateString()
      if (day !== previousDay) message.before(this.dateLine(date))
      previousDay = day
    })

    this.observer.observe(this.element, { childList: true })
  }

  get messages() {
    return Array.from(this.element.querySelectorAll(":scope > li:not(.messages-date)"))
  }

  dateOf(message) {
    const datetime = message.querySelector("time[datetime]")?.getAttribute("datetime")
    const date = datetime && new Date(datetime)
    return date && !isNaN(date) ? date : null
  }

  dateLine(date) {
    const line = document.createElement("li")
    line.className = "messages-date"
    line.setAttribute("role", "separator")
    const label = document.createElement("span")
    label.textContent = this.label(date)
    line.append(label)
    return line
  }

  label(date) {
    const today = new Date()
    const yesterday = new Date(today)
    yesterday.setDate(today.getDate() - 1)

    if (date.toDateString() === today.toDateString()) return "Today"
    if (date.toDateString() === yesterday.toDateString()) return "Yesterday"

    const sameYear = date.getFullYear() === today.getFullYear()
    return date.toLocaleDateString(undefined, { day: "numeric", month: "long", year: sameYear ? undefined : "numeric" })
  }
}
