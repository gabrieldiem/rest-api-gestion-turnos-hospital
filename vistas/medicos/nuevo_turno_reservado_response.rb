class NuevoTurnoReservadoResponse
  def initialize(turno, convertidor_de_tiempo)
    @turno = turno
    @convertidor_de_tiempo = convertidor_de_tiempo
  end

  def to_json(*_args)
    horario = @turno.horario
    {
      id: @turno.id,
      matricula: @turno.medico.matricula,
      dni: @turno.paciente.dni,
      turno: {
        fecha: @convertidor_de_tiempo.presentar_fecha(horario.fecha),
        hora: @convertidor_de_tiempo.presentar_hora(horario.hora)
      },
      created_at: @turno.created_on.to_s
    }.to_json
  end
end
