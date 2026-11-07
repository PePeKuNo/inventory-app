import { Controller } from "@hotwired/stimulus"

// Tag input (Tom Select). While typing, existing tags starting with the text are loaded from the server.
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.select = new window.TomSelect(this.element, {
      create: true,
      persist: false,
      delimiter: ",",
      createFilter: (input) => input.trim().length > 0,
      load: (query, callback) => {
        fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
          .then((response) => response.json())
          .then((names) => callback(names.map((name) => ({ value: name, text: name }))))
          .catch(() => callback())
      }
    })
  }

  disconnect() {
    this.select.destroy()
  }
}
