class Usuario
  attr_reader :email, :dni, :username
  attr_accessor :id, :updated_on, :created_on

  def initialize(email, dni, username, id = nil)
    @email = email
    @dni = dni
    @username = username
    @id = id
  end
end
