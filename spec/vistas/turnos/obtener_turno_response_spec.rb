require 'integration_helper'
require_relative '../../../vistas/turnos/obtener_turno_response'

describe ObtenerTurnoResponse do
  let(:convertidor_de_tiempo) { ConvertidorDeTiempo.new('%Y-%m-%d', ':', '%-H:%M') }

  def convertir_medico(medico)
    {
      nombre: medico.nombre.to_s,
      apellido: medico.apellido.to_s,
      matricula: medico.matricula.to_s,
      especialidad: medico.especialidad.codigo.to_s
    }
  end

  def presentar_fecha(fecha)
    convertidor_de_tiempo.presentar_fecha(fecha)
  end

  def presentar_hora(hora)
    convertidor_de_tiempo.presentar_hora(hora)
  end

  def respuesta_esperada(turno)
    {
      fecha: presentar_fecha(turno.horario.fecha),
      hora: presentar_hora(turno.horario.hora),
      duracion: turno.medico.especialidad.duracion.to_i,
      estado: turno.estado.descripcion.to_s,
      medico: convertir_medico(turno.medico)
    }.to_json
  end

  xit 'transforma exitosamente a JSON' do
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
