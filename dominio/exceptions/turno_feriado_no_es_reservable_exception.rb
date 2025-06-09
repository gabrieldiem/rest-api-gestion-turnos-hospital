class TurnoFeriadoNoEsReservableException < StandardError
  def initialize(msg = 'La reserva de turno no puede realizarse porque es un día feriado')
    super
  end
end
