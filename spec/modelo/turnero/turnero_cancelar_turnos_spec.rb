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
  let(:medico) { turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo) }
  let(:paciente) { turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test') }

  describe '- Cancelacion de turnos - ' do
    it 'un turno cancelado con mas de 24hs de anticipacion debe eliminarlo de la BDD y no afectar la reputacion' do
      fecha_turno = proveedor_de_fecha.hoy + 2

      turno = turnero.asignar_turno(medico.matricula, fecha_turno.to_s, '8:00', paciente.dni)

      reputacion_inicial = turnero.buscar_paciente_por_dni(paciente.dni).reputacion

      turnero.cancelar_turno(turno.id)

      expect { turnero.buscar_turno(turno.id) }.to raise_error(TurnoInexistenteException)

      paciente_actualizado = turnero.buscar_paciente_por_dni(paciente.dni)

      expect(paciente_actualizado.reputacion).to eq(reputacion_inicial)
    end

    it 'cancelar un turno con anticipacion de 24hs muestra que el paciente no tiene asignado ese turno y el medico tampoco' do
      fecha_turno = proveedor_de_fecha.hoy + 2

      turno = turnero.asignar_turno(medico.matricula, fecha_turno.to_s, '8:00', paciente.dni)

      turnero.cancelar_turno(turno.id)

      expect { turnero.obtener_turnos_reservados_del_paciente_por_dni(paciente.dni) }.to raise_error(SinTurnosException)

      expect { turnero.obtener_turnos_reservados_por_medico(medico.matricula) }.to raise_error(SinTurnosException)
    end

    it 'un turno cancelado sin anticipacion de 24hs debe no eliminar el turno de la BDD y debe afectar la reputacion' do
      fecha_turno = proveedor_de_fecha.hoy

      hora_turno = proveedor_de_hora.hora_actual + Hora.new(5, 0)

      turno = turnero.asignar_turno(medico.matricula, fecha_turno.to_s, hora_turno.to_s, paciente.dni)

      reputacion_inicial = turnero.buscar_paciente_por_dni(paciente.dni).reputacion

      turnero.cancelar_turno(turno.id)

      turno_actualizado = turnero.buscar_turno(turno.id)

      expect(turno_actualizado.asistio?).to eq(false)

      paciente_actualizado = turnero.buscar_paciente_por_dni(paciente.dni)

      expect(paciente_actualizado.reputacion).to be < reputacion_inicial
    end

    it 'un turno cancelado sin anticipacion de 24hs no puede ser nuevamente reservado' do
      fecha_turno = proveedor_de_fecha.hoy

      hora_turno = proveedor_de_hora.hora_actual + Hora.new(5, 0)

      turno = turnero.asignar_turno(medico.matricula, fecha_turno.to_s, hora_turno.to_s, paciente.dni)

      turnero.cancelar_turno(turno.id)

      expect { turnero.asignar_turno(medico.matricula, fecha_turno.to_s, hora_turno.to_s, paciente.dni) }.to raise_error(TurnoNoDisponibleException)
    end

    it 'un turno cancelado con anticipacion de 24hs puede ser nuevamente reservado' do
      fecha_turno = proveedor_de_fecha.hoy + 2

      turno = turnero.asignar_turno(medico.matricula, fecha_turno.to_s, '8:00', paciente.dni)

      turnero.cancelar_turno(turno.id)

      turno_nuevo = turnero.asignar_turno(medico.matricula, fecha_turno.to_s, '8:00', paciente.dni)

      expect(turno_nuevo).to be_a(Turno)
    end

    it 'no se puede cancelar un turno que no sea reservado' do
      fecha_turno = proveedor_de_fecha.hoy
      hora_turno = proveedor_de_hora.hora_actual + Hora.new(5, 0)

      turno = turnero.asignar_turno(medico.matricula, fecha_turno.to_s, hora_turno.to_s, paciente.dni)

      turnero.cambiar_asistencia_turno(turno.id, paciente.dni, true)

      expect { turnero.cancelar_turno(turno.id) }.to raise_error(TurnoInvalidoException, 'No se puede cancelar un turno que ya ha sido actualizado')
    end
  end
end
