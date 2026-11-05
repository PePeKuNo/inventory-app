module ApplicationHelper
  MARKDOWN = Redcarpet::Markdown.new(
    Redcarpet::Render::HTML.new(filter_html: true, safe_links_only: true, hard_wrap: true),
    autolink: true, tables: true, fenced_code_blocks: true, strikethrough: true
  )

  # User text is rendered as Markdown; raw HTML is stripped, then sanitized once more.
  def markdown(text)
    tag.div(sanitize(MARKDOWN.render(text.to_s)), class: "markdown")
  end

  # Value of a custom field as shown in tables and on the item page.
  def field_value(item, field)
    value = item[field.key]
    case field.type
    when "bool" then tag.i(class: value ? "bi bi-check-square" : "bi bi-square")
    when "link" then value.present? ? link_to(value.truncate(40), value, target: "_blank", rel: "noopener") : nil
    when "int" then value&.to_s&.delete_suffix(".0")
    else value.to_s.truncate(80)
    end
  end

  # Form control for a custom field (checkboxes are rendered separately).
  def field_input(form, field)
    case field.type
    when "text" then form.text_area field.key, rows: 4, class: "form-control"
    when "int" then form.number_field field.key, step: "any", class: "form-control"
    when "link" then form.url_field field.key, class: "form-control", placeholder: "https://"
    else form.text_field field.key, class: "form-control"
    end
  end

  def field_type_label(type)
    t("fields.types.#{type}")
  end
end
