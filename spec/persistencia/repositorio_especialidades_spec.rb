require 'integration_helper'

require_relative '../../dominio/especialidad'
require_relative '../../persistencia/repositorio_especialidades'

describe RepositorioEspecialidades do
  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end

  it 'deberia guardar y asignar id si la especialidad es nuevo' do
    especialidad = Especialidad.new('Cardiología', 30, 5, 'card')
    described_class.new(logger).save(especialidad)
    expect(especialidad.id).not_to be_nil
  end

  it 'deberia recuperar todos' do
    repositorio = described_class.new(logger)
    cantidad_de_especialidades_iniciales = repositorio.all.size
    especialidad = Especialidad.new('Cardiología', 30, 5, 'card')
    repositorio.save(especialidad)
    expect(repositorio.all.size).to be(cantidad_de_especialidades_iniciales + 1)
  end

  it 'la especialidad devuelta no puede ser nil' do
    repositorio = described_class.new(logger)
    especialidad = Especialidad.new('Cardiología', 30, 5, 'card')
    repositorio.save(especialidad)
    especialidad_recuperada = repositorio.find(especialidad.id)
    expect(especialidad_recuperada.created_on).not_to be_nil
  end

  it 'puedo obtener una especialidad por su codigo' do
    repositorio = described_class.new(logger)
    especialidad = Especialidad.new('Cardiología', 30, 5, 'card')
    repositorio.save(especialidad)
    especialidad_recuperada = repositorio.find_by_codigo('card')
    expect(especialidad_recuperada).not_to be_nil
  end
end
