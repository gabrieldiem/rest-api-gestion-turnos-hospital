require 'date'
require_relative './abstract_repository'
require_relative '../lib/hora'
require_relative '../lib/horario'

class RepositorioTurnos < AbstractRepository
  self.table_name = :turnos
  self.model_class = 'Turno'

  def initialize(logger)
    super()
    @logger = logger
  end

  protected

  def load_object(a_hash)
    paciente = RepositorioPacientes.new(@logger).find(a_hash[:paciente_id]).first
    medico = RepositorioMedicos.new(@logger).find(a_hash[:medico_id]).first
    hora = Hora.new(a_hash[:horario].hour, a_hash[:horario].min)
    fecha = Date.new(a_hash[:horario].year, a_hash[:horario].month, a_hash[:horario].day)
    horario = Horario.new(fecha, hora)

    turno = Turno.new(paciente, medico, horario, a_hash[:id])
    turno.created_on = DateTime.parse(a_hash[:created_on].to_s)
    turno.updated_on = DateTime.parse(a_hash[:updated_on].to_s) if a_hash[:updated_on]
    turno
  end

  def changeset(turno)
    {
      paciente: turno.paciente.id,
      medico: turno.medico.id,
      horario: DateTime.new(turno.horario.fecha.year, turno.horario.fecha.month, turno.horario.fecha.day, turno.horario.hora.hora, turno.horario.hora.minutos),
      created_on: turno.created_on,
      updated_on: turno.updated_on
    }
  end
end
