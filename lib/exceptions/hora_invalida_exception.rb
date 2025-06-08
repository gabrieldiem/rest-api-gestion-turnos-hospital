class HoraInvalidaException < StandardError
  def initialize(msg = 'El formato de la hora es inválida')
    super
  end
end
