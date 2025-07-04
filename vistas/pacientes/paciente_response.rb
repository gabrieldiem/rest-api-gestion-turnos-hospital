class PacienteResponse
  def initialize(paciente)
    @paciente = paciente
  end

  def to_json(*_args)
    {
      username: @paciente.username,
      dni: @paciente.dni,
      email: @paciente.email,
      reputacion: @paciente.reputacion
    }.to_json
  end
end
