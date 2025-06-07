require 'integration_helper'
require_relative '../../routes/especialidades/todas_especialidades_response'

describe TodasEspecialidadesResponse do
  def respuesta_esperada(especialidades)
    {
      cantidad_total: 1,
      especialidades: especialidades.map do |especialidad|
        {
          id: especialidad.id,
          nombre: especialidad.nombre,
          duracion: especialidad.duracion,
          recurrencia_maxima: especialidad.recurrencia_maxima,
          codigo: especialidad.codigo,
          created_on: especialidad.created_on
        }
      end
    }.to_json
  end

  it 'transforma exitosamente a JSON cuando hay un medico' do
    especialidad1 = Especialidad.new('Cardiologia', 45, 1, 'codigo')
    especialidad1.id = 1
    especialidad1.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)
    especialidades = [especialidad1]

    response = described_class.new(especialidades).to_json
    expect(response).to eq(respuesta_esperada(especialidades))
  end
end
