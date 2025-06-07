class NuevoMedicoCreadoResponse
  def initialize(medico)
    @medico = medico
  end

  def to_json(*_args)
    {
      id: @medico.id,
      nombre: @medico.nombre,
      apellido: @medico.apellido,
      matricula: @medico.matricula,
      especialidad: @medico.especialidad.codigo,
      created_on: @medico.created_on
    }.to_json
  end
end
