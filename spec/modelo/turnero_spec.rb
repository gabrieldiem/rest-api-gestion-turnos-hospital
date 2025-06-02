require 'spec_helper'

require_relative '../../dominio/turnero'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/medico'

require_relative '../../persistencia/repositorio_pacientes'
require_relative '../../persistencia/repositorio_especialidades'
require_relative '../../persistencia/repositorio_medicos'

describe Turnero do
  let(:repositorio_especialidades) { RepositorioEspecialidades.new }
  let(:repositorio_medicos) { RepositorioMedicos.new }
  let(:turnero) { described_class.new(RepositorioPacientes.new, repositorio_especialidades, repositorio_medicos) }

  describe '- Capacidades de Especialidades - ' do
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

  describe '- Capacidades de Medicos - ' do
    it 'crea un médico nuevo' do
      especialidad = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      medico_nuevo = turnero.crear_medico('Juan', 'Pérez', 'NAC123', 'card')

      expect(medico_nuevo).to have_attributes(nombre: 'Juan', apellido: 'Pérez', matricula: 'NAC123')
      expect(medico_nuevo.especialidad).to have_attributes(nombre: especialidad.nombre,
                                                           duracion: especialidad.duracion,
                                                           recurrencia_maxima: especialidad.recurrencia_maxima,
                                                           codigo: especialidad.codigo)
    end

    it 'crea un médico nuevo y lo guarda en el repositorio' do
      turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      medico_nuevo = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', 'card')
      medico_guardado = repositorio_medicos.all.first
      expect(repositorio_medicos.all.size).to eq(1)
      expect(medico_guardado.matricula).to eq(medico_nuevo.matricula)
    end

    it 'busca un médico por matrícula' do
      turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      medico_nuevo = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', 'card')
      medico_encontrado = turnero.buscar_medico('NAC456')
      expect(medico_encontrado).to have_attributes(nombre: medico_nuevo.nombre, apellido: medico_nuevo.apellido, matricula: medico_nuevo.matricula)
    end
  end

  describe '- Capacidades de Pacientes - ' do
    it 'crea un paciente nuevo valido' do
      paciente = turnero.crear_paciente('juan.perez@example.com', '12345678', 'juanperez')

      expect(paciente).to have_attributes(email: 'juan.perez@example.com', dni: '12345678', username: 'juanperez')
    end
  end
end
