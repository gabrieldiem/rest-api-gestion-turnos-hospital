require 'integration_helper'

require_relative '../../../dominio/turnero'
require_relative '../../../dominio/especialidad'
require_relative '../../../dominio/medico'
require_relative '../../../dominio/paciente'
require_relative '../../../dominio/calendario_de_turnos'
require_relative '../../../dominio/exceptions/medico_inexistente_exception'
require_relative '../../../dominio/exceptions/paciente_inexistente_exception'
require_relative '../../../dominio/exceptions/fuera_de_horario_exception'
require_relative '../../../dominio/exceptions/turno_no_disponible_exception'
require_relative '../../../dominio/exceptions/sin_turnos_exception'
require_relative '../../../persistencia/repositorio_pacientes'
require_relative '../../../persistencia/repositorio_especialidades'
require_relative '../../../persistencia/repositorio_medicos'
require_relative '../../../lib/proveedor_de_fecha'
require_relative '../../../lib/proveedor_de_hora'
require_relative '../../../lib/proveedor_de_feriados'
require_relative '../../../lib/hora'
require_relative '../../stubs'

describe Turnero do
  include FeriadosStubs
  before(:each) do
    ENV['API_FERIADOS_URL'] = 'http://www.feriados-url.com'
  end

  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end
  let(:repositorio_medicos) { RepositorioMedicos.new(logger) }

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
  let(:repositorios) do
    RepositoriosTurnero.new(RepositorioPacientes.new(logger),
                            RepositorioEspecialidades.new(logger),
                            repositorio_medicos,
                            RepositorioTurnos.new(logger))
  end
  let(:turnero) do
    convertidor_de_tiempo = ConvertidorDeTiempo.new('%Y-%m-%d', ':', '%-H:%M')
    described_class.new(repositorios,
                        ProveedorDeFeriados.new(ENV['API_FERIADOS_URL'], logger),
                        proveedor_de_fecha,
                        proveedor_de_hora,
                        convertidor_de_tiempo)
  end
  let(:especialidad) { turnero.crear_especialidad('Cardiología', 30, 5, 'card') }

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

    def llenar_turnos_de_un_dia(cantidad_turnos, hora_inicio_jornada, fecha_de_maniana, dni_paciente)
      turnos_asignados = []
      cantidad_turnos.to_i.times do |i|
        hora_a_asignar = hora_inicio_jornada + Hora.new(0, i * 30)
        turno = turnero.asignar_turno('NAC456',
                                      fecha_de_maniana.to_s,
                                      "#{hora_a_asignar.hora}:#{hora_a_asignar.minutos}",
                                      dni_paciente)
        turnos_asignados.push(turno)
      end
      turnos_asignados
    end

    it 'puedo consultar todos los turnos reservados con un médico' do
      especialidad = turnero.crear_especialidad('Cardiología', 30, 21, 'card')
      turnero.crear_paciente('juancito@test.com', '1230000', 'juancito')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)

      fecha_de_maniana = fecha_de_hoy + 1
      cuando_pido_los_feriados(fecha_de_hoy.year, [])
      hora_inicio_jornada = Hora.new(8, 0)
      hora_fin_jornada = Hora.new(18, 0)

      cantidad_turnos = ((hora_fin_jornada.hora - hora_inicio_jornada.hora) * 60) / 30
      turnos_asignados = llenar_turnos_de_un_dia(cantidad_turnos, hora_inicio_jornada, fecha_de_maniana, '1230000')

      turnos_reservados = turnero.obtener_turnos_reservados_por_medico('NAC456')
      expect(turnos_reservados.size).to eq(turnos_asignados.size)
    end

    it 'cuando consulto los turnos de un médico sin turnos me devuelve un error' do
      especialidad = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)

      expect { turnero.obtener_turnos_reservados_por_medico('NAC456') }.to raise_error(SinTurnosException)
    end

    it 'obtener todas los medicos' do
      especialidad_uno = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      especialidad_dos = turnero.crear_especialidad('Pediatría', 20, 3, 'pedi')
      especialidad_tres = turnero.crear_especialidad('Cirugía', 60, 2, 'ciru')

      medico_uno = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad_uno.codigo)
      medico_dos = turnero.crear_medico('Ana', 'Gómez', 'NAC789', especialidad_dos.codigo)
      medico_tres = turnero.crear_medico('Luis', 'Martínez', 'NAC101', especialidad_tres.codigo)

      medicos = turnero.obtener_medicos
      expect(medicos.size).to eq(3)
      expect(medicos).to include(
        have_attributes(nombre: medico_uno.nombre, apellido: medico_uno.apellido, matricula: medico_uno.matricula, especialidad: medico_uno.especialidad),
        have_attributes(nombre: medico_dos.nombre, apellido: medico_dos.apellido, matricula: medico_dos.matricula, especialidad: medico_dos.especialidad),
        have_attributes(nombre: medico_tres.nombre, apellido: medico_tres.apellido, matricula: medico_tres.matricula, especialidad: medico_tres.especialidad)
      )
    end

    it 'obtener todos los medicos de una especialidad' do
      especialidad_uno = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      especialidad_dos = turnero.crear_especialidad('Pediatría', 20, 3, 'pedi')

      medico_uno = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad_uno.codigo)
      medico_dos = turnero.crear_medico('Ana', 'Gómez', 'NAC789', especialidad_uno.codigo)
      medico_tres = turnero.crear_medico('Luis', 'Martínez', 'NAC101', especialidad_dos.codigo)

      medicos = turnero.obtener_medicos_por_especialidad(especialidad_uno.codigo)
      expect(medicos.size).to eq(2)
      expect(medicos).to include(
        have_attributes(nombre: medico_uno.nombre, apellido: medico_uno.apellido, matricula: medico_uno.matricula, especialidad: medico_uno.especialidad),
        have_attributes(nombre: medico_dos.nombre, apellido: medico_dos.apellido, matricula: medico_dos.matricula, especialidad: medico_dos.especialidad)
      )
      expect(medicos).not_to include(
        have_attributes(nombre: medico_tres.nombre, apellido: medico_tres.apellido, matricula: medico_tres.matricula, especialidad: medico_tres.especialidad)
      )
    end
  end
end
