require_relative './exceptions/StaticNotFoundException'

class Controller

  def initialize(root, server, render, content)
    @root    = root
    @server  = server
    @render  = render
    @content = content
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

    @server.respond(
      @content.get_static_content(full_path),
      200,
      content_type
    )
  end

  def respond_home
    content_html = @content.get_list_titles_from_directories()
    @server.respond(@render.render_home(content_html))
  end

  def respond_archive(content_path)
    # Force "/" on directory
    if (!/^.*\/$/.match?(content_path))
      @server.redirect("#{@query}/")
      return
    end

    content_html = @content.get_list_titles_from_directory(
      content_path,
      @query
    )

    @server.respond(
      @render.render_archive(
        content_html,
        @query
      )
    )
  end

  def respond_page(content_path)
    begin
      content_html = @content.get_page(content_path)

      @server.respond(
        @render.render_page(
          content_html,
          @content.get_title_from_file(content_path),
          @query
        )
      )
    rescue MardownNotFoundException
      @server.respond_404(@render.render_404())
    end
  end
end
