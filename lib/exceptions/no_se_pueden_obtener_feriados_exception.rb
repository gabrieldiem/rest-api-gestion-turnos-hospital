class NoSePuedenObtenerFeriadosException < StandardError
  def initialize(msg = 'No es posible obtener feriados')
    super
  end
end
