require 'active_model'

class Paciente
  include ActiveModel::Validations

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z]+)*\.[a-z]+\z/i

  attr_reader :email, :dni, :username
  attr_accessor :id, :updated_on, :created_on, :turnos_reservados

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX, message: 'El formato del email es inválido' }
  validates :dni, presence: { message: 'El DNI es requerido' }
  validates :username, presence: { message: 'El username es requerido' }

  def initialize(email, dni, username, id = nil)
    @email = email
    @dni = dni
    @username = username
    @id = id
    @turnos_reservados = []
    validate!
  end

  def tiene_disponibilidad?(horario, duracion)
    @turnos_reservados.each do |turno|
      return false if turno.horario.hay_superposicion?(horario, duracion)
    end
    true
  end

  def ==(other)
    other.is_a?(Paciente) &&
      @dni == other.dni &&
      @email == other.email &&
      @username == other.username
  end
end
