class AccionProhibidaException < StandardError
  def initialize(msg = 'No se puede realizar esta acción')
    super
  end
end
