class RenderSimpleTitle < Redcarpet::Render::Base
  @cache = nil

  def header(text, level)
    return text if level == 1
  end

  def paragraph(text)
    nil
  end
end
