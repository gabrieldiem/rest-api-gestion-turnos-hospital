module RoutesSwagger
  def self.registered(app)
    get_openapi_json(app)
    get_swagger_ui(app)
  end

  def self.get_openapi_json(app)
    app.get '/openapi.json' do
      status 200
      send_file File.join(__dir__, '../openapi.json')
    end
  end

  def self.get_swagger_ui(app)
    app.get '/swagger' do
      content_type 'text/html'
      status 200
      erb :swagger
    end
  end
end
