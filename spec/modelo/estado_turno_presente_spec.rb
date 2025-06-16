require 'integration_helper'
require_relative '../../dominio/estado_turno_presente'

describe EstadoTurnoPresente do
  it 'el estado presente es igual a "presente"' do
    estado = described_class.new
    expect(estado.descripcion).to eq('presente')
  end

  xit 'el estado presente cuando cambiamos de asistencia a false es igual a "ausente"' do
    estado = described_class.new
    nuevo_estado = estado.cambiar_asistencia(false)
    expect(nuevo_estado.descripcion).to eq('ausente')
  end
end
