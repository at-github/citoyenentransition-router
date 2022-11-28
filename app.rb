require 'bundler/setup'
require 'redcarpet'
require 'erb'
require "yaml"

require_relative 'server'

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

  File.join(WEB_ROOT, path)
end

myServer = Server.new
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})

STDOUT.puts 'Server started'

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
      myServer.respond_404()
      next
    end

    content_type = 'text/html'
    content_type = 'text/css' if /^\/public\/css.*$/.match?(path)
    content_type = 'application/javascript' if /^\/public\/js.*$/.match?(path)

    file = File.open('.' + path)
    file_data = file.read
    myServer.respond(file_data, 200, content_type)
  else
    content_folder = YAML.load_file('config.yml')['content_folder']
    md_path_file = "content/#{content_folder}#{path}.md"

    if !File.exist?(md_path_file)
      myServer.respond_404()
      next
    end

    md_file = File.open(md_path_file)
    response = md_file.read

    @content = markdown.render(response)
    template = ERB.new(File.read('layout.erb'))
    output = template.result_with_hash(content: @content)
    myServer.respond(output, 200)
  end
end
