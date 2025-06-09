require 'integration_helper'
require_relative '../../dominio/paciente'
require_relative '../../dominio/medico'
require_relative '../../dominio/especialidad'
require_relative '../../persistencia/repositorio_pacientes'
require_relative '../../persistencia/repositorio_especialidades'
require_relative '../../persistencia/repositorio_turnos'
require_relative '../../persistencia/repositorio_medicos'

describe Paciente do
  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end
  let(:especialidad) { Especialidad.new('Cardiología', 30, 5, 'card') }
  let(:repositorio_especialidades) { RepositorioEspecialidades.new(logger) }
  let(:repositorio_turnos) { RepositorioTurnos.new(logger) }
  let(:repositorio_medico) { RepositorioMedicos.new(logger) }
  let(:repositorio_pacientes) { RepositorioPacientes.new(logger) }
  let(:horario_que_quiero_reservar) do
    hora = Hora.new(8, 15)
    fecha = Date.parse('11/06/2025')
    Horario.new(fecha, hora)
  end

  it 'se crea exitosamente con dni 12345678, email juan.perez@example.com y username @juanperez ' do
    paciente = described_class.new('juan.perez@example.com', '12345678', '@juanperez', 1)
    expect(paciente).to have_attributes(email: 'juan.perez@example.com', dni: '12345678', username: '@juanperez')
  end

  it 'podemos comparar dos pacientes con el mismo dni, email y username' do
    paciente1 = described_class.new('juan.perez@example.com', '12345678', '@juanperez', 1)
    paciente2 = described_class.new('juan.perez@example.com', '12345678', '@juanperez', 1)
    expect(paciente1).to eq(paciente2)
  end

  describe '- validaciones -' do
    it 'no se crea si el dni es vacío' do
      expect do
        described_class.new('juan.perez@example.com', '', '@juanperez', 1)
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el email no tiene @' do
      expect do
        described_class.new('juan.perez.com', '12345678', '@juanperez', 1)
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el email no tiene un dominio' do
      expect do
        described_class.new('juan@perez', '12345678', '@juanperez', 1)
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el email no tiene ni dominio ni @' do
      expect do
        described_class.new('juanPerez', '12345678', '@juanperez', 1)
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el email está vacío' do
      expect do
        described_class.new('', '12345678', '@juanperez', 1)
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el username está vacío' do
      expect do
        described_class.new('juan.perez@example.com', '12345678', '', 1)
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si la reputación es menor a 0' do
      expect do
        described_class.new('juan.perez@example.com', '12345678', '', -1)
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si la reputación es mayor a 1' do
      expect do
        described_class.new('juan.perez@example.com', '12345678', '', 2)
      end.to raise_error(ActiveModel::ValidationError)
    end
  end

  describe '- disponibilidad de paciente -' do
    it 'tiene disponibilidad cuando no tiene ningun turno reservado' do
      paciente = described_class.new('juan.perez@example.com', '12345678', '@juanperez', 1)

      hora = Hora.new(10, 31)
      fecha = Date.parse('25/10/1999')
      horario = Horario.new(fecha, hora)

      expect(paciente.tiene_disponibilidad?(horario, Hora.new(0, especialidad.duracion))).to be true
    end

    it 'no tiene disponibilidad cuando tiene un turno reservado con superposicion' do
      paciente = described_class.new('juan.perez@example.com', '12345678', '@juanperez', 1)
      repositorio_pacientes.save(paciente)

      medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
      repositorio_especialidades.save especialidad
      repositorio_medico.save medico

      horario_turno_reservado = Horario.new(Date.new(2025, 6, 11), Hora.new(8, 0))
      turno = medico.asignar_turno(horario_turno_reservado, paciente)
      repositorio_turnos.save turno

      duracion = Hora.new(0, especialidad.duracion)

      paciente = repositorio_pacientes.find_by_dni('12345678')
      expect(
        paciente.tiene_disponibilidad?(horario_que_quiero_reservar, duracion)
      ).to be false
    end
  end

  describe '- actualizar reputación -' do
    xit 'actualiza la reputación a 1.0 cuando no tiene turnos reservados' do
      paciente = described_class.new('juan.perez@example.com', '12345678', '@juanperez', 1)
      expect(paciente.reputacion).to eq(1.0)
      paciente.actualizar_reputacion
      expect(paciente.reputacion).to eq(1.0)
    end

    xit 'la reputación mantiene igual cuando tiene turnos solo reservados' do
      paciente = described_class.new('juan.perez@example.com', '12345678', '@juanperez', 1)
      expect(paciente.reputacion).to eq(1.0)
      cantidad_turnos_reservados = 10
      (1..cantidad_turnos_reservados).each do |_i|
        turno = Turno.new(paciente, nil, Horario.new(Date.today, Hora.new(10, 0)))
        paciente.turnos_reservados << turno
        paciente.actualizar_reputacion
        expect(paciente.reputacion).to eq(1.0)
      end
    end

    it 'si tengo 2 turnos reservados de ayer, asisito a 1 y falte al otro. La reputacion es 0.5' do
      paciente = described_class.new('juan.perez@example.com', '12345678', '@juanperez', 1)

      (1..2).each do |_i|
        turno = Turno.new(paciente, nil, Horario.new(Date.today + 1, Hora.new(10, 0)))
        paciente.turnos_reservados << turno
      end

      paciente.turnos_reservados.first.cambiar_asistencia(true)
      paciente.turnos_reservados.last.cambiar_asistencia(false)
      paciente.actualizar_reputacion

      expect(paciente.reputacion).to eq(0.5)
    end
  end
end
