root = ::File.dirname(__FILE__)
require ::File.join( root, 'web' )
require './env' if File.exists?('env.rb')
run Gamification.new