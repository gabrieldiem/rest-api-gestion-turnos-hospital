class NuevoTurnoReservadoResponse
  def initialize(turno)
    @turno = turno
  end

  def to_json(*_args)
    horario = @turno.horario
    {
      id: @turno.id,
      matricula: @turno.medico.matricula,
      dni: @turno.paciente.dni,
      turno: {
        fecha: horario.fecha.to_s,
        hora: convertir_hora(horario.hora)
      },
      created_at: @turno.created_on.to_s
    }.to_json
  end

  private

  def convertir_hora(hora)
    "#{hora.hora}:#{hora.minutos.to_s.rjust(2, '0')}"
  end
end
