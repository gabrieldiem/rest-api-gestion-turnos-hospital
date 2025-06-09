class PacienteInvalidoException < StandardError
  def initialize(msg = 'El paciente con DNI no está asociado a este turno')
    super
  end
end
