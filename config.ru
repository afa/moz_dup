require 'bundler/setup'
Bundler.require(:default)

require './boot'

use Rack::Reloader
use Rack::Runtime
use Rack::ShowExceptions if ENV['RACK_ENV'].nil? || ENV['RACK_ENV'] == 'development'

# map '/l' do
#   run LinkManager
# end

# # map '/c' do
# #   run CitateManager
# # end

# map '/b' do
#   run BlogManager
# end

map '/' do
  run AppManager
end
