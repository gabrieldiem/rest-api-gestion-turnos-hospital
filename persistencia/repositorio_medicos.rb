require_relative './abstract_repository'

class RepositorioMedicos < AbstractRepository
  self.table_name = :medicos
  self.model_class = 'Medico'

  def initialize(logger)
    super()
    @logger = logger
    @repositorio_turnos = RepositorioTurnos.new(logger)
    @repositorio_especialidades = RepositorioEspecialidades.new(logger)
  end

  def find_by_matricula(matricula)
    records = dataset.where(matricula:).first

    return nil if records.nil?

    medico = load_object(records)
    medico.turnos_asignados = load_turnos(medico)
    medico
  end

  def find_without_loading_turnos(id)
    AbstractRepository.instance_method(:find).bind(self).call(id)
  rescue ObjectNotFoundException
    @logger.error 'No se pudo encontrar el médico por id'
    nil
  end

  def find_by_especialidad(id_especialidad)
    records = dataset.where(especialidad: id_especialidad)
    return [] if records.nil?

    load_collection(records)
  end

  protected

  def load_turnos(medico)
    @repositorio_turnos.find_by_medico(medico)
  end

  def load_object(a_hash)
    @logger.debug "Buscando medico desde la DB: #{a_hash.inspect}"
    especialidad = @repositorio_especialidades.find(a_hash[:especialidad]) if a_hash[:especialidad]
    medico = Medico.new(a_hash[:nombre], a_hash[:apellido], a_hash[:matricula], especialidad, a_hash[:id])
    medico.created_on = parse_datetime_from_row(a_hash[:created_on]) unless a_hash[:created_on].nil?
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
