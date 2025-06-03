require 'integration_helper'

require_relative '../../lib/hora'

describe Hora do
  it 'Una hora que es 10h 31min se crea con 10h 31min' do
    hora = described_class.new(10, 31)

    expect(hora.is_a?(described_class)).to be true
    expect(hora).to have_attributes(hora: 10, minutos: 31)
  end

  it 'Una hora 10h 31min es igual que otra hora 10h 31min' do
    hora = described_class.new(10, 31)

    expect(hora).to eq described_class.new(10, 31)
  end
end
