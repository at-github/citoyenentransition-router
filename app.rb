require 'bundler/setup'
require 'socket'
require 'uri'
require 'cgi'
require 'redcarpet'

require_relative 'server'

# Files will be served from this directory
WEB_ROOT = './public'

# This helper function parses the Request-Line and
# generates a path to a file on the server.
# Takes a request line (e.g. "GET /path?foo=bar HTTP/1.1")
# and extracts the path from it, scrubbing out parameters
# and unescaping URI-encoding.
#
# This cleaned up path (e.g. "/path") is then converted into
# a relative path to a file in the server's public folder
# by joining it with the WEB_ROOT.
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

    # return the web root joined to the clean path
    File.join(WEB_ROOT, *clean)
  end

  File.join(WEB_ROOT, path)
end

myServer = Server.new
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})

# loop infinitely, processing one incoming
# connection at a time.
loop do
  # Wait until a client connects, then return a TCPSocket
  # that can be used in a similar fashion to other Ruby
  # I/O objects. (In fact, TCPSocket is a subclass of IO.)
  path = requested_file(myServer.request())

  # Make sure the file exists and is not a directory
  # before attempting to open it.
  if File.exist?(path + '.md'.to_s) && !File.directory?(path)
    path_md = path + '.md'
    file_md = File.open(path_md)
    file_data_md = file_md.read
    message = markdown.render(file_data_md)
    file_md.close
    myServer.respond(message, 200)
  else
    myServer.respond('<h1>Contenu introuvable</h1>', 404)
  end
end
