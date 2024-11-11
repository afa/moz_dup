require 'zeitwerk'
require 'sinatra/cookies'
require 'yaml'
require 'logger'
require 'sequel'
require_relative 'app'
App.logger = Logger.new('log/processing.log', 'monthly')
App.logger.level = Logger::INFO
App.logger.info('App start')

begin
  App.config = YAML.load_file('config.yml') || {}
rescue Exception => e
  App.logger.error("config not loaded with #{e.message}")
  raise
end

begin
  db_url = ENV['DATABASE_URL'] || App.config['db'] || 'postgres://localhost/app'
  App.db = Sequel.connect(db_url)
  App.db.extension :pg_json
rescue Exception => e
  App.logger.error("db not connected with #{e.message}")
  raise
end

begin
  App.ext_db ||= {}
  App.config.fetch('ext_db', {}).each do |k, v|
    App.ext_db[k.to_sym] = Sequel.connect(v)
  end
rescue Exception => e
  App.logger.error("ext_db not connected with #{e.message}")
  raise
end
# db_url = File.open('./config/database.yml', 'r') { |f| YAML.safe_load(ERB.new(f.read).result) }
loader = Zeitwerk::Loader.new
Dir['./app/*'].each { |p| loader.push_dir(p) }
loader.setup
