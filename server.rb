class Server
  def initialize(port = 2345)
    @server = TCPServer.new('localhost', port)
  end

  def request()
    @socket = @server.accept
    request_line = @socket.gets
    request_uri = request_line.split(" ")[1]
    CGI.unescape(URI(request_uri).path)
  end

  def respond(content, http_code)
    http_status_message = {
      404 => 'Not found'
    }

    @socket.print "HTTP/1.1 #{http_code} \
                 #{http_status_message.fetch(http_code, 'OK')}\r\n" +
                 "Content-Type: text/html; charset=UTF-8\r\n" +
                 "Content-Length: #{content.size}\r\n" +
                 "Connection: close\r\n"
    @socket.print "\r\n"

    @socket.print content
    @socket.close
  end

  def respond_404()
    respond('<h1>Contenu introuvable</h1>', 404)
  end
end
