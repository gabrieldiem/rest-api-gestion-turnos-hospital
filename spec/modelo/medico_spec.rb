require 'spec_helper'
require_relative '../../dominio/medico'
require_relative '../../dominio/especialidad'

describe Medico do
  let(:especialidad) { Especialidad.new('Cardiología', 30, 5, 'card') }

  it 'se crea exitosamente con nombre Juan, apellido Pérez, matrícula NAC123 y especialidad Cardiología' do
    medico = described_class.new('Juan', 'Pérez', 'NAC123', especialidad)
    expect(medico).to have_attributes(nombre: 'Juan', apellido: 'Pérez', matricula: 'NAC123', especialidad:)
  end

  it 'podemos comparar dos médicos con el mismo nombre, apellido, matrícula y especialidad' do
    medico1 = described_class.new('Juan', 'Pérez', 'NAC123', especialidad)
    medico2 = described_class.new('Juan', 'Pérez', 'NAC123', especialidad)
    expect(medico1).to eq(medico2)
  end
end
