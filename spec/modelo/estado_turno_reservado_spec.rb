require 'integration_helper'
require_relative '../../dominio/estado_turno_reservado'

describe EstadoTurnoReservado do
  it 'el estado reservado es igual a "reservado"' do
    estado = described_class.new
    expect(estado.descripcion).to eq('reservado')
  end
end
