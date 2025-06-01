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
end
