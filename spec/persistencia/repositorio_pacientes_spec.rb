require 'integration_helper'
require_relative '../../dominio/paciente'
require_relative '../../persistencia/repositorio_pacientes'

describe RepositorioPacientes do
  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end

  it 'deberia guardar y asignar id si el paciente es nuevo' do
    juan = Paciente.new('juan@test.com', '12345678', '@juanperez')
    described_class.new(logger).save(juan)
    expect(juan.id).not_to be_nil
  end

  it 'deberia recuperar todos' do
    repositorio = described_class.new(logger)
    cantidad_de_pacientes_iniciales = repositorio.all.size
    juan = Paciente.new('juan@test.com', '12345678', '@juanperez')
    repositorio.save(juan)
    expect(repositorio.all.size).to be(cantidad_de_pacientes_iniciales + 1)
  end

  it 'deberia encontrar un paciente por dni' do
    repositorio = described_class.new(logger)
    juan = Paciente.new('juan@test.com', '12345678', '@juanperez')
    repositorio.save(juan)
    juan_encontrado = repositorio.find_by_dni('12345678')
    expect(juan_encontrado).to have_attributes(email: juan.email, dni: juan.dni, username: juan.username)
  end

  it 'deberia encontrar un paciente por username' do
    repositorio = described_class.new(logger)
    juan = Paciente.new('juan@test.com', '12345678', '@juanperez')
    repositorio.save(juan)
    juan_encontrado = repositorio.find_by_username('@juanperez')
    expect(juan_encontrado).to have_attributes(email: juan.email, dni: juan.dni, username: juan.username)
  end

  it 'deberia retornar nil si no encuentra un paciente por username' do
    repositorio = described_class.new(logger)
    expect(repositorio.find_by_username('@noexiste')).to be_nil
  end
end
