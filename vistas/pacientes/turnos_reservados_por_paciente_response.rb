class TurnosReservadosPorPacienteResponse
  def initialize(turnos, convertidor_de_tiempo)
    @turnos = turnos
    @convertidor_de_tiempo = convertidor_de_tiempo
  end

  def to_json(*_args)
    {
      cantidad_de_turnos: @turnos.size,
      turnos: @turnos.map do |turno|
        {
          id: turno.id.to_s,
          estado: turno.estado.descripcion,
          fecha: @convertidor_de_tiempo.presentar_fecha(turno.horario.fecha),
          hora: @convertidor_de_tiempo.presentar_hora(turno.horario.hora),
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
end
