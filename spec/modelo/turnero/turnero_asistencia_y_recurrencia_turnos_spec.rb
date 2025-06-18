require 'integration_helper'

require_relative '../../../dominio/turnero'
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

  describe '- Asistencia y recurrencia máxima -' do
    describe 'cambiar asistencia a un turno y actualizacion de recurrencia' do
      it 'cuando asisto a un solo turno, la reputacion del paciente se mantiene en 1.0 y el estado es presente' do
        fecha_de_maniana = fecha_de_hoy + 1
        medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
        paciente = turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test')
        turno = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:00', paciente.dni)
        turno_actualizado = turnero.cambiar_asistencia_turno(turno.id, paciente.dni, true)

        paciente_actualizado = turnero.buscar_paciente_por_dni(paciente.dni)
        expect(paciente_actualizado.reputacion).to eq(1.0)

        expect(turno_actualizado.estado.descripcion).to eq('presente')
      end

      it 'cuando falto a un turno luego de asistir a otro, la reputacion del paciente baja a 0.5 y el estado es ausente' do
        fecha_de_maniana = fecha_de_hoy + 1
        medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
        paciente = turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test')
        turno = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:00', paciente.dni)
        turnero.cambiar_asistencia_turno(turno.id, paciente.dni, true)

        turno_nuevo = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:30', paciente.dni)
        turno_actualizado = turnero.cambiar_asistencia_turno(turno_nuevo.id, paciente.dni, false)
        paciente_actualizado = turnero.buscar_paciente_por_dni(paciente.dni)
        expect(paciente_actualizado.reputacion).to eq(0.5)
        expect(turno_actualizado.estado.descripcion).to eq('ausente')
      end

      it 'cuando asisto a 2 turnos, pero falto a uno, la reputacion del paciente baja a 0.66 y el estado es ausente' do
        fecha_de_maniana = fecha_de_hoy + 1
        medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
        dni_paciente = '999999999'
        turnero.crear_paciente('paciente@test.com', dni_paciente, 'paciente_test')

        # Asigno y asisto a dos turnos
        turno1 = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:00', dni_paciente)
        turno2 = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:30', dni_paciente)
        turnero.cambiar_asistencia_turno(turno1.id, dni_paciente, true)
        turnero.cambiar_asistencia_turno(turno2.id, dni_paciente, true)

        # Asigno y falto a un tercer turno
        turno3 = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '9:00', dni_paciente)
        turno_actualizado = turnero.cambiar_asistencia_turno(turno3.id, dni_paciente, false)

        paciente_actualizado = turnero.buscar_paciente_por_dni(dni_paciente)
        expect(paciente_actualizado.reputacion.truncate(2)).to eq(0.66)
        expect(turno_actualizado.estado.descripcion).to eq('ausente')
      end

      it 'cuando reservo 3 turnos, pero solo asisto a 1, mi reputacion es 0.33 y el estado es presente o ausente según corresponda' do
        fecha_de_maniana = fecha_de_hoy + 1
        medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
        paciente = turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test')

        # Asigno tres turnos
        turno1 = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:00', paciente.dni)
        turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:30', paciente.dni)
        turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '9:00', paciente.dni)

        # Solo asisto al primero
        turnero.cambiar_asistencia_turno(turno1.id, paciente.dni, true)

        paciente_actualizado = turnero.buscar_paciente_por_dni(paciente.dni)
        expect(paciente_actualizado.reputacion).to eq(1)
      end

      it 'cuando reservo 3 turnos, y no asisto al primero, mi reputacion va a ser 0' do
        fecha_de_maniana = fecha_de_hoy + 1
        medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
        paciente = turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test')

        # Asigno tres turnos
        turno1 = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:00', paciente.dni)
        turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:30', paciente.dni)
        turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '9:00', paciente.dni)

        # Solo asisto al primero
        turnero.cambiar_asistencia_turno(turno1.id, paciente.dni, false)

        paciente_actualizado = turnero.buscar_paciente_por_dni(paciente.dni)
        expect(paciente_actualizado.reputacion).to eq(0)
      end

      it 'cuando reservo 3 turnos, y no asisto al primero, pero si al segundo, mi reputacion es 0.5' do
        fecha_de_maniana = fecha_de_hoy + 1
        medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
        paciente = turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test')

        # Asigno tres turnos
        turno1 = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:00', paciente.dni)
        turno2 = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:30', paciente.dni)
        turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '9:00', paciente.dni)

        # Solo asisto al primero
        turnero.cambiar_asistencia_turno(turno1.id, paciente.dni, false)
        turnero.cambiar_asistencia_turno(turno2.id, paciente.dni, true)

        paciente_actualizado = turnero.buscar_paciente_por_dni(paciente.dni)
        expect(paciente_actualizado.reputacion).to eq(0.5)
      end
    end
  end

  describe 'cambiar asistencia a un turno' do
    it 'cuando cambio la asistencia de un paciente que no existe, produce un error' do
      fecha_de_maniana = fecha_de_hoy + 1
      medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      paciente = turnero.crear_paciente('paciente@test.com', '123000', 'paciente_test')
      turno_existente = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:00', paciente.dni)

      expect do
        turnero.cambiar_asistencia_turno(turno_existente.id, '999999999', true)
      end
        .to raise_error(PacienteInexistenteException)
    end

    it 'cuando cambio la asistencia de un turno que no existe, produce un error' do
      turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test')

      expect do
        turnero.cambiar_asistencia_turno(9999, '999999999', true)
      end
        .to raise_error(TurnoInexistenteException)
    end

    it 'cuando cambio la asistencia que no es del mismo paciente, produce un error' do
      fecha_de_maniana = fecha_de_hoy + 1
      medico = turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      paciente = turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test')
      turno = turnero.asignar_turno(medico.matricula, fecha_de_maniana.to_s, '8:00', paciente.dni)
      turno_obtenido = turnero.buscar_turno(turno.id)

      otro_paciente = turnero.crear_paciente('paciente2@test.com', '88888888', 'paciente2_test')

      expect do
        turnero.cambiar_asistencia_turno(turno_obtenido.id, otro_paciente.dni, true)
      end
        .to raise_error(PacienteInvalidoException)
    end
  end

  describe 'recurrencia maxima por turnos' do
    it 'cuando reservo un turno con un paciente que no alcanzo la recurrencia maxima, el turnero me deja' do
      especialidad_cirujano = turnero.crear_especialidad('Cirujano', 60, 3, 'ciru')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad_cirujano.codigo)
      fecha_de_maniana = fecha_de_hoy + 1
      dni = '999999999'
      turnero.crear_paciente('carlosbianchi@mail.com', dni, 'carlosbianchi')
      2.times do |i|
        hora = "#{8 + i}:00"
        turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, hora, dni)
      end
      turno = turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, '12:00', dni)
      expect(turno).to have_attributes(medico: have_attributes(matricula: 'NAC456'),
                                       paciente: have_attributes(dni:),
                                       horario: have_attributes(fecha: fecha_de_maniana, hora: have_attributes(hora: 12, minutos: 0)))
    end

    it 'cuando reservo un turno con un paciente que tiene el limite de recurrencia de turnos, produce un error' do
      especialidad_cirujano = turnero.crear_especialidad('Cirujano', 60, 3, 'ciru')
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad_cirujano.codigo)
      fecha_de_maniana = fecha_de_hoy + 1
      dni = '999999999'
      turnero.crear_paciente('carlosbianchi@mail.com', dni, 'carlosbianchi')
      3.times do |i|
        hora = "#{8 + i}:00"
        turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, hora, dni)
      end
      expect do
        turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, '11:00', dni)
      end
        .to raise_error(RecurrenciaMaximaAlcanzadaException)
    end
  end
end
