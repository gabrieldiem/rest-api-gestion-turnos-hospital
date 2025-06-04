require 'integration_helper'
require_relative '../../dominio/paciente'

describe Paciente do
  it 'se crea exitosamente con dni 12345678, email juan.perez@example.com y username @juanperez ' do
    paciente = described_class.new('juan.perez@example.com', '12345678', '@juanperez')
    expect(paciente).to have_attributes(email: 'juan.perez@example.com', dni: '12345678', username: '@juanperez')
  end

  it 'podemos comparar dos pacientes con el mismo dni, email y username' do
    paciente1 = described_class.new('juan.perez@example.com', '12345678', '@juanperez')
    paciente2 = described_class.new('juan.perez@example.com', '12345678', '@juanperez')
    expect(paciente1).to eq(paciente2)
  end

  describe '- validaciones -' do
    it 'no se crea si el dni es vacío' do
      expect do
        described_class.new('juan.perez@example.com', '', '@juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el email no tiene @' do
      expect do
        described_class.new('juan.perez.com', '12345678', '@juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el email no tiene un dominio' do
      expect do
        described_class.new('juan@perez', '12345678', '@juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el email no tiene ni dominio ni @' do
      expect do
        described_class.new('juanPerez', '12345678', '@juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el email está vacío' do
      expect do
        described_class.new('', '12345678', '@juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se crea si el username está vacío' do
      expect do
        described_class.new('juan.perez@example.com', '12345678', '')
      end.to raise_error(ActiveModel::ValidationError)
    end
  end

  it 'tiene disponibilidad cuando no tiene ningun turno reservado' do
    paciente = described_class.new('juan.perez@example.com', '12345678', '@juanperez')

    hora = Hora.new(10, 31)
    fecha = Date.parse('25/10/1999')
    horario = Horario.new(fecha, hora)

    expect(paciente.tiene_disponibilidad?(horario)).to be true
  end
end
