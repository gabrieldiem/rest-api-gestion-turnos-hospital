require_relative './abstract_repository'

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

    medico = load_object(found_record)
    medico.turnos_asignados = load_turnos(medico.id)
    medico
  end

  def find_without_loading_turnos(id)
    AbstractRepository.instance_method(:find).bind(self).call(id)
  end

  protected

  def load_turnos(id)
    RepositorioTurnos.new(@logger).find_by_medico_id(id)
  end

  def load_object(a_hash)
    @logger.debug "Buscando medico desde la DB: #{a_hash.inspect}"
    especialidad = RepositorioEspecialidades.new(@logger).find(a_hash[:especialidad]) if a_hash[:especialidad]
    medico = Medico.new(a_hash[:nombre], a_hash[:apellido], a_hash[:matricula], especialidad, a_hash[:id])
    @logger.debug "Medico encontrado: #{medico.inspect}"
    medico
  end

  def changeset(medico)
    @logger.debug "Creando changeset para medico: #{medico.inspect}"
    {
      nombre: medico.nombre,
      apellido: medico.apellido,
      matricula: medico.matricula,
      especialidad: medico.especialidad.id
    }
  end
end
