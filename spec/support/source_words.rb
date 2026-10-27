# frozen_string_literal: true

require "nokogiri"

# The words of a TEI <text> as transcribed, for checking that the EEBO
# parser keeps every word. The source is adjusted only as the approved
# parser decisions require (HTC-0016, HTC-0017, HTC-0018), so a difference
# means the parser lost, invented, or re-divided words.
module SourceWords
  EEBO = HistoricalTextConverter::Parsers::EEBO

  # Elements whose content the parser builds as running text.
  RUNNING_TEXT = (%w[p ab head l] + EEBO::BlockBuilder::ROLE_PARAGRAPHS.keys).freeze

  CLASSIFIER = EEBO::InlineBuilder.new(report: HistoricalTextConverter::ParseReport.new)

  def self.tally(xml)
    tei = Nokogiri::XML(xml)
    tei.remove_namespaces!
    text = tei.at_xpath("/TEI/text")
    adjust(text, tei)
    notes = lift_notes(text)
    words(([text.text] + notes).join(" "))
  end

  # Words the parser produced.
  def self.parsed(book)
    words(book.text)
  end

  # Line-end break glyphs are ignored on both sides: the parser adds them
  # for <g> elements (HTC-0015), and some sources contain them as text.
  def self.words(string)
    string.delete("∣¦").split.tally
  end

  def self.adjust(text, tei)
    replace = ->(node, string) { node.replace(Nokogiri::XML::Text.new(string, tei)) }
    text.xpath(".//gap[@reason='duplicate']").each { |gap| gap.remove if gap.previous_element&.name == "pb" }
    text.xpath(".//gap").each { |gap| replace.call(gap, gap.xpath("desc").text.strip) }
    text.xpath(".//choice[expan]").each do |choice|
      expan = choice.at_xpath("expan")
      replace.call(choice, (expan.at_xpath("ex") ? expan.xpath("ex") : expan).text.strip)
    end
    text.xpath(".//choice[sic]").each { |choice| replace.call(choice, choice.at_xpath("sic").text) }
    text.xpath(".//expan").each { |expan| replace.call(expan, (expan.at_xpath("ex") ? expan.xpath("ex") : expan).text.strip) }
    text.xpath(".//g[not(node())]").each do |glyph|
      replace.call(glyph, EEBO::GlyphTable.default.display(glyph["ref"]).to_s) unless glyph["ref"].to_s.include?("EOL")
    end
    text.xpath(".//lb").each { |lb| replace.call(lb, "\n") }
    text.xpath(".//*").each do |element|
      next unless block?(element)

      element.add_previous_sibling(Nokogiri::XML::Text.new(" ", tei))
      element.add_next_sibling(Nokogiri::XML::Text.new(" ", tei))
    end
  end

  # Whether the parser builds the element as a block, so its text is not
  # joined to the text around it (HTC-0018 D7, D9).
  def self.block?(element)
    return true if CLASSIFIER.block_element?(element)
    return false unless EEBO::BlockBuilder::BLOCK_LEVEL.include?(element.name)

    block_container?(element.parent)
  end

  def self.block_container?(node)
    return true if node.name == "text" && node.parent.name == "TEI"
    return true if node.name == "note"

    block?(node) && !RUNNING_TEXT.include?(node.name)
  end

  # The parser moves each note after the block that refers to it, so a
  # note's words are counted apart from the words around its anchor.
  # Inner notes are lifted first.
  def self.lift_notes(text)
    text.xpath(".//note").sort_by { |note| -note.ancestors.size }.map do |note|
      words = note.text
      note.remove
      words
    end
  end

  private_class_method :adjust, :block?, :block_container?, :lift_notes
end
