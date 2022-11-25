require 'bundler/setup'
require 'socket'
require 'uri'
require 'cgi'
require 'redcarpet'
require 'net/http'

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

  if (path.match? 'favicon.ico') || (/^\/public.*/.match?(path) == true)
    if !File.exist?('.' + path)
      myServer.respond_404()
      next
    end

    file = File.open('.' + path)
    file_data = file.read
    myServer.respond(file_data, 200)
  else
    uri      = URI(base_url + path + '.md')
    response = Net::HTTP.get_response(uri)

    if response.code.to_i < 400
      message = markdown.render(response.body)
      myServer.respond(message, response.code)
    else
      myServer.respond_404()
    end
  end
end
