class ObjectNotFoundException < StandardError
  def initialize(tipo_de_objeto, id)
    @msg = "No se pudo encontrar el objeto de clase #{tipo_de_objeto} con id #{id} en la base de datos"
    super(@msg)
  end
end
