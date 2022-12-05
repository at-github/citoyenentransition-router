require 'net/http'

class Server
  def initialize(port = 2345)
    @server = TCPServer.new('localhost', port)
  end

  def request
    @socket = @server.accept
    request_line = @socket.gets
    request_uri = request_line.split(" ")[1]
    CGI.unescape URI(request_uri).path
  end

  def respond(
    content,
    http_code = 200,
    content_type = 'text/html'
  )
    http_status_message = {
      404 => 'Not found'
    }

    @socket.print "HTTP/1.1 #{http_code} \
                 #{http_status_message.fetch http_code, 'OK'}\r\n" +
                 "Content-Type: #{content_type}; charset=UTF-8\r\n" +
                 "Connection: close\r\n"
    @socket.print "\r\n"

    @socket.print content
    @socket.close
  end

  def redirect(url)
    @socket.print "HTTP/1.1 302 \
                 OK\r\n" +
                 "Content-Type: text/html; charset=UTF-8\r\n" +
                 "Location: #{url}\r\n" +
                 "Connection: close\r\n"
    @socket.print "\r\n"
    @socket.close
  end

  def respond_404(message)
    respond message, 404
  end
end
