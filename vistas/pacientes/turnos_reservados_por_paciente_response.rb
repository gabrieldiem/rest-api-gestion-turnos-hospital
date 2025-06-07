class TurnosReservadosPorPacienteResponse
  def initialize(turnos)
    @turnos = turnos
  end

  def to_json(*_args)
    {
      cantidad_de_turnos: @turnos.size,
      turnos: @turnos.map do |turno|
        {
          fecha: turno.horario.fecha.to_s,
          hora: convertir_hora(turno.horario.hora),
          medico: convertir_medico(turno.medico)
        }
      end
    }.to_json
  end

  private

  def convertir_medico(medico)
    {
      nombre: medico.nombre.to_s,
      apellido: medico.apellido.to_s,
      matricula: medico.matricula.to_s,
      especialidad: medico.especialidad.codigo.to_s
    }
  end

  def convertir_hora(hora)
    "#{hora.hora}:#{hora.minutos.to_s.rjust(2, '0')}"
  end
end
