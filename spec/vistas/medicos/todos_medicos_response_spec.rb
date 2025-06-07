require 'integration_helper'
require_relative '../../../vistas/medicos/todos_medicos_response'

describe TodosMedicosResponse do
  def respuesta_esperada(medicos)
    {
      cantidad_total: medicos.size,
      medicos: medicos.map do |medico|
        {
          id: medico.id,
          nombre: medico.nombre,
          apellido: medico.apellido,
          matricula: medico.matricula,
          especialidad: medico.especialidad.nombre,
          created_on: medico.created_on
        }
      end
    }.to_json
  end

  it 'transforma exitosamente a JSON cuando hay un medico' do
    especialidad = Especialidad.new('Cardiologia', 45, 1, 'card')
    especialidad.id = 1
    especialidad.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)

    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    medico.id = 1
    medico.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)
    medicos = [medico]

    response = described_class.new(medicos).to_json
    expect(response).to eq(respuesta_esperada(medicos))
  end

  it 'transforma exitosamente a JSON cuando hay 2 médicos' do
    especialidad = Especialidad.new('Cardiologia', 45, 1, 'card')
    especialidad.id = 1
    especialidad.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)

    medico1 = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    medico1.id = 1
    medico1.created_on = DateTime.new(2025, 6, 10, 12, 0, 0)

    medico2 = Medico.new('Pedro', 'Sueco', 'NAC123', especialidad)
    medico2.id = 1
    medico2.created_on = DateTime.new(2025, 6, 11, 12, 0, 0)

    medicos = [medico1, medico2]

    response = described_class.new(medicos).to_json
    expect(response).to eq(respuesta_esperada(medicos))
  end
end
