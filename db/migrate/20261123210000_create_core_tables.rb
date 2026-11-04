class CreateCoreTables < ActiveRecord::Migration[8.1]
  # Custom fields are stored in fixed "slots": up to 3 fields of each type.
  # The inventory keeps the slot settings, the item keeps the slot values.
  FIELD_TYPES = {
    string: :string,
    text: :text,
    int: :decimal,
    link: :string,
    bool: :boolean
  }.freeze

  def change
    create_table :categories do |t|
      t.string :name, null: false, index: { unique: true }
    end

    create_table :inventories do |t|
      t.string :title, null: false
      t.text :description
      t.string :image_url
      t.references :user, null: false, foreign_key: true
      t.references :category, foreign_key: true
      t.boolean :is_public, null: false, default: false
      t.jsonb :custom_id_format, null: false, default: []
      t.integer :lock_version, null: false, default: 0

      FIELD_TYPES.each_key do |type|
        (1..3).each do |n|
          prefix = "custom_#{type}#{n}"
          t.boolean "#{prefix}_state", null: false, default: false
          t.string "#{prefix}_name"
          t.string "#{prefix}_description"
          t.boolean "#{prefix}_show_in_table", null: false, default: false
          t.integer "#{prefix}_position", null: false, default: 0
        end
      end

      t.timestamps
    end

    create_table :items do |t|
      t.references :inventory, null: false, foreign_key: true
      # Items stay in the inventory when their author is deleted.
      t.references :user, foreign_key: { on_delete: :nullify }
      t.string :custom_id, null: false
      t.integer :sequence_number
      t.integer :likes_count, null: false, default: 0
      t.integer :lock_version, null: false, default: 0

      FIELD_TYPES.each do |type, column_type|
        (1..3).each { |n| t.column "custom_#{type}#{n}", column_type }
      end

      t.timestamps
    end
    add_index :items, [ :inventory_id, :custom_id ], unique: true

    create_table :accesses do |t|
      t.references :inventory, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :accesses, [ :inventory_id, :user_id ], unique: true

    create_table :tags do |t|
      t.string :name, null: false, index: { unique: true }
    end

    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :inventory, null: false, foreign_key: true
    end
    add_index :taggings, [ :inventory_id, :tag_id ], unique: true

    create_table :comments do |t|
      t.references :inventory, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end

    create_table :likes do |t|
      t.references :item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :likes, [ :item_id, :user_id ], unique: true
  end
end
