class RecurrenciaMaximaAlcanzadaException < StandardError
  def initialize(msg = 'No puede reservar más turnos para esta especialidad')
    super
  end
end
