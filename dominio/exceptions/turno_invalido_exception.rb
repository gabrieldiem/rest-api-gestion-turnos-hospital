class TurnoInvalidoException < StandardError
  def initialize(msg = 'El turno que se quiere reservar no es un turno válido para la especialidad')
    super
  end
end
