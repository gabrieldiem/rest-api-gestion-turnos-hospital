require_relative './abstract_repository'
require_relative '../config/configuration'

class RepositorioMedicos < AbstractRepository
  self.table_name = :medicos
  self.model_class = 'Medico'

  def initialize(logger)
    super()
    @logger = logger
  end

  def find_by_matricula(matricula)
    found_record = dataset.first(matricula:)
    return nil if found_record.nil?

    load_object(found_record)
  end

  protected

  def load_object(a_hash)
    Configuration.logger.debug "Buscando medico desde la DB: #{a_hash.inspect}"
    especialidad = RepositorioEspecialidades.new(@logger).find(a_hash[:especialidad]) if a_hash[:especialidad]
    medico = Medico.new(a_hash[:nombre], a_hash[:apellido], a_hash[:matricula], especialidad, a_hash[:id])
    Configuration.logger.debug "Medico encontrado: #{medico.inspect}"
    medico
  end

  def changeset(medico)
    Configuration.logger.debug "Creando changeset para medico: #{medico.inspect}"
    {
      nombre: medico.nombre,
      apellido: medico.apellido,
      matricula: medico.matricula,
      especialidad: medico.especialidad.id
    }
  end
end
