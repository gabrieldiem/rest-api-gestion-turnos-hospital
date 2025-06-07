require 'integration_helper'
require_relative '../../../vistas/pacientes/paciente_response'

describe PacienteResponse do
  it 'transforma exitosamente a JSON' do
    paciente = Paciente.new('roberto@mail.com', '12345', 'robertito', 1)
    response = described_class.new(paciente).to_json
    expect(response).to eq({
      username: paciente.username,
      dni: paciente.dni,
      email: paciente.email
    }.to_json)
  end
end
