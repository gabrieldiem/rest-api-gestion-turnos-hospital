require 'integration_helper'
require_relative '../../dominio/estado_turno_reservado'

describe EstadoTurnoReservado do
  it 'el estado reservado es igual a "reservado"' do
    estado = described_class.new
    expect(estado.descripcion).to eq('reservado')
  end

  xit 'el estado reservado cuando cambiamos de asistencia a true es igual a "presente"' do
    estado = described_class.new
    estado.cambiar_asistencia(true)
    expect(estado.descripcion).to eq('presente')
  end
end
