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

  def asignar_turno(fecha_turno, hora_turno, paciente)
    fecha_turno = DateTime.parse(fecha_turno.to_s)
    hora_turno = DateTime.parse(hora_turno)
    turno = { fecha: fecha_turno, hora: hora_turno.strftime('%H').to_i, minuto: hora_turno.strftime('%M').to_i, paciente: }
    @turnos ||= []
    @turnos << turno
  end

  private

  def calcular_turnos_disponibles(fecha_turno, duracion_turno)
    turnos_disponibles = []
    max_cantidad_de_turnos = 5
    @turnos_actual_disponible = 0

    while turnos_disponibles.size < max_cantidad_de_turnos
      hora_turno = calcular_fecha_disponible(fecha_turno, duracion_turno)
      turnos_disponibles << { 'fecha' => fecha_turno.strftime('%d/%m/%Y'), 'hora' => hora_turno.strftime('%-H:%M') }
      @turnos_actual_disponible += 1
    end

    turnos_disponibles
  end

  def calcular_fecha_siguiente(fecha_actual, turno_siguiente, duracion)
    hora_inicio = 8
    hora_siguiente = hora_inicio + (turno_siguiente * duracion / 60)
    minutos_siguiente = (turno_siguiente * duracion) % 60
    DateTime.new(fecha_actual.year, fecha_actual.month, fecha_actual.day, hora_siguiente, minutos_siguiente)
  end

  def existe_turno_asignado?(horario)
    return false if @turnos.nil? || @turnos.empty?

    @turnos.each do |turno|
      return true if turno[:fecha] == horario.to_date && turno[:hora] == horario.hour && turno[:minuto] == horario.min
    end
    false
  end

  def calcular_fecha_disponible(fecha_actual, duracion)
    while @turnos_actual_disponible < 40
      horario = calcular_fecha_siguiente(fecha_actual, @turnos_actual_disponible, duracion)
      if existe_turno_asignado?(horario)
        @turnos_actual_disponible += 1
      else
        return horario
      end
    end
  end
end
