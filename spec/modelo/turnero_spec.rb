require 'integration_helper'

require_relative '../../dominio/turnero'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/medico'
require_relative '../../dominio/paciente'
require_relative '../../dominio/calculador_de_turnos_libres'
require_relative '../../dominio/exceptions/medico_inexistente_exception'
require_relative '../../dominio/exceptions/paciente_inexistente_exception'
require_relative '../../persistencia/repositorio_pacientes'
require_relative '../../persistencia/repositorio_especialidades'
require_relative '../../persistencia/repositorio_medicos'
require_relative '../../lib/proveedor_de_fecha'
require_relative '../../lib/proveedor_de_hora'
require_relative '../../lib/hora'

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
      expect { turnero.buscar_medico('NAC999') }.to raise_error(MedicoInexistenteException)
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

    def cantidad_turnos_en_un_dia(hora_inicio_jornada, hora_fin_jornada, duracion_turno)
      minutos_totales_de_jornada = (hora_fin_jornada.hora - hora_inicio_jornada.hora) * 60
      minutos_totales_de_jornada += hora_fin_jornada.minutos - hora_inicio_jornada.minutos
      minutos_totales_de_jornada / duracion_turno
    end

    def llenar_turnos_de_un_dia(matricula_medico, fecha_a_llenar, duracion_turno)
      dni = "100_#{fecha_a_llenar}_"
      hora_inicio_jornada = Hora.new(8, 0)
      hora_fin_jornada = Hora.new(18, 0)
      cantidad_turnos = cantidad_turnos_en_un_dia(hora_inicio_jornada, hora_fin_jornada, duracion_turno)

      hora_a_asignar = hora_inicio_jornada

      cantidad_turnos.times do |i|
        nuevo_dni = "#{dni}+#{i}"
        hora_a_asignar += Hora.new(0, duracion_turno) if i != 0

        turnero.crear_paciente("j+#{i}@perez.com", nuevo_dni, "juanperez+#{i}")
        turnero.asignar_turno(matricula_medico,
                              fecha_a_llenar.to_s,
                              "#{hora_a_asignar.hora}:#{hora_a_asignar.minutos}",
                              nuevo_dni)
      end
    end

    it 'obtener turnos disponibles del 12/06 dado que hoy es 10/06 y no hay turnos disponibles el 11/06' do
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)

      fecha_de_maniana = fecha_de_hoy + 1
      fecha_de_pasado_maniana = fecha_de_hoy + 2

      llenar_turnos_de_un_dia('NAC456', fecha_de_maniana, especialidad.duracion)

      turnos = turnero.obtener_turnos_disponibles('NAC456')

      expected = [Horario.new(fecha_de_pasado_maniana, Hora.new(8, 0)),
                  Horario.new(fecha_de_pasado_maniana, Hora.new(8, 30)),
                  Horario.new(fecha_de_pasado_maniana, Hora.new(9, 0)),
                  Horario.new(fecha_de_pasado_maniana, Hora.new(9, 30)),
                  Horario.new(fecha_de_pasado_maniana, Hora.new(10, 0))]

      expect(turnos).to eq(expected)
    end

    it 'obtener turnos disponibles de un medico que no existe produce error MedicoInexistenteException' do
      expect do
        turnero.obtener_turnos_disponibles('NAC999')
      end.to raise_error(MedicoInexistenteException)
    end

    it 'obtener turnos disponibles cuando no hay turnos en los proximos 40 dias me da ningun turno disponible' do
      especialidad_cirujano = turnero.crear_especialidad('Cirujano', 5 * 60, 1, 'ciru')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad_cirujano.codigo)

      fecha_de_maniana = fecha_de_hoy + 1
      40.times do |i|
        llenar_turnos_de_un_dia('NAC456', fecha_de_maniana + i, especialidad_cirujano.duracion)
      end

      turnos = turnero.obtener_turnos_disponibles('NAC456')
      expect(turnos).to eq([])
    end

    it 'asignar un turno a un paciente' do
      especialidad_cirujano = turnero.crear_especialidad('Cirujano', 5 * 60, 1, 'ciru')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad_cirujano.codigo)

      dni = '999999999'
      paciente = turnero.crear_paciente('paciente@test.com', dni, 'paciente_test')
      fecha_de_maniana = fecha_de_hoy + 1
      turno_asignado = turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, '8:00', dni)
      expect(turno_asignado).to have_attributes(medico: have_attributes(matricula: 'NAC456'),
                                                paciente: have_attributes(dni: paciente.dni),
                                                horario: have_attributes(fecha: fecha_de_maniana, hora: have_attributes(hora: 8, minutos: 0)))
    end

    xit 'asignar un turno despues de las 18 produce un error FueraDeHorarioException' do
      especialidad_cirujano = turnero.crear_especialidad('Cirujano', 5 * 60, 1, 'ciru')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad_cirujano.codigo)

      dni = '999999999'
      turnero.crear_paciente('paciente@test.com', dni, 'paciente_test')
      fecha_de_maniana = fecha_de_hoy + 1
      expect do
        turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, '18:30', dni)
      end
        .to raise_error(FueraDeHorarioException, 'El turno no puede ser asignado despues de las 18:00')
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

    it 'se obtiene un paciente por username' do
      paciente = turnero.crear_paciente('juan.perez@example.com', '12345678', 'juanperez')
      paciente_encontrado = turnero.buscar_paciente_por_username('juanperez')
      expect(paciente_encontrado).to have_attributes(email: paciente.email, dni: paciente.dni, username: paciente.username)
    end

    it 'no se encuentra un paciente por username inexistente' do
      expect do
        turnero.buscar_paciente_por_username('noexiste')
      end.to raise_error(PacienteInexistenteException)
    end
  end
end
