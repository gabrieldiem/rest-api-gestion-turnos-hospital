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
end
