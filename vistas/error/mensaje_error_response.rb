class MensajeErrorResponse
  def initialize(mensaje)
    @mensaje = mensaje
  end

  def to_json(*_args)
    {
      mensaje_error: @mensaje
    }.to_json
  end
end
