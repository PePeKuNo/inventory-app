import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// The "Custom ID" builder: drag rows to reorder, drag a row out of the list to delete it,
// "Add element" clones a template row. After every change the server renders a preview.
export default class extends Controller {
  static targets = ["list", "template", "preview", "addButton"]
  static values = { previewUrl: String, max: Number }

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      handle: ".drag-handle",
      removeOnSpill: true, // dropping outside the list removes the element
      onEnd: () => this.changed(),
      onRemove: () => this.changed()
    })
    this.listTarget.querySelectorAll(".id-element").forEach((row) => this.updateRow(row))
    this.refreshPreview()
  }

  disconnect() {
    this.sortable.destroy()
  }

  add() {
    if (this.listTarget.children.length >= this.maxValue) return
    this.listTarget.append(this.templateTarget.content.cloneNode(true))
    this.updateRow(this.listTarget.lastElementChild)
    this.changed()
  }

  typeChanged(event) {
    this.updateRow(event.target.closest(".id-element"))
    this.refreshPreview()
  }

  // GUID has no format options, so its format box is hidden. The help text depends on the type.
  updateRow(row) {
    const type = row.querySelector("select").value
    row.querySelector(".format-input").classList.toggle("d-none", type === "guid")
    row.querySelectorAll("[data-help]").forEach((help) => help.classList.toggle("d-none", help.dataset.help !== type))
  }

  changed() {
    this.addButtonTarget.disabled = this.listTarget.children.length >= this.maxValue
    this.element.dispatchEvent(new Event("change", { bubbles: true })) // tells autosave
    this.refreshPreview()
  }

  async refreshPreview() {
    const data = new FormData(this.element)
    data.delete("_method") // the preview route is a plain POST, not the form's PATCH
    // Form tokens are bound to the form's own action, so we send the page-wide CSRF token instead.
    const token = document.querySelector("meta[name='csrf-token']").content
    const response = await fetch(this.previewUrlValue, { method: "POST", body: data, headers: { "X-CSRF-Token": token } })
    if (response.ok) this.previewTarget.textContent = await response.text()
  }
}
