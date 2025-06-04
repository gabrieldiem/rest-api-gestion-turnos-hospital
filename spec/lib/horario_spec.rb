require 'integration_helper'
require_relative '../../lib/hora'
require_relative '../../lib/horario'

describe Horario do
  it 'Un horario que tiene hora 10h 31min y fecha 25/10/1999 se crea con los datos correctos' do
    hora = Hora.new(10, 31)
    fecha = Date.parse('25/10/1999')
    horario = described_class.new(fecha, hora)

    expect(horario.is_a?(described_class)).to be true
    expect(horario).to have_attributes(fecha:, hora:)
  end

  it 'Un horario que tiene hora 10h 31min y fecha 25/10/1999 es igual que otro con los mismo datos' do
    hora = Hora.new(10, 31)
    fecha = Date.parse('25/10/1999')
    horario = described_class.new(fecha, hora)

    expect(horario).to eq described_class.new(fecha, hora)
  end

  describe '- superposicion -' do
    let(:fecha) { Date.new(2024, 6, 1) }
    let(:duracion_1h) { Hora.new(1, 0) }

    it 'hay superposición parcial cuando están en la misma fecha' do
      h1 = described_class.new(fecha, Hora.new(10, 0))
      h2 = described_class.new(fecha, Hora.new(10, 30))

      expect(h1.hay_superposicion?(h2, duracion_1h)).to be true
    end

    it 'no hay superposición si están separados cuando están en la misma fecha' do
      h1 = described_class.new(fecha, Hora.new(10, 0))
      h2 = described_class.new(fecha, Hora.new(11, 1))

      expect(h1.hay_superposicion?(h2, duracion_1h)).to be false
    end

    it 'hay superposición total si empiezan igual cuando están en la misma fecha' do
      h1 = described_class.new(fecha, Hora.new(9, 0))
      h2 = described_class.new(fecha, Hora.new(9, 0))

      expect(h1.hay_superposicion?(h2, duracion_1h)).to be true
    end
  end
end
