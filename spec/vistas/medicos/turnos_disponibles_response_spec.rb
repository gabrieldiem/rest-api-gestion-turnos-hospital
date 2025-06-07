require 'integration_helper'
require_relative '../../../vistas/medicos/turnos_disponibles_response'

describe TurnosDisponiblesResponse do
  def respuesta_esperada(medico, turnos_disponibles)
    turnos_parseados = turnos_disponibles.map do |turno|
      {
        fecha: turno.fecha.to_s,
        hora: "#{turno.hora.hora}:#{turno.hora.minutos.to_s.rjust(2, '0')}"
      }
    end

    {
      medico: {
        nombre: medico.nombre,
        apellido: medico.apellido,
        matricula: medico.matricula,
        especialidad: medico.especialidad.codigo
      },
      turnos: turnos_parseados
    }.to_json
  end

  it 'transforma exitosamente a JSON cuando hay un turno' do
    especialidad = Especialidad.new('Cardiologia', 45, 1, 'card')
    especialidad.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)

    horario = Horario.new(DateTime.new(2025, 6, 10), Hora.new(8, 30))
    horarios = [horario]

    response = described_class.new(medico, horarios).to_json
    expect(response).to eq(respuesta_esperada(medico, horarios))
  end
end
