import { Controller } from "@hotwired/stimulus"

// Small helpers shared by every table in the app:
// - click a header to sort, type in the filter box to hide rows that don't match;
// - tick rows with checkboxes, toolbar buttons are enabled only when something is ticked;
// - click a row to open it (no per-row buttons).
export default class extends Controller {
  static targets = ["body", "filter", "checkbox", "selectAll", "action"]

  connect() {
    this.updateActions()
  }

  sort(event) {
    const header = event.currentTarget
    const index = [...header.parentNode.children].indexOf(header)
    const ascending = header.dataset.dir !== "asc"
    header.parentNode.querySelectorAll("th").forEach((th) => delete th.dataset.dir)
    header.dataset.dir = ascending ? "asc" : "desc"

    const rows = [...this.bodyTarget.rows]
    rows.sort((a, b) => compare(cellValue(a, index), cellValue(b, index)) * (ascending ? 1 : -1))
    this.bodyTarget.append(...rows)
  }

  filter() {
    const text = this.filterTarget.value.toLowerCase()
    for (const row of this.bodyTarget.rows) {
      row.hidden = !row.textContent.toLowerCase().includes(text)
    }
  }

  toggleAll() {
    this.checkboxTargets.forEach((checkbox) => (checkbox.checked = this.selectAllTarget.checked))
    this.updateActions()
  }

  updateActions() {
    const anySelected = this.checkboxTargets.some((checkbox) => checkbox.checked)
    this.actionTargets.forEach((button) => (button.disabled = !anySelected))
  }

  open(event) {
    if (event.target.closest("input, a, label, button")) return
    const href = event.currentTarget.dataset.href
    if (href) window.Turbo.visit(href)
  }
}

function cellValue(row, index) {
  const cell = row.cells[index]
  return cell.dataset.value ?? cell.textContent.trim()
}

function compare(a, b) {
  const x = Number(a)
  const y = Number(b)
  if (a !== "" && b !== "" && !isNaN(x) && !isNaN(y)) return x - y
  return a.localeCompare(b)
}
