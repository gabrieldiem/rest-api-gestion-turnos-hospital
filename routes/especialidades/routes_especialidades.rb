Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, './', '*.rb')].each { |file| require file }

module RoutesEspecialidades
  def self.registered(app)
    get_especialidades(app)
    post_especialidades(app)
  end

  def self.get_especialidades(app)
    app.get '/especialidades' do
      logger.debug('GET /especialidades')
      especialidades = turnero.obtener_especialidades

      status 200
      TodasEspecialidadesResponse.new(especialidades).to_json
    end
  end

  def self.post_especialidades(app)
    app.post '/especialidades' do
      logger.debug("POST /especialidades con params: #{@params}")
      especialidad = turnero.crear_especialidad(@params[:nombre].to_s,
                                                @params[:duracion].to_i,
                                                @params[:recurrencia_maxima].to_i,
                                                @params[:codigo].to_s)

      status 201
      NuevaEspecialidadCreadaResponse.new(especialidad).to_json
    end
  end
end
