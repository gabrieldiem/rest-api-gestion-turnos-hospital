require 'integration_helper'
require_relative '../../../vistas/medicos/turnos_reservados_response'

describe TurnosReservadosResponse do
  let(:convertidor_de_tiempo) { ConvertidorDeTiempo.new('%Y-%m-%d', ':', '%-H:%M') }

  def respuesta_esperada(turnos)
    {
      cantidad_turnos: turnos.size,
      turnos: turnos.map do |turno|
        {
          fecha: convertidor_de_tiempo.presentar_fecha(turno.horario.fecha),
          hora: convertidor_de_tiempo.presentar_hora(turno.horario.hora),
          paciente: {
            dni: turno.paciente.dni.to_s
          }
        }
      end
    }.to_json
  end

  it 'transforma exitosamente a JSON cuando hay un turno' do
    especialidad = Especialidad.new('Cardiologia', 45, 1, 'card')
    especialidad.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    paciente = Paciente.new('roberto@mail.com', '12345', 'robertito', 1)

    horario = Horario.new(DateTime.new(2025, 6, 10), Hora.new(8, 30))
    turno = Turno.new(paciente, medico, horario)
    turnos = [turno]

    response = described_class.new(turnos, convertidor_de_tiempo).to_json
    expect(response).to eq(respuesta_esperada(turnos))
  end
end
