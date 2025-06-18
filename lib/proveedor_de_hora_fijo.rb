require_relative './hora'

class ProveedorDeHoraFijo
  def initialize(hora)
    @hora = hora
  end

  def hora_actual
    hora_actual = Time.parse(@hora.to_s)
    Hora.new(hora_actual.hour, hora_actual.min)
  end
end