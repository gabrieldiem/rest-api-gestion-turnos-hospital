require 'active_model'

class Paciente
  include ActiveModel::Validations
  REPUTACION_INICIAL = 1.0

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z]+)*\.[a-z]+\z/i

  attr_reader :email, :dni, :username, :reputacion
  attr_accessor :id, :updated_on, :created_on, :turnos_reservados

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX, message: 'El formato del email es inválido' }
  validates :dni, presence: { message: 'El DNI es requerido' }
  validates :username, presence: { message: 'El username es requerido' }
  validates :reputacion, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1, message: 'La reputación debe estar entre 0 y 1' }

  def initialize(email, dni, username, reputacion, id = nil)
    @email = email
    @dni = dni
    @username = username
    @id = id
    @turnos_reservados = []
    @reputacion = reputacion
    validate!
  end

  def tiene_disponibilidad?(horario, otra_duracion)
    @turnos_reservados.each do |turno|
      duracion = Hora.new(0, turno.medico.especialidad.duracion)
      return false if turno.horario.hay_superposicion?(horario, otra_duracion, duracion)
    end
    true
  end

  def tiene_turnos_reservados?
    turnos_reservados = @turnos_reservados.count(&:reservado?)
    turnos_reservados > 0
  end

  def actualizar_reputacion
    @reputacion = REPUTACION_INICIAL if @turnos_reservados.empty?

    cantidad_turnos_pasados = @turnos_reservados.count { |turno| !turno.reservado? }
    cantidad_turnos_asistidos = @turnos_reservados.count(&:asistio?)

    @reputacion = cantidad_turnos_pasados.zero? ? REPUTACION_INICIAL : cantidad_turnos_asistidos.to_f / cantidad_turnos_pasados
  end

  def ==(other)
    other.is_a?(Paciente) &&
      @dni == other.dni &&
      @email == other.email &&
      @username == other.username
  end

  def obtener_cantidad_de_turnos_reservados_por_especialidad(especialidad)
    @turnos_reservados.count { |turno| turno.medico.especialidad.codigo == especialidad.codigo }
  end
end
