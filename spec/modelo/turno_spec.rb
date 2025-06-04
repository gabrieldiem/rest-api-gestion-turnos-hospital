require 'integration_helper'

require_relative '../../dominio/turno'
require_relative '../../dominio/medico'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/paciente'
require_relative '../../lib/hora'
require_relative '../../lib/horario'

describe Turno do
  let(:especialidad) { Especialidad.new('Cardiología', 30, 5, 'card') }
  let(:medico) { Medico.new('Juan', 'Pérez', 'NAC123', especialidad) }
  let(:paciente) { Paciente.new('anagomez@example.com', '12345678', 'anagomez') }
  let(:horario) { Horario.new(Date.new(2025, 6, 11), Hora.new(8, 0)) }

  it 'se crea exitosamente con Paciente, Medico y Horario' do
    turno = described_class.new(paciente, medico, horario)
    expect(turno).to have_attributes(paciente:, medico:, horario:)
  end

  it 'puedo comparar dos turnos con el mismo paciente, medico y horario' do
    turno1 = described_class.new(paciente, medico, horario)
    turno2 = described_class.new(paciente, medico, horario)
    expect(turno1).to eq(turno2)
  end

  xit 'no puedo crear un turno para despues de las 18:00' do
    horario_tarde = Horario.new(Date.new(2025, 6, 11), Hora.new(18, 30))
    expect { described_class.new(paciente, medico, horario_tarde) }.to raise_error(FueraDeHorarioException, 'El turno no puede ser asignado despues de las 18:00')
  end
end
