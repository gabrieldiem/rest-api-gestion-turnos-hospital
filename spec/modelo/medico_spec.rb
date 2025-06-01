require 'spec_helper'
require_relative '../../dominio/medico'

describe Medico do
  it 'se crea exitosamente con nombre Juan, apellido Pérez, matrícula NAC123 y especialidad card' do
    medico = described_class.new('Juan', 'Pérez', 'NAC123', 'card')
    expect(medico).to have_attributes(nombre: 'Juan', apellido: 'Pérez', matricula: 'NAC123', especialidad: 'card')
  end
end
