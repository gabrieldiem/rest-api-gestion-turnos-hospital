class TurnosReservadosResponse
  def initialize(turnos)
    @turnos = turnos
  end

  def to_json(*_args)
    {
      cantidad_turnos: @turnos.size,
      turnos: @turnos.map do |turno|
        {
          fecha: turno.horario.fecha.to_s,
          hora: convertir_hora(turno.horario.hora),
          paciente: {
            dni: turno.paciente.dni.to_s
          }
        }
      end
    }.to_json
  end

  private

  def convertir_hora(hora)
    "#{hora.hora}:#{hora.minutos.to_s.rjust(2, '0')}"
  end
end
