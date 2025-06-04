class TurnoNoDisponibleException < StandardError
  def initialize(msg = 'Este turno no está disponible')
    super
  end
end
