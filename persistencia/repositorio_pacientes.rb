require_relative './abstract_repository'

class RepositorioPacientes < AbstractRepository
  self.table_name = :pacientes
  self.model_class = 'Paciente'

  def initialize(logger)
    super()
    @logger = logger
  end

  def find_by_dni(dni)
    records = dataset.where(dni:).first
    return nil if records.nil?

    load_object(records)
  end

  def find_by_username(username)
    records = dataset.where(username:).first
    return nil if records.nil?

    load_object(records)
  end

  protected

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
