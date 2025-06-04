class FueraDeHorarioException < StandardError
  def initialize(msg = 'No se puede reservar en ese horario, el horario de atención es de 8:00 a 18:00')
    super
  end
end
