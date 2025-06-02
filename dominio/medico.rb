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

  def asignar_turno(fecha_turno, hora_turno, paciente)
    fecha_turno = DateTime.parse(fecha_turno.to_s)
    hora_turno = DateTime.parse(hora_turno)
    turno = { fecha: fecha_turno, hora: hora_turno.strftime('%H').to_i, minuto: hora_turno.strftime('%M').to_i, paciente: }
    @turnos ||= []
    @turnos << turno
  end
end
