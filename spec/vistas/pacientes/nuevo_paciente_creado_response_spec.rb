require 'integration_helper'
require_relative '../../../vistas/pacientes/nuevo_paciente_creado_response'

describe NuevoPacienteCreadoResponse do
  it 'transforma exitosamente a JSON' do
    paciente = Paciente.new('roberto@mail.com', '12345', 'robertito', 1)
    response = described_class.new(paciente).to_json
    expect(response).to eq({
      id: paciente.id,
      username: paciente.username,
      dni: paciente.dni,
      email: paciente.email,
      created_on: paciente.created_on
    }.to_json)
  end
end
