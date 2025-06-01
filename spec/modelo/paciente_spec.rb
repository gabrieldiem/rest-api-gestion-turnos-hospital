require 'spec_helper'
require_relative '../../dominio/paciente'

describe Paciente do
  it 'se crea exitosamente con dni 12345678, email juan.perez@example.com y username @juanperez ' do
    usuario = described_class.new('juan.perez@example.com', '12345678', '@juanperez')
    expect(usuario).to have_attributes(email: 'juan.perez@example.com', dni: '12345678', username: '@juanperez')
  end

  describe 'validaciones' do
    it 'no se crea si el dni es vacío' do
      expect { described_class.new('juan.perez@example.com', '', '@juanperez') }.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el email no tiene @' do
      expect { described_class.new('juan.perez.com', '12345678', '@juanperez') }.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el email no tiene un dominio' do
      expect { described_class.new('juan@perez', '12345678', '@juanperez') }.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el email no tiene ni dominio ni @' do
      expect { described_class.new('juanPerez', '12345678', '@juanperez') }.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el email está vacío' do
      expect { described_class.new('', '12345678', '@juanperez') }.to raise_error(ActiveModel::ValidationError)
    end
  end
end
