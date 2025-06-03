require 'integration_helper'

require_relative '../../lib/hora'

describe Hora do
  it 'Una hora que es 10h 31min se crea con 10h 31min' do
    hora = described_class.new(10, 31)

    expect(hora.is_a?(described_class)).to be true
    expect(hora).to have_attributes(hora: 10, minutos: 31)
  end

  it 'Una hora 10h 31min es igual que otra hora 10h 31min' do
    hora = described_class.new(10, 31)

    expect(hora).to eq described_class.new(10, 31)
  end

  it 'Suma de 10h30 + 1h45 da 12h15' do
    h1 = described_class.new(10, 30)
    h2 = described_class.new(1, 45)

    hora_resultado = h1 + h2

    expect(hora_resultado).to eq described_class.new(12, 15)
  end

  it 'Suma de 23h30 + 1h45 da 01h15' do
    h1 = described_class.new(23, 30)
    h2 = described_class.new(1, 45)

    hora_resultado = h1 + h2

    expect(hora_resultado).to eq described_class.new(1, 15)
  end

  it 'Suma de 12h00 + 12h00 da 00h00' do
    h1 = described_class.new(12, 0)
    h2 = described_class.new(12, 0)

    hora_resultado = h1 + h2

    expect(hora_resultado).to eq described_class.new(0, 0)
  end
end
