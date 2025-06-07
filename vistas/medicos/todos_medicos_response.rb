class TodosMedicosResponse
  def initialize(medicos)
    @medicos = medicos
  end

  def to_json(*_args)
    {
      cantidad_total: @medicos.size,
      medicos: @medicos.map do |medico|
        {
          id: medico.id,
          nombre: medico.nombre,
          apellido: medico.apellido,
          matricula: medico.matricula,
          especialidad: medico.especialidad.nombre,
          created_on: medico.created_on
        }
      end
    }.to_json
  end
end
