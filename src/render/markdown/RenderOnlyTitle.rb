class RenderOnlyTitle < Redcarpet::Render::Base
  def initialize(slug)
    super()
    @slug = slug
  end

  def header(text, header_level)
    %(<h#{header_level}>
        <a href="/#{@slug}/#{text.gsub(' ', '-').downcase}">
          #{text}
        </a>
      </h#{header_level}>
    )
  end

  def paragraph(text)
    nil
  end
end
