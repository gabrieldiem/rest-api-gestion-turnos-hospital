require 'integration_helper'

require_relative '../../dominio/turno'
require_relative '../../dominio/medico'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/paciente'
require_relative '../../lib/hora'
require_relative '../../lib/horario'
require_relative '../../dominio/exceptions/fuera_de_horario_exception'
require_relative '../../dominio/estado_turno_reservado'

describe Turno do
  let(:especialidad) { Especialidad.new('Cardiología', 30, 5, 'card') }
  let(:medico) { Medico.new('Juan', 'Pérez', 'NAC123', especialidad) }
  let(:paciente) { Paciente.new('anagomez@example.com', '12345678', 'anagomez', 1) }
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

  it 'no puedo crear un turno para despues de las 18:00' do
    horario_tarde = Horario.new(Date.new(2025, 6, 11), Hora.new(18, 30))
    expect { described_class.new(paciente, medico, horario_tarde) }.to raise_error(FueraDeHorarioException)
  end

  it 'puedo crear un turno para las 17:59' do
    horario_tarde = Horario.new(Date.new(2025, 6, 11), Hora.new(17, 59))
    expect { described_class.new(paciente, medico, horario_tarde) }.not_to raise_error
  end

  it 'los turnos por defecto tiene estado reservado' do
    turno = described_class.new(paciente, medico, horario)
    expect(turno.estado.class).to eq(EstadoTurnoReservado)
  end

  it 'puedo cambiar el estado del turno a presente' do
    turno = described_class.new(paciente, medico, horario)
    turno.cambiar_asistencia(true)
    expect(turno.estado.class).to eq(EstadoTurnoPresente)
    expect(turno.estado.descripcion).to eq('presente')
  end

  it 'puedo cambiar el estado del turno a ausente' do
    turno = described_class.new(paciente, medico, horario)
    turno.cambiar_asistencia(false)
    expect(turno.estado.class).to eq(EstadoTurnoAusente)
    expect(turno.estado.descripcion).to eq('ausente')
  end

  it 'puedo preguntar por la asistencia del turno presente' do
    turno = described_class.new(paciente, medico, horario)
    turno.cambiar_asistencia(true)
    expect(turno.asistio?).to be true
  end

  it 'puedo preguntar por la asistencia del turno ausente' do
    turno = described_class.new(paciente, medico, horario)
    turno.cambiar_asistencia(false)
    expect(turno.asistio?).to be false
  end

  it 'puedo preguntar si el turno está reservado' do
    turno = described_class.new(paciente, medico, horario)
    expect(turno.reservado?).to be true
  end

  it 'puedo preguntar si el turno no está más reservado cuando asistio' do
    turno = described_class.new(paciente, medico, horario)
    turno.cambiar_asistencia(true)
    expect(turno.reservado?).to be false
  end

  it 'puedo preguntar si el turno no está más reservado cuando no asistio' do
    turno = described_class.new(paciente, medico, horario)
    turno.cambiar_asistencia(false)
    expect(turno.reservado?).to be false
  end
end
