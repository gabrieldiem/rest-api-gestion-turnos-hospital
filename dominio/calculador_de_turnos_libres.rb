class CalculadorDeTurnosLibres
  def initialize(repositorio_de_medicos, proveedor_de_fecha, proveedor_de_hora)
    @repositorio_de_medicos = repositorio_de_medicos
    @proveedor_de_fecha = proveedor_de_fecha
    @proveedor_de_hora = proveedor_de_hora
  end

  def calcular_turnos_disponibles_por_medico(medico)
    fecha_posterior = @proveedor_de_fecha.hoy + 1
    calcular_horarios_disponibles(fecha_posterior, medico.especialidad.duracion)
  end

  private

  def calcular_horarios_disponibles(fecha_turno, duracion_turno)
    horarios_disponibles = []
    max_cantidad_de_turnos = 5
    @turnos_actual_disponible = 0

    while horarios_disponibles.size < max_cantidad_de_turnos
      hora_turno = calcular_fecha_disponible(fecha_turno, duracion_turno)
      horarios_disponibles << { fecha: fecha_turno, hora: hora_turno }
      @turnos_actual_disponible += 1
    end

    horarios_disponibles
  end

  def calcular_fecha_disponible(fecha_actual, duracion)
    while @turnos_actual_disponible < 40
      horario = calcular_fecha_siguiente(fecha_actual, @turnos_actual_disponible, duracion)
      if existe_turno_asignado?(horario)
        @turnos_actual_disponible += 1
      else
        return Hora.new(horario.hour, horario.min)
      end
    end
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
end
