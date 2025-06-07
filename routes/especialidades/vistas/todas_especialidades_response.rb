class TodasEspecialidadesResponse
  def initialize(especialidades)
    @especialidades = especialidades
  end

  def to_json(*_args)
    {
      cantidad_total: @especialidades.size,
      especialidades: @especialidades.map do |especialidad|
        {
          id: especialidad.id,
          nombre: especialidad.nombre,
          duracion: especialidad.duracion,
          recurrencia_maxima: especialidad.recurrencia_maxima,
          codigo: especialidad.codigo,
          created_on: especialidad.created_on
        }
      end
    }.to_json
  end
end
