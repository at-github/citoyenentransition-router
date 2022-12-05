require_relative './exceptions/StaticNotFoundException'

class HomeController

  def initialize(server, render, content)
    @server  = server
    @render  = render
    @content = content
  end

  def set_query(path)
    @query = path
    self
  end

  def respond(path)
    content_html = @content.get_list_titles_from_directories()
    @server.respond(@render.render_home(content_html))
  end
end
