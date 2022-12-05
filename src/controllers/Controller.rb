require_relative './exceptions/StaticNotFoundException'

class Controller

  def initialize(root, server, render)
    @root = root
    @server = server
    @render = render
  end

  def set_query(path)
    @query = path
    self
  end

  def respond_static
    full_path = "#{@root}#{@query}"
    if !File.exist?(full_path)
      @server.respond_404(@render.render_404())
      raise StaticNotFoundException.new()
    end

    content_type = 'text/html'
    content_type = 'text/css' if /^\/public\/css.*$/.match?(@query)
    content_type = 'application/javascript' if /^\/public\/js.*$/.match?(@query)

    file = File.open(full_path)
    file_data = file.read
    @server.respond(file_data, 200, content_type)
  end
end
