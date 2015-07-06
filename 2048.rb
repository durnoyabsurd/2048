$:.unshift(File.dirname(__FILE__))

require 'bundler'
require 'game'

Bundler.require(:default)
Game.new.start
