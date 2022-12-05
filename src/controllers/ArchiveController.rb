require_relative './exceptions/StaticNotFoundException'

class ArchiveController

  def initialize(server, render, content)
    @server  = server
    @render  = render
    @content = content
  end

  def set_query(path)
    @query = path
    self
  end

  def respond
    # Force "/" on directory
    if (!/^.*\/$/.match?(@query))
      @server.redirect("#{@query}/")
      return
    end

    @server.respond(
      @render.render_archive(
        @content.get_list_titles_from_directory(@query),
        @query
      )
    )
  end
end
