class EspecialidadDuplicadaException < StandardError
  def initialize(msg = 'La especialidad ya existe con el código proveído')
    super
  end
end
