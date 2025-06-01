require_relative './abstract_repository'

class RepositorioEspecialidades < AbstractRepository
  self.table_name = :especialidades
  self.model_class = 'Especialidad'

  protected

  def load_object(a_hash)
    especialidad = Especialidad.new(a_hash[:nombre], a_hash[:duracion], a_hash[:recurrencia_maxima], a_hash[:codigo], a_hash[:id])
    especialidad.created_on = a_hash[:created_on]
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
