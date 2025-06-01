require 'active_model'

class Usuario
  include ActiveModel::Validations

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z]+)*\.[a-z]+\z/i

  attr_reader :email, :dni, :username
  attr_accessor :id, :updated_on, :created_on

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX, message: 'El formato del email es inválido' }
  validates :dni, presence: { message: 'El DNI es requerido' }

  def initialize(email, dni, username, id = nil)
    @email = email
    @dni = dni
    @username = username
    @id = id
    validate!
  end
end
