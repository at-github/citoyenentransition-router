require_relative './Controller'
require_relative './exceptions/StaticNotFoundException'

class HomeController < Controller

  def initialize(server, render, content)
    @server  = server
    @render  = render
    @content = content
  end

  def respond
    content_html = @content.get_list_titles_from_directories
    @server.respond @render.render_home content_html
  end
end
