require 'integration_helper'
require_relative '../../../vistas/medicos/nuevo_turno_reservado_response'

describe NuevoTurnoReservadoResponse do
  let(:convertidor_de_tiempo) { ConvertidorDeTiempo.new('%Y-%m-%d', ':', '%-H:%M') }

  def respuesta_esperada(turno)
    {
      id: turno.id,
      matricula: turno.medico.matricula,
      dni: turno.paciente.dni,
      turno: {
        fecha: convertidor_de_tiempo.presentar_fecha(turno.horario.fecha),
        hora: convertidor_de_tiempo.presentar_hora(turno.horario.hora)
      },
      created_at: turno.created_on.to_s
    }.to_json
  end

  it 'transforma exitosamente a JSON' do
    especialidad = Especialidad.new('Cardiologia', 45, 1, 'card')
    especialidad.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    paciente = Paciente.new('roberto@mail.com', '12345', 'robertito', 1)

    horario = Horario.new(DateTime.new(2025, 6, 10), Hora.new(8, 30))
    turno = Turno.new(paciente, medico, horario)

    response = described_class.new(turno, convertidor_de_tiempo).to_json
    expect(response).to eq(respuesta_esperada(turno))
  end
end
