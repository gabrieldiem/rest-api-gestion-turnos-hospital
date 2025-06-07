require 'date'
require_relative './abstract_repository'

class RepositorioEspecialidades < AbstractRepository
  self.table_name = :especialidades
  self.model_class = 'Especialidad'

  def initialize(logger)
    super()
    @logger = logger
  end

  def find_by_codigo(codigo)
    rows = dataset.where(codigo:)
    return nil if rows.nil? || rows.empty?

    load_object(rows.first)
  end

  protected

  def load_object(a_hash)
    especialidad = Especialidad.new(a_hash[:nombre], a_hash[:duracion], a_hash[:recurrencia_maxima], a_hash[:codigo], a_hash[:id])
    especialidad.created_on = DateTime.parse(a_hash[:created_on].to_s) unless a_hash[:created_on].nil?
    especialidad
  end

  def changeset(especialidad)
    {
      nombre: especialidad.nombre,
      duracion: especialidad.duracion,
      recurrencia_maxima: especialidad.recurrencia_maxima,
      codigo: especialidad.codigo
    }
  end
end
