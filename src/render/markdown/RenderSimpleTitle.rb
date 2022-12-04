class RenderSimpleTitle < Redcarpet::Render::Base
  def header(text, _)
    return text
  end

  def paragraph(text)
    nil
  end
end
