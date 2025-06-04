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
    let(:dia_siguiente_a_fecha) { Date.new(2024, 6, 2) }
    let(:duracion_1h) { Hora.new(1, 0) }
    let(:duracion_30m) { Hora.new(0, 30) }

    it 'hay superposición parcial cuando están en la misma fecha' do
      h1 = described_class.new(fecha, Hora.new(10, 0))
      h2 = described_class.new(fecha, Hora.new(10, 30))

      expect(h1.hay_superposicion?(h2, duracion_1h, duracion_1h)).to be true
    end

    it 'no hay superposición si están separados cuando están en la misma fecha' do
      h1 = described_class.new(fecha, Hora.new(10, 0))
      h2 = described_class.new(fecha, Hora.new(11, 1))

      expect(h1.hay_superposicion?(h2, duracion_1h, duracion_1h)).to be false
    end

    it 'hay superposición total si empiezan igual cuando están en la misma fecha' do
      h1 = described_class.new(fecha, Hora.new(9, 0))
      h2 = described_class.new(fecha, Hora.new(9, 0))

      expect(h1.hay_superposicion?(h2, duracion_1h, duracion_1h)).to be true
    end

    it 'no hay superposición si uno termina justo donde el otro empieza cuando están en la misma fecha' do
      h1 = described_class.new(fecha, Hora.new(10, 0))
      h2 = described_class.new(fecha, Hora.new(11, 0))

      expect(h1.hay_superposicion?(h2, duracion_1h, duracion_1h)).to be false
    end

    it 'cuando cruzan medianoche hay superposición si uno cruza medianoche y el otro empieza después' do
      h1 = described_class.new(fecha, Hora.new(23, 30))
      h2 = described_class.new(dia_siguiente_a_fecha, Hora.new(0, 0))

      expect(h1.hay_superposicion?(h2, duracion_1h, duracion_1h)).to be true
    end

    it 'cuando cruzan medianoche no hay superposición si no se tocan, aunque uno cruce medianoche' do
      h1 = described_class.new(fecha, Hora.new(23, 0))
      h2 = described_class.new(dia_siguiente_a_fecha, Hora.new(1, 0))

      expect(h1.hay_superposicion?(h2, duracion_1h, duracion_1h)).to be false
    end

    it 'hay superposición con duración corta de 30 minutos' do
      h1 = described_class.new(fecha, Hora.new(8, 0))
      h2 = described_class.new(fecha, Hora.new(8, 15))

      expect(h1.hay_superposicion?(h2, duracion_30m, duracion_30m)).to be true
    end

    it 'hay superposición con duración larga de 5h reciproca' do
      h1 = described_class.new(fecha, Hora.new(8, 0))
      h2 = described_class.new(fecha, Hora.new(12, 0))
      duracion = Hora.new(5, 0)

      expect(h1.hay_superposicion?(h2, duracion, duracion)).to be true
      expect(h2.hay_superposicion?(h1, duracion, duracion)).to be true
    end

    it 'dos horarios con duraciones distintas, pero que se superponen' do
      h1 = described_class.new(fecha, Hora.new(8, 0))
      h2 = described_class.new(fecha, Hora.new(9, 0))

      duracion1 = Hora.new(2, 0)
      duracion2 = Hora.new(1, 0)

      expect(h1.hay_superposicion?(h2, duracion2, duracion1)).to be true
    end
  end
end
