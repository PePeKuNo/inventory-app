# Builds custom inventory numbers from a list of elements, e.g.
#   [{ "type" => "fixed", "format" => "BOOK-" }, { "type" => "sequence", "format" => "D4" }]
#   => "BOOK-0001"
#
# Number formats: "D" decimal, "X" hex, optional width for leading zeros ("D4", "X5"),
# anything after that is literal text ("D3_" => "007_").
# Date formats: yyyy yy MM dd ddd HH mm ss, anything else is literal text.
module CustomId
  TYPES = %w[fixed random20 random32 random6 random9 guid datetime sequence].freeze
  MAX_ELEMENTS = 10

  RANDOM_LIMITS = { "random20" => 2**20, "random32" => 2**32, "random6" => 10**6, "random9" => 10**9 }.freeze
  DEFAULT_WIDTH = { "random6" => 6, "random9" => 9 }.freeze

  DATE_TOKENS = {
    "yyyy" => [ "%Y", '\d{4}' ],
    "yy" => [ "%y", '\d{2}' ],
    "MM" => [ "%m", '\d{2}' ],
    "ddd" => [ "%a", "[A-Za-z]{3}" ],
    "dd" => [ "%d", '\d{2}' ],
    "HH" => [ "%H", '\d{2}' ],
    "mm" => [ "%M", '\d{2}' ],
    "ss" => [ "%S", '\d{2}' ]
  }.freeze
  DATE_TOKEN_REGEXP = Regexp.union(DATE_TOKENS.keys) # longer tokens are listed first

  NUMBER_FORMAT = /\A([DX])?(\d*)(.*)\z/m

  module_function

  def generate(elements, sequence:, time: Time.current)
    elements.map { |element| render(element, sequence:, time:) }.join
  end

  # A regexp that every ID built from these elements matches.
  def regexp(elements)
    /\A#{elements.map { |element| pattern(element) }.join}\z/
  end

  def render(element, sequence:, time:)
    format = element["format"].to_s
    case element["type"]
    when "fixed" then format
    when "guid" then SecureRandom.uuid
    when "datetime" then format_date(time, format)
    when "sequence" then format_number(sequence, format, "sequence")
    else format_number(SecureRandom.random_number(RANDOM_LIMITS.fetch(element["type"])), format, element["type"])
    end
  end

  def pattern(element)
    format = element["format"].to_s
    case element["type"]
    when "fixed" then Regexp.escape(format)
    when "guid" then '\h{8}-\h{4}-\h{4}-\h{4}-\h{12}'
    when "datetime" then format.gsub(/#{DATE_TOKEN_REGEXP}|./m) { |part| DATE_TOKENS[part]&.last || Regexp.escape(part) }
    else number_pattern(format, element["type"])
    end
  end

  def format_number(value, format, type)
    base, width, suffix = parse_number_format(format, type)
    digits = base == "X" ? value.to_s(16).upcase : value.to_s
    digits.rjust(width, "0") + suffix
  end

  def number_pattern(format, type)
    base, width, suffix = parse_number_format(format, type)
    chars = base == "X" ? "[0-9A-F]" : '\d'
    count = width.positive? ? "{#{width},}" : "+"
    "#{chars}#{count}#{Regexp.escape(suffix)}"
  end

  def parse_number_format(format, type)
    base, width, suffix = format.match(NUMBER_FORMAT).captures
    [ base || "D", width.presence&.to_i || DEFAULT_WIDTH.fetch(type, 0), suffix ]
  end

  def format_date(time, format)
    format.gsub(/#{DATE_TOKEN_REGEXP}|./m) { |part| DATE_TOKENS[part] ? time.strftime(DATE_TOKENS[part].first) : part }
  end
end
