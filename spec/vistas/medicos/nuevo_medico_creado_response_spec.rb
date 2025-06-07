require 'integration_helper'
require_relative '../../../routes/medicos/vistas/nuevo_medico_creado_response'

describe NuevoMedicoCreadoResponse do
  it 'transforma exitosamente a JSON' do
    especialidad = Especialidad.new('Cardiologia', 45, 1, 'card')
    especialidad.id = 1
    especialidad.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)

    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    medico.id = 1
    medico.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)

    response = described_class.new(medico).to_json
    expect(response).to eq({
      id: medico.id,
      nombre: medico.nombre,
      apellido: medico.apellido,
      matricula: medico.matricula,
      especialidad: medico.especialidad.codigo,
      created_on: medico.created_on
    }.to_json)
  end
end
