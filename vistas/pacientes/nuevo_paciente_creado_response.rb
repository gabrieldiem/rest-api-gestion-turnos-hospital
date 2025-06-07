class NuevoPacienteCreadoResponse
  def initialize(paciente)
    @paciente = paciente
  end

  def to_json(*_args)
    {
      id: @paciente.id,
      username: @paciente.username,
      dni: @paciente.dni,
      email: @paciente.email,
      created_on: @paciente.created_on
    }.to_json
  end
end
