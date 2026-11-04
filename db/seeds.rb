# Categories are managed directly in the database (no UI needed).
%w[Equipment Furniture Book Other].each { |name| Category.find_or_create_by!(name:) }
