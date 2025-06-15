require 'integration_helper'
require_relative '../../dominio/medico'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/paciente'

describe Medico do
  let(:especialidad) { Especialidad.new('Cardiología', 30, 5, 'card') }

  it 'se crea exitosamente con nombre Juan, apellido Pérez, matrícula NAC123 y especialidad Cardiología' do
    medico = described_class.new('Juan', 'Pérez', 'NAC123', especialidad)
    expect(medico).to have_attributes(nombre: 'Juan', apellido: 'Pérez', matricula: 'NAC123', especialidad:)
  end

  it 'podemos comparar dos médicos con el mismo nombre, apellido, matrícula y especialidad' do
    medico1 = described_class.new('Juan', 'Pérez', 'NAC123', especialidad)
    medico2 = described_class.new('Juan', 'Pérez', 'NAC123', especialidad)
    expect(medico1).to eq(medico2)
  end

  it 'no se puede crear si la especialidad no es válida' do
    expect  do
      described_class.new('Juan', 'Pérez', 'NAC123', nil)
    end.to raise_error(ActiveModel::ValidationError)
  end

  xit 'preguntar si tiene un turno asignado' do
    paciente = Paciente.new('juan.perez@example.com', '12345678', '@juanperez', 1)
    medico = described_class.new('Juan', 'Perez', 'NAC123', especialidad)

    horario = Horario.new(Date.today + 1, Hora.new(10, 0))
    turno = Turno.new(paciente, medico, horario, 1)
    
    medico.asignar_turno(turno.horario, paciente)

    expect(medico.tiene_turno_asignado?(horario)).to be true
  end

  describe '- quitar turno -' do
    it 'quita un turno reservado de la lista de turnos asignados' do
      paciente = described_class.new('juan.perez@example.com', '12345678', '@juanperez', 1)
      medico = described_class.new('Juan', 'Perez', 'NAC123', especialidad)
      turno1 = Turno.new(paciente, medico, Horario.new(Date.today + 1, Hora.new(10, 0)), 1)
      turno2 = Turno.new(paciente, medico, Horario.new(Date.today + 2, Hora.new(11, 0)), 2)

      medico.turnos_asignados << turno1
      medico.turnos_asignados << turno2

      expect(medico.turnos_asignados.size).to eq(2)

      medico.quitar_turno(turno1)
      expect(medico.turnos_asignados).not_to include(turno1)
      expect(medico.turnos_asignados.size).to eq(1)
    end

    it 'no cambia la lista si el turno a quitar no existe' do
      paciente = described_class.new('juan.perez@example.com', '12345678', '@juanperez', 1)
      medico = described_class.new('Juan', 'Perez', 'NAC123', especialidad)
      turno1 = Turno.new(paciente, medico, Horario.new(Date.today + 1, Hora.new(10, 0)), 1)
      turno2 = Turno.new(paciente, medico, Horario.new(Date.today + 2, Hora.new(11, 0)), 2)
      medico.turnos_asignados << turno1

      expect { medico.quitar_turno(turno2) }.to raise_error(TurnoInexistenteException)
    end

    it 'si el turno no es reservado, entonces no puede ser quitado de la lista' do
      paciente = described_class.new('juan.perez@example.com', '12345678', '@juanperez', 1)
      medico = described_class.new('Juan', 'Perez', 'NAC123', especialidad)
      turno = Turno.new(paciente, medico, Horario.new(Date.today + 1, Hora.new(10, 0)), 1)

      turno.cambiar_asistencia(true)

      expect { medico.quitar_turno(turno) }.to raise_error(TurnoInvalidoException)
    end

    it 'no puede quitar un turno que no tiene id' do
      paciente = described_class.new('juan.perez@example.com', '12345678', '@juanperez', 1)
      medico = described_class.new('Juan', 'Perez', 'NAC123', especialidad)
      turno = Turno.new(paciente, medico, Horario.new(Date.today + 1, Hora.new(10, 0)))
      medico.turnos_asignados << turno

      expect { medico.quitar_turno(turno) }.to raise_error(TurnoInvalidoException)
    end

    it 'no puede quitar un turno nil' do
      medico = described_class.new('Juan', 'Perez', 'NAC123', especialidad)

      expect { medico.quitar_turno(nil) }.to raise_error(TurnoInvalidoException)
    end
  end
end
