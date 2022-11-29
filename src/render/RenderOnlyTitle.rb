class RenderOnlyTitle < Redcarpet::Render::HTML
  def header(text, header_level)
    %(<h#{header_level}>
        <a href="./#{text.gsub(' ', '-').downcase}">
          #{text}
        </a>
      </h#{header_level}>
    )
  end

  def paragraph(text)
    nil
  end
end
