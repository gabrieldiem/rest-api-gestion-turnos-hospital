class TurnoInvalidoException < StandardError
  def initialize(msg = 'El turno que se quiere reservar no es valido')
    super
  end
end
