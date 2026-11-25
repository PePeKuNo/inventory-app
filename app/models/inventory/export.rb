# CSV export of all items, with the inventory's own field names as headers.
module Inventory::Export
  extend ActiveSupport::Concern

  def items_csv
    fields = custom_fields
    CSV.generate do |csv|
      csv << [ "ID", *fields.map(&:name), "Created by", "Created at" ]
      items.includes(:user).order(:created_at).each do |item|
        values = fields.map { |field| field.numeric? ? Inventory::CustomFields.display_number(item[field.key]) : item[field.key] }
        csv << [ item.custom_id, *values, item.user&.name, item.created_at ]
      end
    end
  end
end
