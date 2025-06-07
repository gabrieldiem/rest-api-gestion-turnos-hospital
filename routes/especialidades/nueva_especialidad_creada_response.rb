class NuevaEspecialidadCreadaResponse
  def initialize(especialidad)
    @especialidad = especialidad
  end

  def to_json(*_args)
    {
      id: @especialidad.id,
      nombre: @especialidad.nombre,
      duracion: @especialidad.duracion,
      recurrencia_maxima: @especialidad.recurrencia_maxima,
      codigo: @especialidad.codigo,
      created_on: @especialidad.created_on
    }.to_json
  end
end
