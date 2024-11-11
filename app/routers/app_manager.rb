class AppManager < Sinatra::Base
  helpers Sinatra::Cookies
  get '/' do
    "who is you are? what do you need for?"
  end
end
