require 'integration_helper'
require_relative '../../dominio/estado_turno_factory'

describe EstadoTurnoFactory do
  it 'podemos obtener el estado reservado a partir del tipo' do
    estado = described_class.crear_estado('0')
    expect(estado.class).to eq(EstadoTurnoReservado)
  end
end
