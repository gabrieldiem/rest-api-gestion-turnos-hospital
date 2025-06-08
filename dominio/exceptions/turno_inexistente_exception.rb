class TurnoInexistenteException < StandardError
  def initialize(msg = 'No existe un turno con los datos provistos')
    super
  end
end
