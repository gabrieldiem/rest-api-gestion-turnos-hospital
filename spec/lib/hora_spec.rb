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

  it 'Suma de 24h00 + 24h00 da 00h00' do
    h1 = described_class.new(24, 0)
    h2 = described_class.new(24, 0)

    hora_resultado = h1 + h2

    expect(hora_resultado).to eq described_class.new(0, 0)
  end

  it 'Se normaliza correctamente una hora creada como 0h 120min a 2h 0min' do
    hora = described_class.new(0, 120)

    expect(hora).to eq described_class.new(2, 0)
  end

  it 'Se normaliza correctamente 23h 120min a 1h 0min del día siguiente' do
    hora = described_class.new(23, 120)

    expect(hora).to eq described_class.new(1, 0)
  end

  describe '- superposicion -' do
    let(:duracion_1h) { described_class.new(1, 0) }

    it 'detecta superposición parcial' do
      h1 = described_class.new(10, 0)
      h2 = described_class.new(10, 30)

      expect(h1.hay_superposicion?(h2, duracion_1h)).to be true
    end

    it 'detecta que no hay superposición' do
      h1 = described_class.new(10, 0)
      h2 = described_class.new(11, 1)

      expect(h1.hay_superposicion?(h2, duracion_1h)).to be false
    end

    it 'detecta superposición completa' do
      h1 = described_class.new(10, 0)
      h2 = described_class.new(10, 0)

      expect(h1.hay_superposicion?(h2, duracion_1h)).to be true
    end
  end
end
