require_relative './abstract_repository'

class RepositorioPacientes < AbstractRepository
  self.table_name = :pacientes
  self.model_class = 'Paciente'

  def find_by_dni(dni)
    found_record = dataset.first(dni:)
    return nil if found_record.nil?

    load_object(found_record)
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
