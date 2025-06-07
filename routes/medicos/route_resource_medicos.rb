Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/medicos', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/error', '*.rb')].each { |file| require file }

module RoutesResourceMedicos
  def self.registered(app)
    get_medicos(app)
    post_medicos(app)
  end

  def self.get_medicos(app)
    app.get '/medicos' do
      logger.debug('GET /medicos')

      medicos = turnero.obtener_medicos

      status 200
      TodosMedicosResponse.new(medicos).to_json
    end
  end

  def self.post_medicos(app)
    app.post '/medicos' do
      logger.debug("POST /medicos con params: #{@params}")
      medico = turnero.crear_medico(@params[:nombre].to_s,
                                    @params[:apellido].to_s,
                                    @params[:matricula].to_s,
                                    @params[:especialidad].to_s)
      status 201
      NuevoMedicoCreadoResponse.new(medico).to_json
    end
  end
end
