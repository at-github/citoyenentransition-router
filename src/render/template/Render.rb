class Render
  def initialize(title, links)
    @title = title
    @links = links

    @layout_template    = ERB.new(File.read('src/templates/layout.erb'))
    @home_template      = ERB.new(File.read('src/templates/home.erb'))
    @archive_template   = ERB.new(File.read('src/templates/archive.erb'))
    @page_template      = ERB.new(File.read('src/templates/archive.erb'))
    @not_found_template = ERB.new(File.read('src/templates/not_found.erb'))
  end

  def render(content)
    @layout_template.result_with_hash(
      content: content,
      title: @title,
      links: @links
    )
  end

  def render_home(content)
    return render(@home_template.result_with_hash(
        content: content
    ))
  end

  def render_archive(content)
    return render(@archive_template.result_with_hash(
        content: content
    ))
  end

  def render_page(content)
    return render(@page_template.result_with_hash(
        content: content
    ))
  end

  def render_404()
    return render(@not_found_template.result())
  end
end
