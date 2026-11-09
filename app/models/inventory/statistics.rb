# Aggregates for the "Stats" tab.
module Inventory::Statistics
  extend ActiveSupport::Concern

  def statistics
    all = items.to_a
    stats = { "items_count" => all.size }

    custom_fields.each do |field|
      values = all.map { |item| item[field.key] }

      case field.type
      when "int"
        numbers = values.compact.map(&:to_f)
        stats["#{field.key}_min"] = numbers.min
        stats["#{field.key}_max"] = numbers.max
        stats["#{field.key}_avg"] = numbers.any? ? numbers.sum / numbers.size : nil
      when "bool"
        stats["#{field.key}_true"] = values.count(true)
      else
        # the most frequent value
        stats["#{field.key}_mode"] = values.compact.tally.max_by { |_, count| count }&.first
      end
    end

    stats
  end
end
