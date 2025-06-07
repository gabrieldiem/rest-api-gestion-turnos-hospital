require 'integration_helper'
require_relative '../../../vistas/pacientes/turnos_reservados_por_paciente_response'

describe TurnosReservadosPorPacienteResponse do
  def convertir_medico(medico)
    {
      nombre: medico.nombre.to_s,
      apellido: medico.apellido.to_s,
      matricula: medico.matricula.to_s,
      especialidad: medico.especialidad.codigo.to_s
    }
  end

  def convertir_hora(hora)
    "#{hora.hora}:#{hora.minutos.to_s.rjust(2, '0')}"
  end

  def respuesta_esperada(turnos)
    {
      cantidad_de_turnos: turnos.size,
      turnos: turnos.map do |turno|
        {
          fecha: turno.horario.fecha.to_s,
          hora: convertir_hora(turno.horario.hora),
          medico: convertir_medico(turno.medico)
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

    response = described_class.new(turnos).to_json
    expect(response).to eq(respuesta_esperada(turnos))
  end
end
