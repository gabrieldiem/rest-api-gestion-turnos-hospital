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
require_relative '../../../dominio/exceptions/turno_inexistente_exception'
require_relative '../../../dominio/exceptions/paciente_invalido_exception'
require_relative '../../../dominio/exceptions/recurrencia_maxima_alcanzada_exception'
require_relative '../../../dominio/exceptions/turno_invalido_exception'
require_relative '../../../dominio/exceptions/reputacion_invalida_exception'
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
    cuando_pido_los_feriados(2025, [])
  end

  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end
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
                            RepositorioMedicos.new(logger),
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

  describe '- Cancelacion de turnos - ' do
    xit 'un turno cancelado con mas de 24hs de anticipacion debe eliminarlo de la BDD y no afectar la reputacion' do
      fecha_pasado_2_dias_de_hoy = :proveedor_de_fecha.hoy + 2

      medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      paciente = turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test')
      turno = turnero.asignar_turno(medico.matricula, fecha_pasado_2_dias_de_hoy.to_s, '8:00', paciente.dni)

      turnero.cancelar_turno(turno.id)

      expect { turnero.buscar_turno_by_id(turno.id) }.to raise_error(TurnoInexistenteException)

      paciente_actualizado = turnero.buscar_paciente_por_dni(paciente.dni)

      expect(paciente_actualizado.reputacion).to eq(1.0)
    end

    xit 'un turno cancelado con menos de 24hs de anticipacion debe no eliminarlo de la BDD y afectar la reputacion' do
      fecha_turno_con_menos_de_24hs_de_anticipacion = :proveedor_de_fecha.hoy
      hora_turno = :proveedor_de_hora.hora_actual - 1.hour

      medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      paciente = turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test')
      turno = turnero.asignar_turno(medico.matricula, fecha_turno_con_menos_de_24hs_de_anticipacion, hora_turno, paciente.dni)

      reputacion_inicial = turnero.buscar_paciente_por_dni(paciente.dni).reputacion
      expect(reputacion_inicial).to eq(1.0)

      turnero.cancelar_turno(turno.id)

      expect { turnero.buscar_turno_by_id(turno.id) }.not_to raise_error(TurnoInexistenteException)

      paciente_actualizado = turnero.buscar_paciente_por_dni(paciente.dni)

      expect(paciente_actualizado.reputacion).to be < reputacion_inicial
    end

    xit 'un turno cancelado con anticipacion no puede ser nuevamente cancelado' do
      fecha_turno_con_menos_de_24hs_de_anticipacion = :proveedor_de_fecha.hoy
      hora_turno = :proveedor_de_hora.hora_actual - 1.hour

      medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      paciente = turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test')
      turno = turnero.asignar_turno(medico.matricula, fecha_turno_con_menos_de_24hs_de_anticipacion, hora_turno, paciente.dni)

      turnero.cancelar_turno(turno.id)

      expect { turnero.cancelar_turno(turno.id) }.to raise_error(TurnoInvalidoException, 'No se puede cancelar un turno que ya ha sido actualizado')
    end

    xit 'un turno cancelado con anticipacion no puede actualizado' do
      fecha_turno_con_menos_de_24hs_de_anticipacion = :proveedor_de_fecha.hoy
      hora_turno = :proveedor_de_hora.hora_actual - 1.hour

      medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      paciente = turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test')
      turno = turnero.asignar_turno(medico.matricula, fecha_turno_con_menos_de_24hs_de_anticipacion, hora_turno, paciente.dni)

      turnero.cambiar_asistencia_turno(turno.id, paciente.dni, true)

      expect { turnero.cancelar_turno(turno.id) }.to raise_error(TurnoInvalidoException, 'No se puede cancelar un turno que ya ha sido actualizado')
    end
  end
end
