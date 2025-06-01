require 'spec_helper'
require_relative '../../dominio/especialidad'

describe Especialidad do
  it 'se crea exitosamente con nombre Cardiología, duración 30, recurrencia 5 y codigo card' do
    especialidad = described_class.new('Cardiología', 30, 5, 'card')
    expect(especialidad).to have_attributes(nombre: 'Cardiología', duracion: 30, recurrencia_maxima: 5, codigo: 'card')
  end
end
