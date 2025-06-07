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
          hora: "#{turno.horario.hora.hora}:#{turno.horario.hora.minutos.to_s.rjust(2, '0')}",
          paciente: {
            dni: turno.paciente.dni.to_s
          }
        }
      end
    }.to_json
  end
end
