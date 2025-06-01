require 'spec_helper'
require_relative '../../dominio/turnero'
require_relative '../../dominio/especialidad'
require_relative '../../persistencia/repositorio_usuarios'
require_relative '../../persistencia/repositorio_especialidades'

describe Turnero do
  let(:turnero) { described_class.new(RepositorioUsuarios.new, RepositorioEspecialidades.new) }

  it 'crea una especialidad nuevo' do
    especialidad_nuevo = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
    expect(especialidad_nuevo).to have_attributes(nombre: 'Cardiología', duracion: 30, recurrencia_maxima: 5, codigo: 'card')
  end
end
