# CSV export of all items, with the inventory's own field names as headers.
module Inventory::Export
  extend ActiveSupport::Concern

  def items_csv
    fields = custom_fields
    CSV.generate do |csv|
      csv << [ "ID", *fields.map(&:name), "Created by", "Created at" ]
      items.includes(:user).order(:created_at).each do |item|
        csv << [ item.custom_id, *fields.map { |field| item[field.key] }, item.user&.name, item.created_at ]
      end
    end
  end
end
