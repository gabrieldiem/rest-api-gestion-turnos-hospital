class ProveedorDeFechaFijo
  def initialize(fecha)
    @fecha = fecha
  end

  def hoy
    Date.parse(@fecha.to_s)
  end
end