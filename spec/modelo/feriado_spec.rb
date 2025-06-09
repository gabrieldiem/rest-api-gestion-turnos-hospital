require 'integration_helper'
require_relative '../../dominio/feriado'

describe Feriado do
  it 'se crea exitosamente para fecha 20/06/2025 motivo Día de la bandera y tipo inamovible' do
    fecha = Date.new(2025, 0o6, 20)
    feriado = described_class.new(fecha, 'Día de la bandera', 'inamovible')
    expect(feriado).to have_attributes(fecha:, motivo: 'Día de la bandera', tipo: 'inamovible')
  end

  it 'dos feriados con los mismos valores son iguales' do
    fecha = Date.new(2025, 0o6, 20)
    feriado1 = described_class.new(fecha, 'Día de la bandera', 'inamovible')
    feriado2 = described_class.new(fecha, 'Día de la bandera', 'inamovible')

    expect(feriado1).to eq(feriado2)
  end
end
