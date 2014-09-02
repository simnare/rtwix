require "gettext/po"
require "gettext/po_parser"
require "gettext/po_entry"

module Rtwix extend self
  def extract
    abort "See usage with `help`" unless ARGV.count == 2

    source, destination = ARGV
    Dir.exist? source or abort "Source directory is not accessible"

    po = if File.exists? destination then
      GetText::POParser.new.parse_file destination, GetText::PO.new
    else
      GetText::PO.new
    end

    gather_files(source).each do |file|
      gather_keywords(file).each do |keyword|
        if po.has_key? keyword
          next
        end

        po[keyword] = ""
      end
    end

    File.write destination, po.to_s
  end

  def gather_files(source)
    Dir.glob("#{source}/**/*.twig")
  end

  def gather_keywords(file)
    return [] unless File.readable? file
    hits = []

    File.open(file).each do |line|
      line.scan(/translate\((['"].*?['"])\)/).each do |keyword|
        keyword = keyword.first
        next unless valid_keyword? keyword
        hits.push unquote(keyword)
      end
    end

    return hits
  end

  # only keywords from global domain are accepted atm
  def valid_keyword?(keyword)
    quotes = quote_style keyword

    invalid = keyword =~ /,\s+#{quotes}\w+#{quotes}$/
    puts "Invalid keyword found: #{keyword}" if invalid

    return !invalid
  end

  def parse_keyword(raw)
    quotes = quote_style raw
    return raw
  end

  def quote_style(keyword)
    return keyword.start_with?("'") ? "'" : "\'"
  end

  def unquote(message)
    quotes = quote_style message

    message = message.chomp(quotes).reverse.chomp(quotes).reverse
    # remove escaping backslashes
    message.gsub /\\#{quotes}/, quotes
  end

end
