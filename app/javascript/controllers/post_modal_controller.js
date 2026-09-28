import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

// Shows a post's full content in a modal when its card is clicked.
// The data comes from the card's hidden .post-content block, so no request is made.
// While the modal is open the address bar shows the post's URL (/posts/:id),
// which also works as a standalone page when shared or refreshed.
export default class extends Controller {
  static targets = [ "modal", "content", "category", "title", "postedBy", "body", "actions" ]

  connect() {
    this.modal = Modal.getOrCreateInstance(this.modalTarget)
    this.restoreUrl = this.restoreUrl.bind(this)
    this.hideBeforeCache = this.hideBeforeCache.bind(this)
    this.modalTarget.addEventListener("hidden.bs.modal", this.restoreUrl)
    document.addEventListener("turbo:before-cache", this.hideBeforeCache)
  }

  disconnect() {
    this.modalTarget.removeEventListener("hidden.bs.modal", this.restoreUrl)
    document.removeEventListener("turbo:before-cache", this.hideBeforeCache)
    this.modal.dispose()
  }

  open(event) {
    const card = event.currentTarget
    const post = card.querySelector(".post-content")
    const branch = card.querySelector("[data-branch]")?.dataset.branch

    this.contentTarget.className = `modal-content post-modal branch-${branch}`
    this.categoryTarget.textContent = card.querySelector(".post-category").textContent
    this.titleTarget.textContent = post.querySelector("h3").textContent
    this.postedByTarget.textContent = post.querySelector(".posted-by").textContent
    this.bodyTarget.textContent = post.querySelector("p").textContent
    // Server-rendered per card: log in / I'm interested / nothing for your own post
    this.actionsTarget.innerHTML = post.querySelector(".post-actions").innerHTML

    this.previousUrl = window.location.href
    history.replaceState(history.state, "", card.id)
    this.modal.show()
  }

  restoreUrl() {
    if (this.previousUrl) {
      history.replaceState(history.state, "", this.previousUrl)
      this.previousUrl = null
    }
  }

  // Don't let Turbo cache the page with the modal open
  hideBeforeCache() {
    this.modalTarget.classList.remove("show")
    document.querySelectorAll(".modal-backdrop").forEach(el => el.remove())
    document.body.classList.remove("modal-open")
    document.body.removeAttribute("style")
    // Turbo has already moved to the next URL here, so leave history alone
    this.previousUrl = null
  }
}
