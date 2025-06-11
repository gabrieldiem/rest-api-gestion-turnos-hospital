class ObjectNotFoundException < StandardError
  def initialize(msg = 'No se pudo encontrar el objeto en la base de datos')
    super
  end
end
