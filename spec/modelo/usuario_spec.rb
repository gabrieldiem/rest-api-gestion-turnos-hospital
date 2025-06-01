require 'spec_helper'
require_relative '../../dominio/usuario'

describe Usuario do
  it 'se crea exitosamente con dni 12345678, email juan.perez@example.com y username @juanperez ' do
    usuario = described_class.new('juan.perez@example.com', '12345678', '@juanperez')
    expect(usuario).to have_attributes(email: 'juan.perez@example.com', dni: '12345678', username: '@juanperez')
  end
end
