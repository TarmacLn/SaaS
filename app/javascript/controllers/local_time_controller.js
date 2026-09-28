import { Controller } from "@hotwired/stimulus"

// Shows a <time datetime="…UTC…"> in the viewer's own time zone and locale.
// The server renders UTC (so the same HTML is right for everyone, e.g. broadcast
// chat messages); the browser converts it.
//
//   format "short" (default): "14:38" for today, "28 Sep, 14:38" for other days
//   format "title":           keep the text (e.g. "5 minutes ago"), only add a tooltip
//
// Either way the full local date and time goes in the title tooltip.
export default class extends Controller {
  static values = { format: { type: String, default: "short" } }

  connect() {
    const date = new Date(this.element.getAttribute("datetime"))
    if (isNaN(date)) return

    this.element.title = date.toLocaleString(undefined, { dateStyle: "full", timeStyle: "short" })
    if (this.formatValue === "short") this.element.textContent = this.short(date)
  }

  short(date) {
    const time = date.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" })
    if (this.isToday(date)) return time

    const sameYear = date.getFullYear() === new Date().getFullYear()
    const day = date.toLocaleDateString(undefined, { day: "numeric", month: "short", year: sameYear ? undefined : "numeric" })
    return `${day}, ${time}`
  }

  isToday(date) {
    return date.toDateString() === new Date().toDateString()
  }
}
