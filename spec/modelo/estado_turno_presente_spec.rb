require 'integration_helper'
require_relative '../../dominio/estado_turno_presente'

describe EstadoTurnoPresente do
  it 'el estado presente es igual a "presente"' do
    estado = described_class.new
    expect(estado.descripcion).to eq('presente')
  end
end
