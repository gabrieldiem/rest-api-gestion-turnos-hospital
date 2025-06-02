require 'integration_helper'
require_relative '../../dominio/medico'
require_relative '../../persistencia/repositorio_medicos'
require_relative '../../dominio/especialidad'
require_relative '../../persistencia/repositorio_especialidades'

describe RepositorioMedicos do
  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end
  let(:especialidad) { Especialidad.new('Cardiología', 30, 5, 'card') }
  let(:repositorio_especialidades) { RepositorioEspecialidades.new(logger) }

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

  xit 'cuando se asigna un turno a un médico se guarda correctamente' do
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    repositorio = described_class.new(logger)
    repositorio.save(medico)

    medico.asignar_turno(Date.new(2025, 6, 11), '8:00', 'Paciente A')
    repositorio.save(medico)

    medico = repositorio.find_by_matricula('NAC123')
    expect(medico.turnos).to include({ fecha: Date.new(2025, 6, 11), hora: '8:00', paciente: 'Paciente A' })
  end
end
