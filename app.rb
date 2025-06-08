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
Dir[File.join(__dir__, 'routes/control', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'routes/medicos', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'routes/pacientes', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'routes/especialidades', '*.rb')].each { |file| require file }

FORMATO_FECHA = '%Y-%m-%d'.freeze
SEPARADOR_DE_HORA = ':'.freeze
FORMATO_HORA_OUTPUT = '%-H:%M'.freeze

configure do
  api_logger = Configuration.logger
  DB = Configuration.db # rubocop:disable  Lint/ConstantDefinitionInBlock
  DB.loggers << api_logger
  set :logger, api_logger
  set :default_content_type, :json
  set :environment, ENV['APP_MODE'].to_sym
  convertidor_de_tiempo_ = ConvertidorDeTiempo.new(FORMATO_FECHA, SEPARADOR_DE_HORA, FORMATO_HORA_OUTPUT)
  api_feriados = ENV['API_FERIADOS_URL']
  set :convertidor_de_tiempo, convertidor_de_tiempo_
  set :turnero, Turnero.new(RepositorioPacientes.new(api_logger),
                            RepositorioEspecialidades.new(api_logger),
                            RepositorioMedicos.new(api_logger),
                            RepositorioTurnos.new(api_logger),
                            ProveedorDeFeriados.new(api_feriados),
                            ProveedorDeFecha.new,
                            ProveedorDeHora.new,
                            convertidor_de_tiempo_)
  api_logger.info('Iniciando turnero...')
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

def convertidor_de_tiempo
  settings.send(:convertidor_de_tiempo)
end

register RoutesSystemControl
register RoutesPacientes
register RoutesEspecialidades
register RoutesMedicos
