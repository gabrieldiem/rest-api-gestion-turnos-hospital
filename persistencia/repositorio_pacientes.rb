require_relative './abstract_repository'

class RepositorioPacientes < AbstractRepository
  self.table_name = :pacientes
  self.model_class = 'Paciente'

  def initialize(logger)
    super()
    @logger = logger
    @repositorio_turnos = RepositorioTurnos.new(logger)
  end

  def find_by_dni(dni)
    records = dataset.where(dni:).first
    return nil if records.nil?

    paciente = load_object(records)
    paciente.turnos_reservados = load_turnos(paciente.id)
    paciente
  end

  def find_by_username(username)
    records = dataset.where(username:).first
    return nil if records.nil?

    paciente = load_object(records)
    paciente.turnos_reservados = load_turnos(paciente.id)
    paciente
  end

  def find_without_loading_turnos(id)
    AbstractRepository.instance_method(:find).bind(self).call(id)
  end

  protected

  def load_turnos(id)
    @repositorio_turnos.find_by_paciente_id(id)
  end

  def load_object(a_hash)
    Paciente.new(a_hash[:email], a_hash[:dni], a_hash[:username], a_hash[:id])
  end

  def changeset(paciente)
    {
      email: paciente.email,
      dni: paciente.dni,
      username: paciente.username
    }
  end
end
