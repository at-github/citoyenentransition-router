require_relative './Controller'
require_relative './exceptions/StaticNotFoundException'

class ArchiveController < Controller

  def initialize(server, render, content)
    super server, render, content
  end

  def respond
    # Force "/" on directory
    if (!/^.*\/$/.match?(@query))
      @server.redirect "#{@query}/"
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
