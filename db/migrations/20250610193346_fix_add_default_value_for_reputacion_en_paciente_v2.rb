require_relative '../../dominio/paciente'

Sequel.migration do
  up do
    alter_table(:pacientes) do
      rename_column :reputacion, :reputacion_old
    end

    alter_table(:pacientes) do
      add_column :reputacion, Float, default: Paciente::REPUTACION_INICIAL
    end

    self[:pacientes].each do |row|
      reputacion_old = row[:reputacion_old]
      reputacion_new = Paciente::REPUTACION_INICIAL

      reputacion_new = reputacion_old unless reputacion_old.nil?

      self[:pacientes].where(id: row[:id]).update(reputacion: reputacion_new)
    end

    alter_table(:pacientes) do
      drop_column :reputacion_old
    end
  end

  down do
    alter_table(:pacientes) do
      rename_column :reputacion, :reputacion_new
    end

    alter_table(:pacientes) do
      add_column :reputacion, Float
    end

    self[:pacientes].each do |row|
      reputacion = row[:reputacion_new]
      self[:pacientes].where(id: row[:id]).update(reputacion:) if reputacion
    end

    alter_table(:pacientes) do
      drop_column :reputacion_new
    end
  end
end
