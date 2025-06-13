require 'sinatra'
require 'sinatra/json'
require 'sequel'
require 'sinatra/custom_logger'
require 'active_model'
require 'dotenv/load'
require_relative './config/configuration'
require_relative './lib/version'
require_relative './lib/proveedor_de_fecha'
require_relative './lib/proveedor_de_hora'
require_relative './lib/proveedor_de_feriados'
require_relative './lib/convertidor_de_tiempo'

Dir[File.join(__dir__, 'dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'persistencia', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'routes', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'routes/medicos', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'routes/pacientes', '*.rb')].each { |file| require file }

FORMATO_FECHA = '%Y-%m-%d'.freeze
SEPARADOR_DE_HORA = ':'.freeze
FORMATO_HORA_OUTPUT = '%-H:%M'.freeze

configure do
  api_logger = Configuration.logger
  DB = Configuration.db # rubocop:disable  Lint/ConstantDefinitionInBlock
  DB.loggers << api_logger
  set :logger, api_logger
  set :default_content_type, :json
  set :views, File.join(__dir__, 'vistas')
  set :environment, ENV['APP_MODE'].to_sym
  set :stage, ENV['STAGE']
  convertidor_de_tiempo_ = ConvertidorDeTiempo.new(FORMATO_FECHA, SEPARADOR_DE_HORA, FORMATO_HORA_OUTPUT)
  api_feriados = ENV['API_FERIADOS_URL']
  set :convertidor_de_tiempo, convertidor_de_tiempo_
  repositorios = RepositoriosTurnero.new(RepositorioPacientes.new(api_logger),
                                         RepositorioEspecialidades.new(api_logger),
                                         RepositorioMedicos.new(api_logger),
                                         RepositorioTurnos.new(api_logger))
  set :turnero, Turnero.new(repositorios,
                            ProveedorDeFeriados.new(api_feriados, api_logger),
                            ProveedorDeFecha.new,
                            ProveedorDeHora.new,
                            convertidor_de_tiempo_)
  api_logger.info('Iniciando turnero...')
end

def habilitar_cors(response)
  response.headers['Access-Control-Allow-Origin'] = '*'
  response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization'
end

before do
  habilitar_cors(response)

  if !request.body.nil? && request.body.size.positive?
    request.body.rewind
    @params = JSON.parse(request.body.read, symbolize_names: true)
  end
end

options '*' do
  habilitar_cors(response)
  200
end

def turnero
  settings.send(:turnero)
end

def convertidor_de_tiempo
  settings.send(:convertidor_de_tiempo)
end

def stage
  settings.send(:stage)
end

register RoutesSystemControl
register RoutesPacientes
register RoutesEspecialidades
register RoutesMedicos
register RoutesTurnos
register RoutesSwagger
