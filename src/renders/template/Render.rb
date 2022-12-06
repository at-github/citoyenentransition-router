class Render
  def initialize(root, title, links, footer)
    @title = title.capitalize
    @links = links
    @github, @twitter = footer.values_at('github', 'twitter')

    @layout_template    = ERB.new File.read "#{root}/src/templates/layout.erb"
    @home_template      = ERB.new File.read "#{root}/src/templates/home.erb"
    @archive_template   = ERB.new File.read "#{root}/src/templates/archive.erb"
    @page_template      = ERB.new File.read "#{root}/src/templates/page.erb"
    @not_found_template = ERB.new File.read "#{root}/src/templates/not_found.erb"
  end

  def render(content, title = nil)
    final_title = title ? "#{title.capitalize} - #{@title}" : @title

    @layout_template.result_with_hash(
      content: content,
      title: final_title,
      links: @links,
      github: @github,
      twitter: @twitter
    )
  end

  def render_home(content)
    return render @home_template.result_with_hash content: content
  end

  def render_archive(content, title)
    title = title.gsub '/', ''
    return render @archive_template.result_with_hash(
      content: content,
      title: title
    ), title
  end

  def render_page(content, title, slug)
    category = /^\/(?<category>.*)\/.*$/.match(slug)['category']

    return render @page_template.result_with_hash(
      content: content,
      category: category
    ), title

  end

  def render_404
    return render @not_found_template.result
  end
end
