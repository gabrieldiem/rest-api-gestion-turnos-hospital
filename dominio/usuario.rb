class Usuario
  attr_reader :email
  attr_accessor :id, :updated_on, :created_on

  def initialize(email, id = nil)
    @email = email
    @id = id
  end
end
