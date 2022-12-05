require_relative '../controllers/StaticController'
require_relative '../controllers/HomeController'
require_relative '../controllers/ArchiveController'
require_relative '../controllers/PageController'
require_relative '../controllers/exceptions/StaticNotFoundException'

class Dispatcher

  def initialize(
    server,
    render,
    content
  )
    @server  = server
    @render  = render
    @content = content
  end

  def dispatch(path)
    # Statics
    if /^\/public.*$/.match?(path) == true
      begin
        staticController = StaticController.new(
          @server,
          @render,
          @content
        )
        staticController.set_query(path).respond
        return
      rescue StaticNotFoundException
        return
      end
    end

    # Home
    if /^\/$/.match?(path) == true
      homeController = HomeController.new(
        @server,
        @render,
        @content
      )
      homeController.set_query(path).respond(path)
      return
    end

    # Archive
    if @content.slug_directory?(path)
      archiveController = ArchiveController.new(
        @server,
        @render,
        @content
      )
      archiveController.set_query(path).respond(path)
      return
    end

    # Page
    pageController = PageController.new(
      @server,
      @render,
      @content
    )
    pageController.set_query(path).respond(path)
  end
end
