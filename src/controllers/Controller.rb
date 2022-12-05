require_relative './exceptions/StaticNotFoundException'

class Controller

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

  def switch(path)
    # Statics
    if /^\/public.*$/.match?(path) == true
      begin
        set_query(path).respond_static
        return
      rescue StaticNotFoundException
        return
      end
    end

    # Home
    if /^\/$/.match?(path) == true
      set_query(path).respond_home
      return
    end

    # Archive
    if @content.slug_directory?(path)
      set_query(path).respond_archive(path)
      return
    end

    # Page
    set_query(path).respond_page(path)
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

  def respond_archive(path)
    # Force "/" on directory
    if (!/^.*\/$/.match?(path))
      @server.redirect("#{@query}/")
      return
    end

    @server.respond(
      @render.render_archive(
        @content.get_list_titles_from_directory(path),
        @query
      )
    )
  end

  def respond_page(path)
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
