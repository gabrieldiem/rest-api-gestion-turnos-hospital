require 'integration_helper'
require_relative '../../dominio/medico'
require_relative '../../persistencia/repositorio_medicos'
require_relative '../../dominio/especialidad'
require_relative '../../persistencia/repositorio_especialidades'

describe RepositorioMedicos do
  it 'guarda y asigna id si el medico es nuevo' do
    especialidad = Especialidad.new('Cardiología', 30, 5, 'card')
    RepositorioEspecialidades.new.save(especialidad)
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    described_class.new.save(medico)
    expect(medico.id).not_to be_nil
  end

  it 'obtener un médico por matrícula' do
    especialidad = Especialidad.new('Cardiología', 30, 5, 'card')
    RepositorioEspecialidades.new.save(especialidad)
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    repositorio = described_class.new
    repositorio.save(medico)

    medico_encontrado = repositorio.find_by_matricula('NAC123')
    expect(medico_encontrado).to be_a(Medico)
    expect(medico_encontrado.matricula).to eq('NAC123')
  end
end
