require 'date'
require 'time'
require 'sequel'
require_relative '../config/configuration'
require_relative './object_not_found_exception'

class AbstractRepository
  def save(a_record)
    @logger.debug "Actualizando tabla de #{a_record.class}: #{a_record.inspect}"
    if find_dataset_by_id(a_record.id).first
      update(a_record)
    else
      insert(a_record)
    end
    @logger.debug "Guardado exitosamente #{a_record.class} con ID: #{a_record.id}"
    a_record
  end

  def destroy(a_record)
    find_dataset_by_id(a_record.id).delete
  end
  alias delete destroy

  def delete_all
    dataset.delete
  end

  def all
    load_collection dataset.all
  end

  def find(id)
    found_record = dataset.first(pk_column => id)
    raise ObjectNotFoundException.new(self.class.model_class, id) if found_record.nil?

    load_object dataset.first(found_record)
  end

  def first
    @logger.debug "Obteniendo el primer registro de #{class_name}"

    load_collection dataset.where(is_active: true)
    load_object dataset.first
  end

  class << self
    attr_accessor :table_name, :model_class
  end

  protected

  def dataset
    DB[self.class.table_name]
  end

  def load_collection(rows)
    rows.map { |a_record| load_object(a_record) }
  end

  def update(a_record)
    find_dataset_by_id(a_record.id).update(update_changeset(a_record))
  end

  def insert(a_record)
    date = DateTime.parse(Time.now.to_s)
    changeset_to_insert = insert_changeset(a_record, date)
    id = dataset.insert(changeset_to_insert)

    a_record.id = id
    a_record.created_on = date
    a_record
  end

  def find_dataset_by_id(id)
    @logger.debug "Buscando #{class_name} con ID: #{id}"

    dataset.where(pk_column => id)
  end

  def load_object(_a_record)
    raise 'Subclass must implement'
  end

  def changeset(_a_object)
    raise 'Subclass must implement'
  end

  def insert_changeset(a_record, date)
    changeset_with_timestamps(a_record).merge(created_on: date)
  end

  def update_changeset(a_record)
    changeset_with_timestamps(a_record).merge(updated_on: Time.now)
  end

  def changeset_with_timestamps(a_record)
    changeset(a_record).merge(created_on: a_record.created_on, updated_on: a_record.updated_on)
  end

  def class_name
    self.class.model_class
  end

  def pk_column
    Sequel[self.class.table_name][:id]
  end

  def parse_datetime_from_row(datetime_from_row)
    DateTime.parse(datetime_from_row.to_s) unless datetime_from_row.nil?
  end
end
