# Aggregates for the "Stats" tab, computed by the database in one query.
module Inventory::Statistics
  extend ActiveSupport::Concern

  def statistics
    fields = custom_fields
    selects = [ "COUNT(*) AS items_count" ]
    fields.each do |field|
      column = Item.connection.quote_column_name(field.key)
      case field.type
      when "int"
        selects << "MIN(#{column}) AS #{field.key}_min" << "MAX(#{column}) AS #{field.key}_max" << "AVG(#{column}) AS #{field.key}_avg"
      when "bool"
        selects << "COUNT(*) FILTER (WHERE #{column}) AS #{field.key}_true"
      else
        # mode() is the most frequent value
        selects << "mode() WITHIN GROUP (ORDER BY #{column}) AS #{field.key}_mode"
      end
    end
    items.unscope(:order).select(selects.join(", ")).take.attributes
  end
end
