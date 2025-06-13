module RoutesSwagger
  def self.registered(app)
    app.get '/openapi.json' do
      status 200
      send_file File.join(__dir__, '../openapi.json')
    end

    app.get '/swagger' do
      content_type 'text/html'
      status 200
      erb :swagger
    end
  end
end
