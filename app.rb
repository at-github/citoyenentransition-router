require 'bundler/setup'
require 'erb'
require 'yaml'

require_relative 'src/services/Server'
require_relative 'src/services/Translation'
require_relative 'src/render/template/Render'
require_relative 'src/services/Content'

# Checks
abort 'You must create content folder'      if !File.directory? 'content'
abort 'You must create a "config.yml" file' if !File.exist? 'config.yml'

config = YAML.load_file('config.yml')
abort 'You must create a "title" key in config.yml file,'\
  ' with a correct path' if !config.key? "title"
@title = config['title']

abort 'You must create a "content_folder" key in config.yml file,'\
  ' with a correct path' if !config.key? "content_folder"

content_folder = 'content/' + config['content_folder']
abort 'Wrong path for content_folder key'\
  ' in config.yml file' if !File.directory? content_folder

myServer = Server.new
translation = Translation.new(config['translations'])
content = Content.new(content_folder, translation)
@links = content.get_links()
render = Render.new(@title, @links)

STDOUT.puts 'Server started localhost:2345'
loop do
  path = myServer.request()

  # Statics
  if (path.match? 'favicon.ico') || (/^\/public.*$/.match?(path) == true)
    if !File.exist?('.' + path)
      myServer.respond_404(render.render_404())
      next
    end

    content_type = 'text/html'
    content_type = 'text/css' if /^\/public\/css.*$/.match?(path)
    content_type = 'application/javascript' if /^\/public\/js.*$/.match?(path)

    file = File.open('.' + path)
    file_data = file.read
    myServer.respond(file_data, 200, content_type)
    next
  end

  # Home
  if /^\/$/.match?(path) == true
    content_html = content.get_list_titles_from_directories()
    myServer.respond(render.render_home(content_html))
    next
  end

  markdown_path = "#{content_folder}#{translation.translate_slug(path)}"

  # Archive
  if File.directory?(markdown_path)
    # Force "/" on directory
    if (!/^.*\/$/.match?(markdown_path))
      myServer.redirect("#{path}/")
      next
    end

    slug = path.gsub('/', '')
    content_html = content.get_list_titles_from_directory(
      markdown_path,
      slug
    )

    myServer.respond(
      render.render_archive(
        content_html,
        slug
      )
    )
  # Page
  else
    md_path_file = "#{markdown_path}.md"

    begin
      content_html = content.get_page(md_path_file)
    rescue MardownNotFoundException
      myServer.respond_404(render.render_404())
      next
    end

    myServer.respond(
      render.render_page(
        content_html,
        content.get_title(md_path_file),
        path
      )
    )
  end
end
