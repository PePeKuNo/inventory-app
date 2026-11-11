import { Controller } from "@hotwired/stimulus"

// Autosave for the inventory forms (Settings, Custom ID, Fields).
// We don't send every keystroke: the form is marked "dirty" on change and saved every few seconds.
// The form carries lock_version; the server answers with the new one (we keep it for the next save)
// or with 409 Conflict if somebody else saved the inventory first.
export default class extends Controller {
  static values = { interval: { type: Number, default: 8000 }, messages: Object }

  connect() {
    this.dirty = false
    this.timer = setInterval(() => this.save(), this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
    if (this.dirty) this.save({ keepalive: true }) // leaving the tab: don't lose the last changes
  }

  markDirty() {
    if (this.conflict) return
    this.dirty = true
    this.showStatus("unsaved", "text-bg-warning")
  }

  submit(event) {
    event.preventDefault()
    this.markDirty()
    this.save()
  }

  async save({ keepalive = false } = {}) {
    if (!this.dirty || this.saving || this.conflict) return
    this.dirty = false
    this.saving = true
    this.showStatus("saving", "text-bg-light border")

    try {
      const response = await fetch(this.element.action, {
        method: "POST", // the form has a hidden _method=patch field
        body: new FormData(this.element),
        headers: { Accept: "application/json" },
        keepalive
      })
      const data = await response.json()

      if (response.ok) {
        this.lockVersionField.value = data.lock_version
        this.showStatus("saved", "text-bg-success")
      } else if (response.status === 409) {
        this.conflict = true
        this.showStatus("conflict", "text-bg-danger")
        alert(data.error)
      } else {
        this.showStatus("error", "text-bg-danger", data.error)
      }
    } catch {
      this.dirty = true // network problem: try again on the next tick
      this.showStatus("error", "text-bg-danger")
    } finally {
      this.saving = false
    }
  }

  get lockVersionField() {
    return this.element.querySelector("[name='inventory[lock_version]']")
  }

  showStatus(key, classes, details) {
    const badge = document.getElementById("save-status")
    if (!badge) return
    badge.className = `badge rounded-pill ${classes}`
    badge.textContent = details ? `${this.messagesValue[key]}: ${details}` : this.messagesValue[key]
  }
}
