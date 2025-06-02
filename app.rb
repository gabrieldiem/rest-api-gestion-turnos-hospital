require 'sinatra'
require 'sinatra/json'
require 'sequel'
require 'sinatra/custom_logger'
require 'active_model'
require_relative './config/configuration'
require_relative './lib/version'
Dir[File.join(__dir__, 'dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'persistencia', '*.rb')].each { |file| require file }

configure do
  customer_logger = Configuration.logger
  DB = Configuration.db # rubocop:disable  Lint/ConstantDefinitionInBlock
  DB.loggers << customer_logger
  set :logger, customer_logger
  set :default_content_type, :json
  set :environment, ENV['APP_MODE'].to_sym
  set :turnero, Turnero.new(RepositorioPacientes.new, RepositorioEspecialidades.new, RepositorioMedicos.new)
  customer_logger.info('Iniciando turnero...')
end

before do
  if !request.body.nil? && request.body.size.positive?
    request.body.rewind
    @params = JSON.parse(request.body.read, symbolize_names: true)
  end
end

def turnero
  settings.send(:turnero)
end

get '/version' do
  logger.debug('GET /version')
  json({ version: Version.current })
end

post '/reset' do
  status 200
end

post '/pacientes' do
  logger.debug("POST /pacientes con params: #{@params}")
  paciente = turnero.crear_paciente(@params[:email].to_s, @params[:dni].to_s, @params[:username].to_s)
  status 201
  {
    id: paciente.id,
    username: paciente.username,
    dni: paciente.dni,
    email: paciente.email,
    created_on: paciente.created_on
  }.to_json
rescue ActiveModel::ValidationError => e
  logger.error("Error al crear paciente: #{e.message}")
  status 400
  { mensaje_error: e.model.errors.first.message }.to_json
end

post '/especialidades' do
  logger.debug("POST /especialidades con params: #{@params}")
  especialidad = turnero.crear_especialidad(@params[:nombre].to_s,
                                            @params[:duracion].to_i,
                                            @params[:recurrencia_maxima].to_i,
                                            @params[:codigo].to_s)

  status 201
  {
    id: especialidad.id,
    nombre: especialidad.nombre,
    duracion: especialidad.duracion,
    recurrencia_maxima: especialidad.recurrencia_maxima,
    codigo: especialidad.codigo,
    created_on: especialidad.created_on
  }.to_json
end

get '/medicos/:matricula/turnos-disponibles' do
  logger.debug("POST /medicos/#{params[:matricula]}/turnos-disponibles: #{@params}")
  medico = turnero.buscar_medico(params[:matricula])
  _turnos_disponibles = medico.obtener_turnos_disponibles
end

post '/medicos' do
  logger.debug("POST /medicos con params: #{@params}")
  medico = turnero.crear_medico(@params[:nombre].to_s,
                                @params[:apellido].to_s,
                                @params[:matricula].to_s,
                                @params[:especialidad].to_s)
  status 201
  {
    id: medico.id,
    nombre: medico.nombre,
    apellido: medico.apellido,
    matricula: medico.matricula,
    especialidad: medico.especialidad.codigo,
    created_on: medico.created_on
  }.to_json
end
