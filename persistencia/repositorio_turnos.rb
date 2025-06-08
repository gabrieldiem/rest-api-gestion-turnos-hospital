require 'date'
require_relative './abstract_repository'
require_relative '../lib/hora'
require_relative '../lib/horario'
require_relative '../dominio/estado_turno_factory'

class RepositorioTurnos < AbstractRepository
  self.table_name = :turnos
  self.model_class = 'Turno'

  def initialize(logger)
    super()
    @logger = logger
  end

  def find_by_medico_id(medico_id)
    @logger.info("Buscando turnos para el médico con ID: #{medico_id}")
    records = dataset.where(medico: medico_id)
    return [] if records.empty?

    load_collection(records)
  end

  def find_by_paciente_id(paciente_id)
    @logger.info("Buscando turnos para el médico con ID: #{paciente_id}")
    records = dataset.where(paciente: paciente_id)
    return [] if records.empty?

    load_collection(records)
  end

  def find_by_id(turno_id)
    @logger.info("Buscando turno con ID: #{turno_id}")
    record = dataset.where(id: turno_id).first
    return nil if record.nil?

    load_object(record)
  end

  protected

  def crear_objeto_horario(a_hash)
    fecha = Date.parse(a_hash[:horario].to_s)
    hora = Hora.new(a_hash[:horario].hour, a_hash[:horario].min)
    Horario.new(fecha, hora)
  end

  def cargar_fechas_de_creacion_y_actualizacion(paciente, medico, horario, a_hash)
    turno = Turno.new(paciente, medico, horario, a_hash[:id])
    turno.estado = EstadoTurnoFactory.crear_estado(a_hash[:estado]) if a_hash[:estado]
    turno.created_on = parse_datetime_from_row(a_hash[:created_on]) unless a_hash[:created_on].nil?
    turno.updated_on = parse_datetime_from_row(a_hash[:updated_on]) unless a_hash[:updated_on].nil?
    turno
  end

  def load_object(a_hash)
    paciente = RepositorioPacientes.new(@logger).find_without_loading_turnos(a_hash[:paciente])
    medico = RepositorioMedicos.new(@logger).find_without_loading_turnos(a_hash[:medico])
    horario = crear_objeto_horario(a_hash)
    cargar_fechas_de_creacion_y_actualizacion(paciente, medico, horario, a_hash)
  end

  def changeset(turno)
    {
      paciente: turno.paciente.id,
      medico: turno.medico.id,
      horario: turno.horario.to_datetime,
      estado: EstadoTurnoFactory.obtener_tipo(turno.estado)
    }
  end
end
