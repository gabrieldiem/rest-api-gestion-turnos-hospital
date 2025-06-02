require 'spec_helper'
require_relative '../../dominio/medico'
require_relative '../../dominio/especialidad'

describe Medico do
  let(:especialidad) { Especialidad.new('Cardiología', 30, 5, 'card') }

  it 'se crea exitosamente con nombre Juan, apellido Pérez, matrícula NAC123 y especialidad Cardiología' do
    medico = described_class.new('Juan', 'Pérez', 'NAC123', especialidad)
    expect(medico).to have_attributes(nombre: 'Juan', apellido: 'Pérez', matricula: 'NAC123', especialidad:)
  end

  it 'obtenemos los turnos disponibles del médico' do
    medico = described_class.new('Juan', 'Pérez', 'NAC123', especialidad)

    turnos_disponibles = medico.obtener_turnos_disponibles(Date.new(2025, 6, 10))

    expect(turnos_disponibles).to eq([
                                       { 'fecha' => '11/06/2025', 'hora' => '8:00' },
                                       { 'fecha' => '11/06/2025', 'hora' => '8:30' },
                                       { 'fecha' => '11/06/2025', 'hora' => '9:00' },
                                       { 'fecha' => '11/06/2025', 'hora' => '9:30' },
                                       { 'fecha' => '11/06/2025', 'hora' => '10:00' }
                                     ])
  end

  xit 'obtenemos los turnos, pero a partir de las 8:15 porque tiene un turno asignado' do
    medico = described_class.new('Juan', 'Pérez', 'NAC123', especialidad)

    medico.asignar_turno(Date.new(2025, 6, 11), '08:00', 'Paciente A')
    turnos_disponibles = medico.obtener_turnos_disponibles(Date.new(2025, 6, 10), hora_inicio: '08:15')

    expect(turnos_disponibles).to eq([
                                       { 'fecha' => '11/06/2025', 'hora' => '8:30' },
                                       { 'fecha' => '11/06/2025', 'hora' => '9:00' },
                                       { 'fecha' => '11/06/2025', 'hora' => '9:30' },
                                       { 'fecha' => '11/06/2025', 'hora' => '10:00' },
                                       { 'fecha' => '11/06/2025', 'hora' => '10:30' }
                                     ])
  end
end
