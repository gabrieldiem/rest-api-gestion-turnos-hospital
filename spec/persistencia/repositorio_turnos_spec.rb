require 'integration_helper'

require_relative '../../dominio/medico'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/paciente'
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
    paciente = RepositorioPacientes.new(logger).save(Paciente.new('anagomez@example.com', '12345678', 'anagomez'))

    turno = Turno.new(paciente, medico, Horario.new(Date.new(2025, 6, 11), Hora.new(8, 0)))
    described_class.new(logger).save(turno)
    expect(turno.id).not_to be_nil
  end

  it 'obtener turnos por id de un medico' do
    especialidad = RepositorioEspecialidades.new(logger).save(Especialidad.new('Cardiología', 30, 5, 'card'))
    medico = RepositorioMedicos.new(logger).save(Medico.new('Juan', 'Pérez', 'NAC123', especialidad))
    paciente = RepositorioPacientes.new(logger).save(Paciente.new('anagomez@example.com', '12345678', 'anagomez'))

    turno = Turno.new(paciente, medico, Horario.new(Date.new(2025, 6, 11), Hora.new(8, 0)))
    described_class.new(logger).save(turno)

    turnos = described_class.new(logger).find_by_medico_id(medico.id)
    expect(turnos).to eq([turno])
  end
end
