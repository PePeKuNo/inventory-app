import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// The "Fields" tab. Every slot (3 per type) is rendered; unused slots are hidden.
// "Add" shows the next free slot of the chosen type, "remove" hides it again.
// Dragging rows changes the order, which is saved in the *_position inputs.
export default class extends Controller {
  static targets = ["list", "row"]

  connect() {
    this.sortable = Sortable.create(this.listTarget, { handle: ".drag-handle", onEnd: () => this.changed() })
  }

  disconnect() {
    this.sortable.destroy()
  }

  add(event) {
    const type = event.params.type
    const row = this.rowTargets.find((r) => r.dataset.type === type && r.hidden)
    if (!row) return alert(this.element.dataset.limitMessage)
    row.hidden = false
    row.querySelector("[data-state]").value = "true"
    this.listTarget.append(row) // new fields go to the end
    row.querySelector("input[type=text]").focus()
    this.changed()
  }

  remove(event) {
    const row = event.target.closest("[data-fields-target='row']")
    row.hidden = true
    row.querySelector("[data-state]").value = "false"
    this.changed()
  }

  changed() {
    this.rowTargets.forEach((row, index) => (row.querySelector("[data-position]").value = index))
    this.element.dispatchEvent(new Event("change", { bubbles: true })) // tells autosave
  }
}
