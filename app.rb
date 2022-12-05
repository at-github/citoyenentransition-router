require 'bundler/setup'
require 'erb'
require 'yaml'

require_relative 'src/controllers/Controller'
require_relative 'src/renders/template/Render'
require_relative 'src/services/Content'
require_relative 'src/services/Server'
require_relative 'src/services/Translation'

# Checks
pwd  = File.dirname(File.expand_path(__FILE__))
abort 'You must create content folder'      if !File.directory? "#{pwd}/content"
abort 'You must create a "config.yml" file' if !File.exist? "#{pwd}/config.yml"

config = YAML.load_file("#{pwd}/config.yml")
abort 'You must create a "title" key in config.yml file,'\
  ' with a correct path' if !config.key? "title"
@title = config['title']

abort 'You must create a "content_folder" key in config.yml file,'\
  ' with a correct path' if !config.key? "content_folder"

content_folder = "#{pwd}/content/#{config['content_folder']}"
abort 'Wrong path for content_folder key'\
  ' in config.yml file' if !File.directory? content_folder

server = Server.new
translation = Translation.new(config['translations'])
content = Content.new(content_folder, translation)
@links = content.get_links()
render = Render.new(pwd, @title, @links)
controller = Controller.new(server, render, content)

STDOUT.puts 'Server started localhost:2345'
loop do
  path = server.request()
  controller.switch(path)
end
