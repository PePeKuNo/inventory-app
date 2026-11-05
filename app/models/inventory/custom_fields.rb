# Each inventory has fixed field "slots": 3 of each type (custom_string1..3, custom_int1..3, ...).
# A slot is used when its *_state is true; *_name, *_description, *_show_in_table and
# *_position describe how the field looks. Items store the values in the same-named columns.
module Inventory::CustomFields
  extend ActiveSupport::Concern

  TYPES = %w[string text int link bool].freeze
  SLOTS = TYPES.flat_map { |type| (1..3).map { |n| "custom_#{type}#{n}" } }.freeze
  SETTINGS = %w[state name description show_in_table position].freeze

  Field = Data.define(:key, :type, :name, :description, :show_in_table, :position) do
    def numeric? = type == "int"
  end

  included do
    validate :enabled_fields_have_names
  end

  class_methods do
    def field_setting_columns
      SLOTS.flat_map { |slot| SETTINGS.map { |setting| "#{slot}_#{setting}" } }
    end
  end

  # All slots (used or not), ordered for the "Fields" tab.
  def field_slots
    SLOTS.map { |key| build_field(key) }.sort_by(&:position)
  end

  # Only the fields the owner turned on, in the owner's order.
  def custom_fields
    field_slots.select { |field| self["#{field.key}_state"] }
  end

  def table_fields
    custom_fields.select(&:show_in_table)
  end

  private
    def build_field(key)
      Field.new(
        key:,
        type: key[/\Acustom_([a-z]+)\d\z/, 1],
        name: self["#{key}_name"],
        description: self["#{key}_description"],
        show_in_table: self["#{key}_show_in_table"],
        position: self["#{key}_position"]
      )
    end

    def enabled_fields_have_names
      custom_fields.each do |field|
        errors.add(:base, :field_name_missing) if field.name.blank?
      end
    end
end
