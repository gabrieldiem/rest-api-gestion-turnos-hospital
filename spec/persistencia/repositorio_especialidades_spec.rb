require 'integration_helper'
require_relative '../../dominio/especialidad'
require_relative '../../persistencia/repositorio_especialidades'

describe RepositorioEspecialidades do
  it 'deberia guardar y asignar id si el usuario es nuevo' do
    especialidad = Especialidad.new('Cardiología', 30, 5, 'card')
    described_class.new.save(especialidad)
    expect(especialidad.id).not_to be_nil
  end
end
