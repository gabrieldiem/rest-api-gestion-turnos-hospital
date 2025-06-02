class Medico
  attr_reader :nombre, :apellido, :matricula, :especialidad
  attr_accessor :id, :created_on, :updated_on

  def initialize(nombre, apellido, matricula, especialidad, id = nil)
    @nombre = nombre
    @apellido = apellido
    @matricula = matricula
    @especialidad = especialidad
    @id = id
  end

  def obtener_turnos_disponibles(fecha_actual)
    fecha_posterior = fecha_actual + 1
    calcular_turnos_disponibles(fecha_posterior, @especialidad.duracion)
  end

  private

  def calcular_turnos_disponibles(fecha_turno, duracion_turno)
    hora_inicio = 8
    cantidad_de_turnos = 0
    max_cantidad_de_turnos = 5
    turnos_disponibles = []

    while cantidad_de_turnos < max_cantidad_de_turnos
      hora_turno = DateTime.new(fecha_turno.year, fecha_turno.month, fecha_turno.day, hora_inicio + (cantidad_de_turnos * duracion_turno / 60), (cantidad_de_turnos * duracion_turno) % 60)
      turnos_disponibles << { 'fecha' => fecha_turno.strftime('%d-%m-%Y'), 'hora' => hora_turno.strftime('%H:%M') }
      cantidad_de_turnos += 1
    end

    turnos_disponibles
  end
end
