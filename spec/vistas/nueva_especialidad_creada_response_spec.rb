require 'integration_helper'
require_relative '../../routes/especialidades/nueva_especialidad_creada_response'

describe NuevaEspecialidadCreadaResponse do
  it 'transforma exitosamente a JSON' do
    especialidad = Especialidad.new('Cardiologia', 45, 1, 'codigo')
    especialidad.id = 1
    especialidad.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)

    response = described_class.new(especialidad).to_json
    expect(response).to eq({
      id: especialidad.id,
      nombre: especialidad.nombre,
      duracion: especialidad.duracion,
      recurrencia_maxima: especialidad.recurrencia_maxima,
      codigo: especialidad.codigo,
      created_on: especialidad.created_on
    }.to_json)
  end
end
