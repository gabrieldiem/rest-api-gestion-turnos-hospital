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
  let(:turnero) do
    convertidor_de_tiempo = ConvertidorDeTiempo.new('%Y-%m-%d', ':', '%-H:%M')
    described_class.new(repositorio_pacientes,
                        repositorio_especialidades,
                        repositorio_medicos,
                        repositorio_turnos,
                        proveedor_de_fecha,
                        proveedor_de_hora,
                        convertidor_de_tiempo)
  end
  let(:especialidad) { turnero.crear_especialidad('Cardiología', 30, 5, 'card') }

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

    it 'asignar un turno despues de las 18 produce un error FueraDeHorarioException' do
      especialidad_cirujano = turnero.crear_especialidad('Cirujano', 5 * 60, 1, 'ciru')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad_cirujano.codigo)

      dni = '999999999'
      turnero.crear_paciente('paciente@test.com', dni, 'paciente_test')
      fecha_de_maniana = fecha_de_hoy + 1
      expect do
        turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, '18:30', dni)
      end
        .to raise_error(FueraDeHorarioException)
    end

    it 'asignar un turno en el mismo horario con otro turno del paciente un error HorarioSuperpuestoException' do
      especialidad_cirujano = turnero.crear_especialidad('Cirujano', 5 * 60, 1, 'ciru')
      especialidad_pediatra = turnero.crear_especialidad('Pediatra', 20, 1, 'pedi')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad_cirujano.codigo)
      turnero.crear_medico('Pablo', 'Pediatra', 'NAC000', especialidad_pediatra.codigo)

      dni = '999999999'
      turnero.crear_paciente('paciente@test.com', dni, 'paciente_test')
      fecha_de_maniana = fecha_de_hoy + 1
      turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, '10:00', dni)

      _paciente = repositorio_pacientes.find_by_dni '999999999'

      expect do
        turnero.asignar_turno('NAC000', fecha_de_maniana.to_s, '12:00', dni)
      end
        .to raise_error(HorarioSuperpuestoException)
    end

    it 'asignar un turno ya reservado produce un error TurnoNoDisponibleException' do
      especialidad_cirujano = turnero.crear_especialidad('Cirujano', 5 * 60, 1, 'ciru')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad_cirujano.codigo)
      fecha_de_maniana = fecha_de_hoy + 1

      dni = '999999999'
      dni2 = '88888888'
      turnero.crear_paciente('paciente@test.com', dni, 'paciente_test')
      turnero.crear_paciente('paciente2@test.com', dni2, 'paciente2_test')
      turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, '8:00', dni)
      expect do
        turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, '8:00', dni2)
      end
        .to raise_error(TurnoNoDisponibleException)
    end

    it 'obtener turnos reservados de un paciente' do
      especialidad_cirujano = turnero.crear_especialidad('Cirujano', 5 * 60, 1, 'ciru')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad_cirujano.codigo)
      fecha_de_maniana = fecha_de_hoy + 1

      dni = '999999999'
      turnero.crear_paciente('paciente@test.com', dni, 'paciente_test')
      turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, '8:00', dni)

      turnos_reservados = turnero.obtener_turnos_reservados_del_paciente_por_dni(dni)
      expect(turnos_reservados.size).to eq(1)
      expect(turnos_reservados.first.horario.fecha.to_s).to include(fecha_de_maniana.to_s)
      expect(turnos_reservados.first.medico.matricula).to eq('NAC456')
    end

    it 'obtener turnos reservados de un paciente sin turnos devuelve un error' do
      dni = '999999999'
      turnero.crear_paciente('paciente@test.com', dni, 'paciente_test')

      expect do
        turnero.obtener_turnos_reservados_del_paciente_por_dni(dni)
      end.to raise_error(SinTurnosException)
    end

    xit 'cambiar la asistencia de un turno' do
      fecha_de_maniana = fecha_de_hoy + 1
      medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      paciente = turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test')
      turno = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:00', paciente.dni)
      turno_actualizado = turnero.cambiar_asistencia_turno(turno.id, paciente.dni, true)
      expect(turno_actualizado.estado).to eq('presente')
    end
  end
end
