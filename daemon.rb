#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'daemons'

pwd  = File.dirname(File.expand_path(__FILE__))
file = pwd + '/app.rb'

Daemons.run_proc(
  'citoyenentransition',
  :log_output => true
) do
  exec "ruby #{file}"
end
