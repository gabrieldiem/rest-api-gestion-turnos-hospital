require 'integration_helper'

require_relative '../../../dominio/turnero'
require_relative '../../../dominio/especialidad'
require_relative '../../../dominio/medico'
require_relative '../../../dominio/paciente'
require_relative '../../../dominio/calculador_de_turnos_libres'
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
require_relative '../../../lib/hora'

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

    it 'puedo consultar todos los turnos reservados con un médico' do
      especialidad = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      paciente = turnero.crear_paciente('juancito@test.com', '999999999', 'juancito')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)

      fecha_de_maniana = fecha_de_hoy + 1
      hora_inicio_jornada = Hora.new(8, 0)
      hora_fin_jornada = Hora.new(18, 0)

      cantidad_turnos = (hora_fin_jornada.hora - hora_inicio_jornada.hora) * 2 # Cada turno dura 30 minutos
      cantidad_turnos.times do |i|
        hora_a_asignar = hora_inicio_jornada + Hora.new(0, i * 30)
        turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, "#{hora_a_asignar.hora}:#{hora_a_asignar.minutos}", paciente.dni)
      end

      turnos_reservados = turnero.obtener_turnos_reservados_por_medico('NAC456')
      expect(turnos_reservados.size).to eq(cantidad_turnos)
    end

    it 'cuando consulto los turnos de un médico sin turnos me devuelve un error' do
      especialidad = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)

      expect { turnero.obtener_turnos_reservados_por_medico('NAC456') }.to raise_error(SinTurnosException)
    end
  end
end
