require 'spec_helper'
require_relative '../lib/convertidor_de_tiempo'
require_relative '../lib/exceptions/fecha_invalida_exception'
require_relative '../lib/exceptions/hora_invalida_exception'

describe ConvertidorDeTiempo do
  let(:formato_fecha) { '%Y-%m-%d'.freeze }
  let(:formato_hora_input) { '%H:%M'.freeze }
  let(:formato_hora_output) { '%-H:%M'.freeze }
  let(:convertidor) { described_class.new(formato_fecha, formato_hora_input, formato_hora_output) }

  it 'al convertir la fecha cuando la fecha es válida devuelve un objeto Date' do
    fecha = convertidor.estandarizar_fecha('2025-06-06')
    expect(fecha).to eq(Date.new(2025, 6, 6))
  end

  it 'al convertir la fecha cuando la fecha es inválida lanza FechaInvalidaException' do
    expect do
      convertidor.estandarizar_fecha('06/06/2025')
    end.to raise_error(FechaInvalidaException)
  end

  it 'al convertir hora cuando la fecha es inválida lanza FechaInvalidaException' do
    expect do
      convertidor.estandarizar_hora('06-06-2025', '8:30')
    end.to raise_error(HoraInvalidaException)
  end
end
