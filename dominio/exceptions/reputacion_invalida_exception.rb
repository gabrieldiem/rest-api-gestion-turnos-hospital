class ReputacionInvalidaException < StandardError
  def initialize(msg = 'Su reputación no es suficiente para reservar este turno')
    super
  end
end
