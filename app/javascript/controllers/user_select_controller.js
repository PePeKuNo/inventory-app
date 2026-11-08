import { Controller } from "@hotwired/stimulus"

// Picks a user by name or email with autocomplete (Tom Select + /users.json).
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.select = new window.TomSelect(this.element, {
      valueField: "id",
      labelField: "name",
      searchField: ["name", "email"],
      load: (query, callback) => {
        fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, { headers: { Accept: "application/json" } })
          .then((response) => response.json())
          .then(callback)
          .catch(() => callback())
      },
      render: {
        option: (user, escape) => `<div>${escape(user.name)} <small class="text-body-secondary">${escape(user.email)}</small></div>`
      }
    })
  }

  disconnect() {
    this.select.destroy()
  }
}
