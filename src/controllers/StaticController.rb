require_relative './Controller'
require_relative './exceptions/StaticNotFoundException'

class StaticController < Controller

  def initialize(server, render, content)
    super server, render, content
    @root    = File.dirname(File.expand_path(__FILE__)) + '/../..'
  end

  def respond
    full_path = "#{@root}#{@query}"
    if !File.exist? full_path
      @server.respond_404 @render.render_404
      raise StaticNotFoundException.new
    end

    content_type = 'text/html'
    content_type = 'text/css' if /^\/public\/css.*$/.match? @query
    content_type = 'application/javascript' if /^\/public\/js.*$/.match? @query
    content_type = 'image/png' if /^\/public\/img\/.*\.png$/.match? @query

    @server.respond(
      @content.get_static_content(full_path),
      200,
      content_type
    )
  end
end
