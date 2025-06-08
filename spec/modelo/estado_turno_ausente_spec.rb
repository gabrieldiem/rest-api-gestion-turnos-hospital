require 'integration_helper'
require_relative '../../dominio/estado_turno_ausente'

describe EstadoTurnoAusente do
  it 'el estado ausente es igual a "ausente"' do
    estado = described_class.new
    expect(estado.descripcion).to eq('ausente')
  end
end
