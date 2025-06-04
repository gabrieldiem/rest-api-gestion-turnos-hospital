class HorarioSuperpuestoException < StandardError
  def initialize(msg = 'El turno se sobrepone con otro turno ya reservado')
    super
  end
end
