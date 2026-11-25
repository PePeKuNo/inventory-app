# Full-text search through a GIN index instead of scanning the tables.
# Postgres keeps the tsvector columns up to date by itself (generated columns),
# pg_search reads them via the tsvector_column option.
class AddSearchVectors < ActiveRecord::Migration[8.1]
  def change
    add_column :inventories, :searchable, :virtual, type: :tsvector, stored: true, as: <<~SQL.squish
      setweight(to_tsvector('simple', coalesce(title, '')), 'A') ||
      setweight(to_tsvector('simple', coalesce(description, '')), 'B')
    SQL
    add_index :inventories, :searchable, using: :gin

    item_columns = %w[custom_id custom_string1 custom_string2 custom_string3 custom_text1 custom_text2 custom_text3]
    add_column :items, :searchable, :virtual, type: :tsvector, stored: true,
      as: "to_tsvector('simple', #{item_columns.map { |column| "coalesce(#{column}, '')" }.join(" || ' ' || ")})"
    add_index :items, :searchable, using: :gin
  end
end
