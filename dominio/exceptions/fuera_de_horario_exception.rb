class FueraDeHorarioException < StandardError
  def initialize(msg = 'El turno no puede ser asignado despues de las 18:00')
    super
  end
end
