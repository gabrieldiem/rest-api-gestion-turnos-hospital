require 'integration_helper'
require_relative '../../../vistas/medicos/nuevo_turno_reservado_response'

describe NuevoTurnoReservadoResponse do
  def convertir_hora(hora)
    "#{hora.hora}:#{hora.minutos.to_s.rjust(2, '0')}"
  end

  def respuesta_esperada(turno)
    {
      id: turno.id,
      matricula: turno.medico.matricula,
      dni: turno.paciente.dni,
      turno: {
        fecha: turno.horario.fecha.to_s,
        hora: convertir_hora(turno.horario.hora)
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

    response = described_class.new(turno).to_json
    expect(response).to eq(respuesta_esperada(turno))
  end
end
