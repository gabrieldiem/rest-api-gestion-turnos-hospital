class SinTurnosException < StandardError
  def initialize(msg = 'El paciente no tiene turnos reservados')
    super
  end
end
