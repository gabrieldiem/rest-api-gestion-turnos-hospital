class ActualizacionDeTurnoResponse
  def initialize(turno, convertidor_de_tiempo)
    @turno = turno
    @convertidor_de_tiempo = convertidor_de_tiempo
  end

  def to_json(*_args)
    {
      fecha: presentar_fecha,
      hora: presentar_hora,
      duracion: @turno.medico.especialidad.duracion.to_i,
      estado: @turno.estado.descripcion.to_s,
      medico: convertir_medico(@turno.medico)
    }.to_json
  end

  private

  def presentar_fecha
    @convertidor_de_tiempo.presentar_fecha(@turno.horario.fecha)
  end

  def presentar_hora
    @convertidor_de_tiempo.presentar_hora(@turno.horario.hora)
  end

  def convertir_medico(medico)
    {
      nombre: medico.nombre.to_s,
      apellido: medico.apellido.to_s,
      matricula: medico.matricula.to_s,
      especialidad: medico.especialidad.codigo.to_s
    }
  end
end
