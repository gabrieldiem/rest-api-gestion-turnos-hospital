require 'spec_helper'

require_relative '../../dominio/turnero'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/medico'

require_relative '../../persistencia/repositorio_usuarios'
require_relative '../../persistencia/repositorio_especialidades'
require_relative '../../persistencia/repositorio_medicos'

describe Turnero do
  let(:repositorio_especialidades) { RepositorioEspecialidades.new }
  let(:repositorio_medicos) { RepositorioMedicos.new }
  let(:turnero) { described_class.new(RepositorioUsuarios.new, repositorio_especialidades, repositorio_medicos) }

  describe 'Especialidades' do
    it 'crea una especialidad nuevo' do
      especialidad_nuevo = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      expect(especialidad_nuevo).to have_attributes(nombre: 'Cardiología', duracion: 30, recurrencia_maxima: 5, codigo: 'card')
    end

    it 'crea una especialidad nuevo y lo guarda en el repositorio' do
      especialidad_nuevo = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      especialidad_guardada = repositorio_especialidades.all.first
      expect(repositorio_especialidades.all.size).to eq(1)
      expect(especialidad_guardada).to have_attributes(nombre: especialidad_nuevo.nombre, duracion: especialidad_nuevo.duracion, recurrencia_maxima: especialidad_nuevo.recurrencia_maxima,
                                                       codigo: especialidad_nuevo.codigo)
    end
  end

  describe 'Médicos' do
    it 'crea un médico nuevo' do
      especialidad = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      medico_nuevo = turnero.crear_medico('Juan', 'Pérez', 'NAC123', especialidad)
      expect(medico_nuevo).to have_attributes(nombre: 'Juan', apellido: 'Pérez', matricula: 'NAC123', especialidad:)
    end
  end
end
