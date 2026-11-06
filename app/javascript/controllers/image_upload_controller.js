import { Controller } from "@hotwired/stimulus"

// Uploads the image straight from the browser to Cloudinary (their widget supports drag-and-drop).
// Our server never receives the file, it only stores the resulting URL.
export default class extends Controller {
  static targets = ["input", "preview"]
  static values = { cloudName: String, preset: String }

  open() {
    window.cloudinary.openUploadWidget(
      { cloudName: this.cloudNameValue, uploadPreset: this.presetValue, sources: ["local", "url"], multiple: false, clientAllowedFormats: ["image"] },
      (error, result) => {
        if (!error && result.event === "success") this.setUrl(result.info.secure_url)
      }
    )
  }

  clear() {
    this.setUrl("")
  }

  setUrl(url) {
    this.inputTarget.value = url
    this.previewTarget.src = url
    this.previewTarget.hidden = !url
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true })) // tells autosave
  }
}
