require 'integration_helper'
require_relative '../../dominio/estado_turnos'

describe EstadoTurnos do
  it 'el estado reservado es igual a "reservado"' do
    estado = described_class.crear_estado_reservado
    expect(estado.valor).to eq('reservado')
  end
end
