require 'integration_helper'
require_relative '../../dominio/estado_turno_factory'

describe EstadoTurnoFactory do
  it 'podemos obtener el estado reservado a partir del tipo' do
    estado = described_class.crear_estado('0')
    expect(estado.class).to eq(EstadoTurnoReservado)
  end

  it 'podemos obtener el tipo de un estado reservado' do
    estado = EstadoTurnoReservado.new
    tipo = described_class.obtener_tipo(estado)
    expect(tipo).to eq('0')
  end

  it 'podemos obtener el estado reservado a partir de su descripcion' do
    estado = described_class.crear_estado_por_descripcion('reservado')
    expect(estado.class).to eq(EstadoTurnoReservado)
  end

  it 'podemos obtener el estado presente a partir de su tipo' do
    estado = described_class.crear_estado('1')
    expect(estado.class).to eq(EstadoTurnoPresente)
  end

  it 'podemos obtener el tipo de un estado presente' do
    estado = EstadoTurnoPresente.new
    tipo = described_class.obtener_tipo(estado)
    expect(tipo).to eq('1')
  end

  it 'podemos obtener el estado presente a partir de su descripcion' do
    estado = described_class.crear_estado_por_descripcion('presente')
    expect(estado.class).to eq(EstadoTurnoPresente)
  end

  it 'podemos obtener el estado ausente a partir de su tipo' do
    estado = described_class.crear_estado('2')
    expect(estado.class).to eq(EstadoTurnoAusente)
  end

  it 'podemos obtener el tipo de un estado ausente' do
    estado = EstadoTurnoAusente.new
    tipo = described_class.obtener_tipo(estado)
    expect(tipo).to eq('2')
  end
end
