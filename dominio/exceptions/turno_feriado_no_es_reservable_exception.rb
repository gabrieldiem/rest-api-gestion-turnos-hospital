class TurnoFeriadoNoEsReservableException < StandardError
  def initialize(msg = 'No se puede reservar un turno para un día feriado')
    super
  end
end
