require 'integration_helper'

require_relative '../../dominio/medico'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/paciente'
require_relative '../../dominio/estado_turno_reservado'
require_relative '../../lib/hora'
require_relative '../../lib/horario'

require_relative '../../persistencia/repositorio_medicos'
require_relative '../../persistencia/repositorio_especialidades'
require_relative '../../persistencia/repositorio_pacientes'
require_relative '../../persistencia/repositorio_turnos'

describe RepositorioTurnos do
  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end

  it 'guarda y asigna id si el turno es nuevo' do
    especialidad = RepositorioEspecialidades.new(logger).save(Especialidad.new('Cardiología', 30, 5, 'card'))
    medico = RepositorioMedicos.new(logger).save(Medico.new('Juan', 'Pérez', 'NAC123', especialidad))
    paciente = RepositorioPacientes.new(logger).save(Paciente.new('anagomez@example.com', '12345678', 'anagomez', 1))

    turno = Turno.new(paciente, medico, Horario.new(Date.new(2025, 6, 11), Hora.new(8, 0)))
    described_class.new(logger).save(turno)
    expect(turno.id).not_to be_nil
  end

  it 'obtener turnos por id de un medico' do
    especialidad = RepositorioEspecialidades.new(logger).save(Especialidad.new('Cardiología', 30, 5, 'card'))
    medico = RepositorioMedicos.new(logger).save(Medico.new('Juan', 'Pérez', 'NAC123', especialidad))
    paciente = RepositorioPacientes.new(logger).save(Paciente.new('anagomez@example.com', '12345678', 'anagomez', 1))

    turno = Turno.new(paciente, medico, Horario.new(Date.new(2025, 6, 11), Hora.new(8, 0)))
    described_class.new(logger).save(turno)

    turnos = described_class.new(logger).find_by_medico_id(medico.id)
    expect(turnos).to eq([turno])
  end

  it 'obtener turnos por id de un paciente' do
    especialidad = RepositorioEspecialidades.new(logger).save(Especialidad.new('Cardiología', 30, 5, 'card'))
    medico = RepositorioMedicos.new(logger).save(Medico.new('Juan', 'Pérez', 'NAC123', especialidad))
    paciente = RepositorioPacientes.new(logger).save(Paciente.new('anagomez@example.com', '12345678', 'anagomez', 1))

    turno = Turno.new(paciente, medico, Horario.new(Date.new(2025, 6, 11), Hora.new(8, 0)))
    described_class.new(logger).save(turno)

    turnos = described_class.new(logger).find_by_paciente_id(paciente.id)
    expect(turnos).to eq([turno])
  end

  it 'los turnos tiene por defecto estado reservado' do
    especialidad = RepositorioEspecialidades.new(logger).save(Especialidad.new('Cardiología', 30, 5, 'card'))
    medico = RepositorioMedicos.new(logger).save(Medico.new('Juan', 'Pérez', 'NAC123', especialidad))
    paciente = RepositorioPacientes.new(logger).save(Paciente.new('anagomez@example.com', '12345678', 'anagomez', 1))

    turno = Turno.new(paciente, medico, Horario.new(Date.new(2025, 6, 11), Hora.new(8, 0)))
    described_class.new(logger).save(turno)

    turno = described_class.new(logger).find_by_id(turno.id)
    expect(turno.estado.class).to eq(EstadoTurnoReservado)
  end

  it 'existe el metodo find_by_id y cuando no existe el turno devuelve nil' do
    turno = described_class.new(logger).find_by_id(9999)
    expect(turno).to be_nil
  end
end
