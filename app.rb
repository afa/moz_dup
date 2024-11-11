class App
  class << self
    attr_accessor :config, :db, :logger, :ext_db
  end
  def call(_env)
    [200, {'Content-Type' => 'text/html'}, ['Rack!']]
  end
end
