class ProveedorDeFeriados
  def initialize(api_feriados_url, logger)
    @api_feriados_url = api_feriados_url
    @logger = logger
  end

  def obtener_feriados(_anio)
    []
  end
end
