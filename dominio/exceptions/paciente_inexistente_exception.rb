class PacienteInexistenteException < StandardError
  def initialize(msg = 'No existe un paciente con los datos provistos')
    super
  end
end
