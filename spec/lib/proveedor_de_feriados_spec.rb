require 'integration_helper'
require_relative '../../lib/proveedor_de_feriados'
require_relative '../stubs'

describe ProveedorDeFeriados do
  include FeriadosStubs

  before(:each) do
    ENV['API_FERIADOS_URL'] = 'http://www.feriados-url.com'
  end

  let(:api_feriados_url) { ENV['API_FERIADOS_URL'] }
  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end

  it 'se construye correctamente' do
    expect(described_class.new(api_feriados_url, logger)).to be_a(described_class)
  end
end
