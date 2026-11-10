import { Controller } from "@hotwired/stimulus"

// Turns every [data-bs-toggle="popover"] inside the element into a Bootstrap popover.
export default class extends Controller {
  connect() {
    this.popovers = [...this.element.querySelectorAll('[data-bs-toggle="popover"]')]
      .map((el) => new window.bootstrap.Popover(el, { trigger: "focus", html: true }))
  }

  disconnect() {
    this.popovers.forEach((popover) => popover.dispose())
  }
}
