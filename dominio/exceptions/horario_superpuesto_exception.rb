class HorarioSuperpuestoException < StandardError
  def initialize(msg = 'El turno se sobrepone con otro turno ya reservado. Por favor elija otro horario')
    super
  end
end
