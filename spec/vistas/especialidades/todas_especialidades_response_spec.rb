require 'integration_helper'
require_relative '../../../vistas/especialidades/todas_especialidades_response'

describe TodasEspecialidadesResponse do
  def respuesta_esperada(especialidades)
    {
      cantidad_total: especialidades.size,
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

  it 'transforma exitosamente a JSON cuando hay una especialidad' do
    especialidad = Especialidad.new('Cardiologia', 45, 1, 'card')
    especialidad.id = 1
    especialidad.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)
    especialidades = [especialidad]

    response = described_class.new(especialidades).to_json
    expect(response).to eq(respuesta_esperada(especialidades))
  end

  it 'transforma exitosamente a JSON cuando hay 2 especialidades' do
    especialidad1 = Especialidad.new('Cardiologia', 45, 1, 'card')
    especialidad1.id = 1
    especialidad1.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)

    especialidad2 = Especialidad.new('Traumatología', 45, 1, 'trauma')
    especialidad2.id = 2
    especialidad2.created_on = DateTime.new(2025, 6, 11, 12, 0, 0)

    especialidades = [especialidad1, especialidad2]

    response = described_class.new(especialidades).to_json
    expect(response).to eq(respuesta_esperada(especialidades))
  end
end
