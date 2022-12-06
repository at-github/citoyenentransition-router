require_relative './Controller'
require_relative './exceptions/StaticNotFoundException'

class PageController < Controller

  def initialize(server, render, content)
    super server, render, content
  end

  def respond
    begin
      content_html = @content.get_page @query

      @server.respond(
        @render.render_page(
          content_html,
          @content.get_title_from_file(@query),
          @query
        )
      )
    rescue MardownNotFoundException
      @server.respond_404 @render.render_404
    end
  end
end
