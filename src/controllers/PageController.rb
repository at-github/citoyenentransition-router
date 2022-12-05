require_relative './exceptions/StaticNotFoundException'

class PageController

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
    begin
      content_html = @content.get_page(path)

      @server.respond(
        @render.render_page(
          content_html,
          @content.get_title_from_file(path),
          @query
        )
      )
    rescue MardownNotFoundException
      @server.respond_404(@render.render_404())
    end
  end
end
