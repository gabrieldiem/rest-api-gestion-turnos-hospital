require 'integration_helper'
require_relative '../../dominio/especialidad'

describe Especialidad do
  it 'se crea exitosamente con nombre Cardiología, duración 30, recurrencia 5 y codigo card' do
    especialidad = described_class.new('Cardiología', 30, 5, 'card')
    expect(especialidad).to have_attributes(nombre: 'Cardiología', duracion: 30, recurrencia_maxima: 5, codigo: 'card')
  end

  it 'podemos comparar dos especialidades con el mismo nombre, duracion, recurrencia_maxima y codigo' do
    especialidad1 = described_class.new('Cardiología', 30, 5, 'card')
    especialidad2 = described_class.new('Cardiología', 30, 5, 'card')
    expect(especialidad1).to eq(especialidad2)
  end
end
