require 'bundler/setup'
require 'redcarpet'
require 'erb'
require 'yaml'

require_relative 'server'
require_relative 'src/render/RenderOnlyTitle'

myServer = Server.new
markdown_content = Redcarpet::Markdown.new(
  Redcarpet::Render::HTML,
  extensions = {}
)
markdown_links = Redcarpet::Markdown.new(
  Redcarpet::Render::HTML.new(
    link_attributes: {target: '_blank'}
  ),
  extensions = {}
)

if !File.directory? 'content'
  abort 'You must create content folder'
end

content_folder = 'content/' + YAML.load_file('config.yml')['content_folder']
layout_template = ERB.new(File.read('src/templates/layout.erb'))

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
  markdownTitle = Redcarpet::Markdown.new(
    RenderOnlyTitle.new(slug),
    extensions = {}
  )
  content = ''
  list_md = Dir["#{folder_path}/*.md"]

  list_md.each do |md|
    md_file   = File.open(md)
    response  = md_file.read
    content +=  markdownTitle.render(response)
  end

  content
end

STDOUT.puts 'Server started'
# loop infinitely, processing one incoming
# connection at a time.
loop do
  # Wait until a client connects, then return a TCPSocket
  # that can be used in a similar fashion to other Ruby
  # I/O objects. (In fact, TCPSocket is a subclass of IO.)
  path = requested_file(myServer.request())

  # Home
  if /^\/$/.match?(path) == true
    home_template = ERB.new(File.read('src/templates/home.erb'))
    @posts = list_titles_from_directory(
      content_folder + '/posts',
      'posts'
    )
    @suggestions = list_titles_from_directory(
      content_folder + '/suggestions',
      'suggestions'
    )

    links_md_path = content_folder + '/links.md'
    links_md_file = File.open(links_md_path)
    links_content = links_md_file.read
    @links        = markdown_links.render(links_content)

    # Homemade inheritance
    @content = home_template.result_with_hash(
      posts: @posts,
      suggestions: @suggestions,
      links: @links
    )
    output = layout_template.result_with_hash(content: @content)
    myServer.respond(output)
    next
  end

  # Statics
  if (path.match? 'favicon.ico') || (/^\/public.*$/.match?(path) == true)
    if !File.exist?('.' + path)
      myServer.respond_404()
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

  markdown_path = "#{content_folder}#{path}"

  if File.directory?(markdown_path)
    # Force "/" on directory
    if (!/^.*\/$/.match?(markdown_path))
      slug = markdown_path.split('/')[-1]
      myServer.redirect("#{slug}/")
      next
    end

    @content = list_titles_from_directory(markdown_path, path.gsub('/', ''))
    output = layout_template.result_with_hash(content: @content)
    myServer.respond(output, 200)
  else
    md_path_file = "#{markdown_path}.md"

    if !File.exist?(md_path_file)
      myServer.respond_404()
      next
    end

    md_file = File.open(md_path_file)
    response = md_file.read

    @content = markdown_content.render(response)
    output = layout_template.result_with_hash(content: @content)
    myServer.respond(output, 200)
  end
end
