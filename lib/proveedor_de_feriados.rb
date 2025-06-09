require 'faraday'
require_relative './exceptions/no_se_pueden_obtener_feriados_exception'

class ProveedorDeFeriados
  def initialize(api_feriados_url, logger)
    @api_feriados_url = api_feriados_url
    @logger = logger
  end

  def obtener_feriados(anio)
    final_url = "#{@api_feriados_url}/#{anio}"
    response = ejecutar_request_para_obtener_feriados(final_url)

    case response.status
    when 200
      response_body = obtener_response_body(response)
      @logger.info("Response 2XX OK de #{final_url} es: #{response_body}")
      crear_feriados(response_body)
    else
      @logger.error("Response errónea de #{final_url} es: #{response.inspect}")
      raise NoSePuedenObtenerFeriadosException
    end
  end

  private

  def crear_feriados(_response_body)
    []
  end

  def ejecutar_request_para_obtener_feriados(final_url)
    @logger.info("Haciendo GET request a #{final_url}")

    Faraday.get(final_url)
  end

  def obtener_response_body(response)
    JSON.parse(response.body)
  end
end
