require 'integration_helper'
require_relative '../../../vistas/error/mensaje_error_response'

describe MensajeErrorResponse do
  it 'transforma exitosamente a JSON' do
    response = described_class.new('hay un error').to_json
    expect(response).to eq({
      mensaje_error: 'hay un error'
    }.to_json)
  end
end
