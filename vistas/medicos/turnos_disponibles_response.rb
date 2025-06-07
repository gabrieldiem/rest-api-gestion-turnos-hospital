class TurnosDisponiblesResponse
  def initialize(medico, turnos_disponibles)
    @medico = medico
    @turnos_disponibles = turnos_disponibles
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
        fecha: turno.fecha.to_s,
        hora: "#{turno.hora.hora}:#{turno.hora.minutos.to_s.rjust(2, '0')}"
      }
    end
  end
end
