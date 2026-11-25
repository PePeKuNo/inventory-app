module DemoData
  module_function

  # Runs on every server start, so it only fills an empty database:
  # otherwise deleted demo data would come back after each restart.
  def seed!
    if Inventory.exists?
      puts "demo:seed skipped: inventories already exist"
      return
    end

    email = ENV["ADMIN_EMAIL"].to_s.strip.downcase
    owner = User.find_by("LOWER(email) = ?", email) || User.order(:id).first

    if owner.nil?
      puts "demo:seed skipped: no users"
      return
    end

    demo_inventories.each do |data|
      inventory = Inventory.find_or_initialize_by(title: data[:title])
      inventory.user ||= owner

      if inventory.new_record?
        inventory.category = Category.find_or_create_by!(name: data[:category])
        inventory.is_public = true
        inventory.custom_id_format = data[:format]
        assign_fields(inventory, data[:fields])
        inventory.save!
        puts "demo:seed created #{inventory.title}"
      else
        puts "demo:seed kept #{inventory.title}"
      end

      if inventory.items.none?
        data[:items].each { |attributes| inventory.items.create!(attributes.merge(user: owner)) }
        puts "demo:seed added items to #{inventory.title}"
      end

      inventory.update!(tag_list: data[:tags]) if inventory.tags.none?
      inventory.comments.create!(user: owner, body: data[:comment]) if inventory.comments.none?
    end

    puts "demo:seed done for #{owner.email}"
  end

  def assign_fields(inventory, fields)
    counters = Hash.new(0)

    fields.each_with_index do |(type, name, show_in_table), position|
      counters[type] += 1
      key = "custom_#{type}#{counters[type]}"
      inventory["#{key}_state"] = true
      inventory["#{key}_name"] = name
      inventory["#{key}_show_in_table"] = show_in_table
      inventory["#{key}_position"] = position
    end
  end

  def demo_inventories
    [
      {
        title: "Company Computers",
        category: "Equipment",
        format: [
          { "type" => "fixed", "format" => "COMP-2025-" },
          { "type" => "random32", "format" => "X8" },
          { "type" => "fixed", "format" => "-" },
          { "type" => "sequence", "format" => "D3" }
        ],
        fields: [
          [ "string", "Model", true ],
          [ "int", "Price", true ]
        ],
        tags: "office, computers",
        comment: "Company laptops and workstations. Try the custom ID preview and the table filters.",
        items: [
          { custom_string1: "Dell Latitude 5540", custom_int1: 1200 },
          { custom_string1: "HP EliteBook 840", custom_int1: 950 },
          { custom_string1: "Apple MacBook Air M3", custom_int1: 1300 }
        ]
      },
      {
        title: "Library",
        category: "Book",
        format: [
          { "type" => "fixed", "format" => "BOOK-" },
          { "type" => "sequence", "format" => "D4" }
        ],
        fields: [
          [ "string", "Title", true ],
          [ "string", "Authors", true ],
          [ "text", "Annotation", false ]
        ],
        tags: "books, library",
        comment: "Books from the office library. Ask the owner before taking one home.",
        items: [
          {
            custom_string1: "The Pragmatic Programmer",
            custom_string2: "Andrew Hunt, David Thomas",
            custom_text1: "A practical guide to software craftsmanship."
          },
          {
            custom_string1: "Clean Code",
            custom_string2: "Robert C. Martin",
            custom_text1: "Principles and practices for readable code."
          },
          {
            custom_string1: "Design Patterns",
            custom_string2: "Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides",
            custom_text1: "Reusable solutions for object-oriented design."
          }
        ]
      },
      {
        title: "Parts",
        category: "Equipment",
        format: [
          { "type" => "fixed", "format" => "PART-" },
          { "type" => "sequence", "format" => "D7" }
        ],
        fields: [
          [ "int", "Voltage", true ],
          [ "int", "Current", true ],
          [ "string", "Model", true ],
          [ "link", "Datasheet link", false ]
        ],
        tags: "electronics, parts",
        comment: "Spare electronic parts. Datasheets are linked in the item cards.",
        items: [
          {
            custom_int1: 5,
            custom_int2: 0.25,
            custom_string1: "R-10K",
            custom_link1: "https://example.com/datasheets/r-10k.pdf"
          },
          {
            custom_int1: 16,
            custom_int2: 0.5,
            custom_string1: "C-100",
            custom_link1: "https://example.com/datasheets/c-100.pdf"
          },
          {
            custom_int1: 100,
            custom_int2: 0.2,
            custom_string1: "D-4148",
            custom_link1: "https://example.com/datasheets/d-4148.pdf"
          }
        ]
      }
    ]
  end
end
