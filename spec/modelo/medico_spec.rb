require 'spec_helper'
require_relative '../../dominio/medico'
require_relative '../../dominio/especialidad'

describe Medico do
  let(:especialidad) { Especialidad.new('Cardiología', 30, 5, 'card') }

  it 'se crea exitosamente con nombre Juan, apellido Pérez, matrícula NAC123 y especialidad Cardiología' do
    medico = described_class.new('Juan', 'Pérez', 'NAC123', especialidad)
    expect(medico).to have_attributes(nombre: 'Juan', apellido: 'Pérez', matricula: 'NAC123', especialidad:)
  end

  xit 'obtenemos los turnos disponibles del médico' do
    allow(Date).to receive(:today).and_return(Date.new(2025, 10, 6))
    medico = described_class.new('Juan', 'Pérez', 'NAC123', :especialidad)

    turnos_disponibles = medico.obtener_turnos_disponibles

    expect(turnos_disponibles).to eq([
                                       { 'fecha' => '2025-11-06', 'hora' => '08:00' },
                                       { 'fecha' => '2025-11-06', 'hora' => '08:30' },
                                       { 'fecha' => '2025-11-06', 'hora' => '09:00' },
                                       { 'fecha' => '2025-11-06', 'hora' => '09:30' },
                                       { 'fecha' => '2025-11-06', 'hora' => '10:00' }
                                     ])
  end
end
