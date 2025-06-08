class TurnosDisponiblesResponse
  def initialize(medico, turnos_disponibles, convertidor_de_tiempo)
    @medico = medico
    @turnos_disponibles = turnos_disponibles
    @convertidor_de_tiempo = convertidor_de_tiempo
  end

  def to_json(*_args)
    {
      medico: {
        nombre: @medico.nombre,
        apellido: @medico.apellido,
        matricula: @medico.matricula,
        especialidad: @medico.especialidad.codigo
      },
      turnos: parsear_turnos
    }.to_json
  end

  private

  def parsear_turnos
    @turnos_disponibles.map do |turno|
      {
        fecha: @convertidor_de_tiempo.presentar_fecha(turno.fecha),
        hora: @convertidor_de_tiempo.presentar_hora(turno.hora)
      }
    end
  end
end
