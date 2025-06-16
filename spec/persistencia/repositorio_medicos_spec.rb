require 'integration_helper'

require_relative '../../dominio/medico'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/paciente'
require_relative '../../lib/hora'
require_relative '../../lib/horario'

require_relative '../../persistencia/repositorio_medicos'
require_relative '../../persistencia/repositorio_especialidades'

describe RepositorioMedicos do
  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end
  let(:especialidad) { Especialidad.new('Cardiología', 30, 5, 'card') }
  let(:repositorio_especialidades) { RepositorioEspecialidades.new(logger) }
  let(:repositorio_pacientes) { RepositorioPacientes.new(logger) }
  let(:repositorio_turnos) { RepositorioTurnos.new(logger) }

  before :each do
    repositorio_especialidades.save(especialidad)
  end

  it 'guarda y asigna id si el medico es nuevo' do
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    described_class.new(logger).save(medico)
    expect(medico.id).not_to be_nil
  end

  it 'obtener un médico por matrícula' do
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    repositorio = described_class.new(logger)
    repositorio.save(medico)

    medico_encontrado = repositorio.find_by_matricula('NAC123')
    expect(medico_encontrado).to be_a(Medico)
    expect(medico_encontrado.matricula).to eq('NAC123')
  end

  it 'cuando se asigna un turno a un médico se guarda correctamente' do
    horario = Horario.new(Date.new(2025, 6, 11), Hora.new(8, 0))
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    paciente = Paciente.new('anagomez@example.com', '12345678', 'anagomez', 1)
    repositorio_pacientes.save(paciente)

    repositorio_medico = described_class.new(logger)
    repositorio_medico.save(medico)

    turno = medico.asignar_turno(horario, paciente)
    repositorio_turnos.save turno

    medico = repositorio_medico.find_by_matricula('NAC123')
    expect(medico.turnos_asignados).to include(Turno.new(paciente, medico, horario))
  end

  it 'obtener un médico por id sin turnos' do
    horario = Horario.new(Date.new(2025, 6, 11), Hora.new(8, 0))
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    paciente = Paciente.new('anagomez@example.com', '12345678', 'anagomez', 1)
    repositorio_pacientes.save(paciente)

    repositorio_medico = described_class.new(logger)
    repositorio_medico.save(medico)

    turno = medico.asignar_turno(horario, paciente)
    repositorio_turnos.save turno

    medico = repositorio_medico.find_without_loading_turnos(medico.id)
    expect(medico.turnos_asignados).to eq []
  end

  it 'obtener un médico por id sin turnos con un id inexistente devuelve nil' do
    id_inexistente = 8888
    repositorio_medico = described_class.new(logger)
    expect(repositorio_medico.find_without_loading_turnos(id_inexistente)).to eq nil
  end

  xit 'obtener un medico por especialidad me trae todos los medicos de esa especialidad' do
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    medico2 = Medico.new('Juan', 'Suarez', 'NAC345', especialidad)

    especialidad_aux = repositorio_especialidades.find_by_codigo(especialidad.codigo)
    repositorio_medico = described_class.new(logger)
    repositorio_medico.save(medico)
    repositorio_medico.save(medico2)

    medicos = repositorio_medico.find_by_especialidad(especialidad_aux.id)
    expect(medicos).not_to eq []
    expect(medicos).to include(medico, medico2)
  end

  it 'obtener un medico por especialidad me trae vacio si no hay medicos de esa especialidad' do
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    otra_especialidad = 212_121
    repositorio_medico = described_class.new(logger)
    repositorio_medico.save(medico)

    medicos = repositorio_medico.find_by_especialidad(otra_especialidad)
    expect(medicos).to eq []
    expect(medicos).not_to include(medico)
  end
end
