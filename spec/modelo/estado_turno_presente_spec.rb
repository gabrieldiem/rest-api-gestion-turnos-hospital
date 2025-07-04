require 'integration_helper'
require_relative '../../dominio/estado_turno_presente'

describe EstadoTurnoPresente do
  it 'el estado presente es igual a "presente"' do
    estado = described_class.new
    expect(estado.descripcion).to eq('presente')
  end

  it 'el estado presente cuando cambiamos de asistencia a false es igual a "ausente"' do
    estado = described_class.new
    nuevo_estado = estado.cambiar_asistencia(false)
    expect(nuevo_estado.descripcion).to eq('ausente')
  end

  it 'el estado presente cuando cambiamos de asistencia a true sigue siendo "presente"' do
    estado = described_class.new
    nuevo_estado = estado.cambiar_asistencia(true)
    expect(nuevo_estado.descripcion).to eq('presente')
  end

  it 'el estado presente acepta el metodo reservado? y asistio?' do
    estado = described_class.new
    expect(estado.reservado?).to be false
    expect(estado.asistio?).to be true
  end
end
