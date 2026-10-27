# frozen_string_literal: true

# Builds small Books for transformation specs.
module DocumentHelper
  def text(value, **metadata)
    HistoricalTextConverter::Document::Text.new(value, metadata: metadata)
  end

  def gap(desc)
    text(desc, artifact: :gap, gap: true, reason: "illegible")
  end

  def paragraph(*children, **metadata)
    HistoricalTextConverter::Document::Paragraph.new(children: children, metadata: metadata)
  end

  def book(*blocks)
    HistoricalTextConverter::Document::Book.new(body: HistoricalTextConverter::Document::Section.new(kind: :body, children: blocks))
  end

  # Applies the described transformation with the default configuration,
  # or with the given transformations: settings.
  def transform(book, settings = nil, context: transformation_context(settings))
    described_class.new.apply(book, context)
  end

  def transformation_context(settings = nil)
    configuration = HistoricalTextConverter::Configuration.new
    configuration = instance_double(HistoricalTextConverter::Configuration, transformations: settings) if settings
    HistoricalTextConverter::Transformations::Context.new(configuration: configuration)
  end
end
