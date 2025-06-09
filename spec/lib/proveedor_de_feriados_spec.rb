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

  it 'devuelve un feriado correcto cuando la API devuelve solo un feriado' do
    proveedor_de_feriados = described_class.new(api_feriados_url, logger)
    fecha_feriado = Date.new(2025, 0o6, 20)
    cuando_pido_los_feriados(fecha_feriado.year, [fecha_feriado])

    feriado_esperado = Feriado.new(fecha_feriado, 'Es un feriado', 'inamovible')
    expect(proveedor_de_feriados.obtener_feriados(2025)).to eq([feriado_esperado])
  end
end
