require 'bundler/setup'
require 'erb'
require 'yaml'

require_relative 'src/controllers/Controller'
require_relative 'src/renders/template/Render'
require_relative 'src/services/Content'
require_relative 'src/services/Server'
require_relative 'src/services/Translation'

# Checks
pwd  = File.dirname(File.expand_path(__FILE__))
abort 'You must create content folder'      if !File.directory? "#{pwd}/content"
abort 'You must create a "config.yml" file' if !File.exist? "#{pwd}/config.yml"

config = YAML.load_file("#{pwd}/config.yml")
abort 'You must create a "title" key in config.yml file,'\
  ' with a correct path' if !config.key? "title"
@title = config['title']

abort 'You must create a "content_folder" key in config.yml file,'\
  ' with a correct path' if !config.key? "content_folder"

content_folder = "#{pwd}/content/#{config['content_folder']}"
abort 'Wrong path for content_folder key'\
  ' in config.yml file' if !File.directory? content_folder

server = Server.new
translation = Translation.new(config['translations'])
content = Content.new(content_folder, translation)
@links = content.get_links()
render = Render.new(pwd, @title, @links)
controller = Controller.new(pwd, server, render)

STDOUT.puts 'Server started localhost:2345'
loop do
  path = server.request()

  # Statics
  if /^\/public.*$/.match?(path) == true
    begin
      controller.set_query(path).respond_static
      next
    rescue StaticNotFoundException
      next
    end
  end

  # Home
  if /^\/$/.match?(path) == true
    content_html = content.get_list_titles_from_directories()
    server.respond(render.render_home(content_html))
    next
  end

  # Translate slug if needed
  content_path = "#{content_folder}#{translation.translate_slug(path)}"

  # Archive
  if File.directory?(content_path)
    # Force "/" on directory
    if (!/^.*\/$/.match?(content_path))
      server.redirect("#{path}/")
      next
    end

    content_html = content.get_list_titles_from_directory(
      content_path,
      path
    )

    server.respond(
      render.render_archive(
        content_html,
        path
      )
    )
    next
  end

  # Page
  begin
    content_html = content.get_page(content_path)
  rescue MardownNotFoundException
    server.respond_404(render.render_404())
    next
  end

  server.respond(
    render.render_page(
      content_html,
      content.get_title_from_file(content_path),
      path
    )
  )
end
