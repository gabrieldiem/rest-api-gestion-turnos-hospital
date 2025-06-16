require 'integration_helper'
require_relative '../../dominio/estado_turno_reservado'

describe EstadoTurnoReservado do
  it 'el estado reservado es igual a "reservado"' do
    estado = described_class.new
    expect(estado.descripcion).to eq('reservado')
  end

  it 'el estado reservado cuando cambiamos de asistencia a true es igual a "presente"' do
    estado = described_class.new
    nuevo_estado = estado.cambiar_asistencia(true)
    expect(nuevo_estado.descripcion).to eq('presente')
  end

  it 'el estado reservado cuando cambiamos de asistencia a false es igual a "ausente"' do
    estado = described_class.new
    nuevo_estado = estado.cambiar_asistencia(false)
    expect(nuevo_estado.descripcion).to eq('ausente')
  end

  it 'el estado reservado acepta el metodo reservado? y asistio?' do
    estado = described_class.new
    expect(estado.reservado?).to be true
    expect(estado.asistio?).to be false
  end
end
