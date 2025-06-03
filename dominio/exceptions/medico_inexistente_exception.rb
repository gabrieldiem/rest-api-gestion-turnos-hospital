class MedicoInexistenteException < StandardError
  def initialize(msg = 'No existe un médico con la matrícula proveida')
    super
  end
end
