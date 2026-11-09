class Inventory < ApplicationRecord
  include CustomFields, Statistics, PgSearch::Model

  belongs_to :user
  belongs_to :category, optional: true
  has_many :items, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :accesses, dependent: :destroy
  has_many :writers, through: :accesses, source: :user
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  validates :title, presence: true
  validate :custom_id_format_is_valid

  pg_search_scope :search,
    against: { title: "A", description: "B" },
    associated_against: { tags: :name },
    using: { tsearch: { prefix: true } }

  scope :latest, -> { order(created_at: :desc) }
  scope :most_popular, -> {
    left_joins(:items).group(:id).select("inventories.*, COUNT(items.id) AS items_count").order("items_count DESC")
  }

  # Owner and admins can change the inventory itself (settings, fields, access).
  def editable_by?(user)
    user.present? && (user.admin? || user_id == user.id)
  end

  # Writers can add, edit and delete items.
  def writable_by?(user)
    return false if user.nil?

    editable_by?(user) || is_public? || accesses.exists?(user_id: user.id)
  end

  def tag_list
    tags.map(&:name).join(",")
  end

  def tag_list=(value)
    names = value.to_s.split(",").map { |name| name.strip.downcase }.compact_blank.uniq
    self.tags = names.map { |name| Tag.find_or_create_by!(name:) }
  end

  # Keeps only known keys, so the stored format is always a clean list.
  def custom_id_format=(elements)
    list = elements.respond_to?(:values) ? elements.values : Array(elements)
    super(list.filter_map do |element|
      next unless element.respond_to?(:to_h)

      element.to_h.stringify_keys.slice("type", "format")
    end)
  end

  def generate_custom_id(sequence)
    return sequence.to_s if custom_id_format.empty?

    CustomId.generate(custom_id_format, sequence:)
  end

  def custom_id_regexp
    CustomId.regexp(custom_id_format) if custom_id_format.any?
  end

  private
    def custom_id_format_is_valid
      if custom_id_format.size > CustomId::MAX_ELEMENTS ||
          custom_id_format.any? { |element| CustomId::TYPES.exclude?(element["type"]) }
        errors.add(:custom_id_format, :invalid)
      end
    end
end
