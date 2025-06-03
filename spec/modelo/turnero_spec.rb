require 'integration_helper'

require_relative '../../dominio/turnero'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/medico'
require_relative '../../dominio/calculador_de_turnos_libres'

require_relative '../../persistencia/repositorio_pacientes'
require_relative '../../persistencia/repositorio_especialidades'
require_relative '../../persistencia/repositorio_medicos'
require_relative '../../lib/proveedor_de_fecha'

describe Turnero do
  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end
  let(:repositorio_turnos) { RepositorioTurnos.new(logger) }
  let(:repositorio_especialidades) { RepositorioEspecialidades.new(logger) }
  let(:repositorio_medicos) { RepositorioMedicos.new(logger) }
  let(:repositorio_pacientes) { RepositorioPacientes.new(logger) }
  let(:fecha_de_hoy) { Date.new(2025, 6, 10) }
  let(:proveedor_de_fecha) do
    proveedor_double = class_double(Date, today: fecha_de_hoy)
    ProveedorDeFecha.new(proveedor_double)
  end
  let(:proveedor_de_hora) do
    hora_actual = DateTime.new(2025, 1, 1, 8, 0)
    proveedor_double = class_double(Time, now: hora_actual)
    ProveedorDeHora.new(proveedor_double)
  end
  let(:turnero) { described_class.new(repositorio_pacientes, repositorio_especialidades, repositorio_medicos, repositorio_turnos, proveedor_de_fecha, proveedor_de_hora) }
  let(:especialidad) { turnero.crear_especialidad('Cardiología', 30, 5, 'card') }

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

    it 'no encuentra un médico por matrícula inexistente' do
      expect { turnero.buscar_medico('NAC999') }.to raise_error(MedicoInexistente)
    end
  end

  describe '- Capacidades de Turnos - ' do
    it 'obtener turnos disponibles de un médico' do
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      fecha_de_maniana = fecha_de_hoy + 1

      turnos = turnero.obtener_turnos_disponibles('NAC456')

      expect(turnos).to eq([Horario.new(fecha_de_maniana, Hora.new(8, 0)),
                            Horario.new(fecha_de_maniana, Hora.new(8, 30)),
                            Horario.new(fecha_de_maniana, Hora.new(9, 0)),
                            Horario.new(fecha_de_maniana, Hora.new(9, 30)),
                            Horario.new(fecha_de_maniana, Hora.new(10, 0))])
    end

    it 'obtener turnos disponibles dado que ya se asigno un turno' do
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)

      dni = '999999999'
      turnero.crear_paciente('j@perez.com', dni, 'juanperez')

      fecha_de_maniana = fecha_de_hoy + 1
      turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, '8:00', dni)

      turnos = turnero.obtener_turnos_disponibles('NAC456')
      expect(turnos).to eq([Horario.new(fecha_de_maniana, Hora.new(8, 30)),
                            Horario.new(fecha_de_maniana, Hora.new(9, 0)),
                            Horario.new(fecha_de_maniana, Hora.new(9, 30)),
                            Horario.new(fecha_de_maniana, Hora.new(10, 0)),
                            Horario.new(fecha_de_maniana, Hora.new(10, 30))])
    end
  end

  describe '- Capacidades de Pacientes - ' do
    it 'crea un paciente nuevo valido' do
      paciente = turnero.crear_paciente('juan.perez@example.com', '12345678', 'juanperez')

      expect(paciente).to have_attributes(email: 'juan.perez@example.com', dni: '12345678', username: 'juanperez')
    end

    it 'crea un paciente nuevo y lo guarda en el repositorio' do
      paciente = turnero.crear_paciente('juan.perez@example.com', '12345678', 'juanperez')

      paciente_guardado = repositorio_pacientes.all.first
      expect(repositorio_pacientes.all.size).to eq(1)
      expect(paciente_guardado).to have_attributes(email: paciente.email, dni: paciente.dni, username: paciente.username)
    end

    it 'no se puede crear un paciente con DNI repetido' do
      dni = '12345678'
      _paciente_valido = turnero.crear_paciente('gabriel.dominguez@example.com', dni, 'gabrieldominguez')

      expect do
        turnero.crear_paciente('juan.perez@example.com', dni, 'juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se puede crear un paciente con email sin arroba (@)' do
      expect do
        turnero.crear_paciente('juan.perezexample.com', '12345678', 'juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se puede crear un paciente con email sin dominio' do
      expect do
        turnero.crear_paciente('juan.perez@example', '12345678', 'juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se puede crear un paciente con email vacio' do
      expect do
        turnero.crear_paciente('', '12345678', 'juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se puede crear un paciente con DNI vacio' do
      expect do
        turnero.crear_paciente('juan.perez@example.com', '', 'juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se puede crear un paciente con username vacio' do
      expect do
        turnero.crear_paciente('juan.perez@example.com', '12345678', '')
      end.to raise_error(ActiveModel::ValidationError)
    end
  end
end
