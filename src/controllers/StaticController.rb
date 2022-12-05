require_relative './exceptions/StaticNotFoundException'

class StaticController

  def initialize(server, render, content)
    @root    = File.dirname(File.expand_path(__FILE__)) + '/../..'
    @server  = server
    @render  = render
    @content = content
  end

  def set_query(path)
    @query = path
    self
  end

  def respond
    full_path = "#{@root}#{@query}"
    if !File.exist?(full_path)
      @server.respond_404(@render.render_404())
      raise StaticNotFoundException.new()
    end

    content_type = 'text/html'
    content_type = 'text/css' if /^\/public\/css.*$/.match?(@query)
    content_type = 'application/javascript' if /^\/public\/js.*$/.match?(@query)

    @server.respond(
      @content.get_static_content(full_path),
      200,
      content_type
    )
  end
end
