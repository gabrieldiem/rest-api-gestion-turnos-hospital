class FechaInvalidaException < StandardError
  def initialize(msg = 'El formato de fecha es inválido')
    super
  end
end
