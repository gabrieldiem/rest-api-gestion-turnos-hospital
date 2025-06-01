require 'sinatra'
require 'sinatra/json'
require 'sequel'
require 'sinatra/custom_logger'
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
  set :turnero, Turnero.new(RepositorioUsuarios.new, RepositorioEspecialidades.new)
  customer_logger.info('Iniciando turnero...')
end

before do
  if !request.body.nil? && request.body.size.positive?
    request.body.rewind
    @params = JSON.parse(request.body.read, symbolize_names: true)
  end
end

def turnero
  settings.turnero
end

get '/version' do
  logger.debug('Handling /version')
  json({ version: Version.current })
end

post '/reset' do
  status 200
end

get '/usuarios' do
  usuarios = turnero.usuarios
  respuesta = []
  usuarios.map { |u| respuesta << { email: u.email, id: u.id } }
  status 200
  json(respuesta)
end

post '/usuarios' do
  logger.debug("POST /usuarios: #{@params}")
  usuario = turnero.crear_usuario(@params['email'])
  status 201
  { id: usuario.id, email: usuario.email }.to_json
end

post '/especialidades' do
  logger.debug("POST /especialidades: #{@params}")
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

post '/medicos' do
  logger.debug("POST /medicos: #{@params}")
  status 201
end
