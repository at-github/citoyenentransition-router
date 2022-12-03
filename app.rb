require 'bundler/setup'
require 'redcarpet'
require 'erb'
require 'yaml'

require_relative 'src/services/Server'
require_relative 'src/services/Translation'
require_relative 'src/render/markdown/RenderOnlyTitle'
require_relative 'src/render/template/Render'

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

# This helper function parses the Request-Line and
# generates a path to a file on the server.
# Takes a request line (e.g. "GET /path?foo=bar HTTP/1.1")
# and extracts the path from it, scrubbing out parameters
# and unescaping URI-encoding.
#
# This cleaned up path (e.g. "/path") is then converted into
# a relative path to a file in the server's
def requested_file(request)
  clean = []

  # Split the path into components
  parts = request.split("/")

  parts.each do |part|
    # skip any empty or current directory (".") path components
    next if part.empty? || part == '.'
    # If the path component goes up one directory level (".."),
    # remove the last clean component.
    # Otherwise, add the component to the Array of clean components
    part == '..' ? clean.pop : clean << part
  end

  request
end

def list_titles_from_directory(folder_path, slug)
  markdownTitle = Redcarpet::Markdown.new(RenderOnlyTitle.new(slug))
  content = ''
  list_md = Dir["#{folder_path}/*.md"]

  list_md.each do |md|
    md_file   = File.open(md)
    response  = md_file.read
    content +=  markdownTitle.render(response)
  end

  content
end

myServer = Server.new
markdown_content = Redcarpet::Markdown.new(
  Redcarpet::Render::HTML,
  extensions = {tables: true}
)
markdown_links = Redcarpet::Markdown.new(
  Redcarpet::Render::HTML.new(
    link_attributes: {target: '_blank'}
  ),
  extensions = {}
)

links_md_path = content_folder + '/links.md'
links_md_file = File.open(links_md_path)
links_content = links_md_file.read
@links        = markdown_links.render(links_content)

translation = Translation.new(config['translations'])
render = Render.new(@title, @links)

STDOUT.puts 'Server started localhost:2345'
# loop infinitely, processing one incoming
# connection at a time.
loop do
  # Wait until a client connects, then return a TCPSocket
  # that can be used in a similar fashion to other Ruby
  # I/O objects. (In fact, TCPSocket is a subclass of IO.)
  path = requested_file(myServer.request())

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
    home_template = ERB.new(File.read('src/templates/home.erb'))
    content = []

    root = Dir["#{content_folder}/*"]
    root.each do |item|
      folder = item.split('/')[-1]
      content << Hash[
        'name' => translation.untranslate(folder),
        'content' => list_titles_from_directory(
          item,
          translation.untranslate(folder)
        )
      ] if File.directory? item
    end

    myServer.respond(render.render_home(content))
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

    content = list_titles_from_directory(markdown_path, path.gsub('/', ''))
    myServer.respond(render.render_archive(content))
  # Page
  else
    md_path_file = "#{markdown_path}.md"

    if !File.exist?(md_path_file)
      myServer.respond_404(render.render_404())
      next
    end

    md_file = File.open(md_path_file)
    response = md_file.read

    content = markdown_content.render(response)
    myServer.respond(render.render_page(content))
  end
end
