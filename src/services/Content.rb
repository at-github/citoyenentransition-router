require 'redcarpet'
require_relative '../renders/markdown/RenderSimpleTitle'
require_relative './exceptions/MardownNotFoundException'

class Content
  def initialize(content_folder, translation)
    @content_folder = content_folder
    @markdown_links = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        link_attributes: {target: '_blank'}
      ),
      extensions = {}
    )
    @markdownSimpleTitle = Redcarpet::Markdown.new(RenderSimpleTitle.new())
    @translation = translation
  end

  def slug_directory?(path)
    translated_slug = @translation.translate_slug(path)
    File.directory?("#{@content_folder}#{translated_slug}")
  end

  def get_static_content(path)
    File.open(path).read
  end

  def get_title_from_file(path)
    translated_slug = @translation.translate_slug(path)

    path = "#{@content_folder}#{translated_slug}.md" if ! /.*\.md$/.match? path

    if !File.exist?(path)
      raise MardownNotFoundException.new()
    end

    md_file = File.open(path)
    response = md_file.read

    @markdownSimpleTitle.render(response)
  end

  def get_links()
    links_md_path = @content_folder + '/links.md'
    links_md_file = File.open(links_md_path)
    links_content = links_md_file.read
    @markdown_links.render(links_content)
  end

  def get_page(path)
    translated_path = "#{@translation.translate_slug(path)}"
    path = "#{@content_folder}#{translated_path}.md"

    if !File.exist?(path)
      raise MardownNotFoundException.new()
    end

    md_file = File.open(path)
    response = md_file.read

    markdown_content = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(hard_wrap: true),
      extensions = {tables: true}
    )
    markdown_content.render(response)
  end

  def get_list_titles_from_directory(folder_path)
    translated_folder_path = @translation.translate_slug(folder_path)
    content = ''

    slug = @translation.untranslate_slug(translated_folder_path)
    list_md = Dir["#{@content_folder}/#{translated_folder_path}/*.md"]
    list_md.each do |md|
      text = get_title_from_file(md)
      content += "<h3>
        <a href=\"#{slug}#{text.gsub(' ', '-').downcase}\">
          #{text}
        </a>
      </h3>"
    end

    content
  end

  def get_list_titles_from_directories()
    content_html = []

    root = Dir["#{@content_folder}/*"]
    root.each do |item|
      next if !File.directory? item

      folder = item.split('/')[-1]
      slug = "/#{folder}/"
      content_html << Hash[
        'name' => @translation.untranslate(folder),
        'content' => get_list_titles_from_directory(slug)
      ]
    end

    content_html
  end
end
