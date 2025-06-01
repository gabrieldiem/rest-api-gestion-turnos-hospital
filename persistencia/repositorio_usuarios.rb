require_relative './abstract_repository'

class RepositorioUsuarios < AbstractRepository
  self.table_name = :usuarios
  self.model_class = 'Usuario'

  def find_by_dni(dni)
    found_record = dataset.first(dni:)
    return nil if found_record.nil?

    load_object(found_record)
  end

  protected

  def load_object(a_hash)
    Usuario.new(a_hash[:email], a_hash[:dni], a_hash[:username], a_hash[:id])
  end

  def changeset(usuario)
    {
      email: usuario.email,
      dni: usuario.dni,
      username: usuario.username
    }
  end
end
