Sequel.migration do
  up do
    alter_table(:pacientes) do
      rename_column :created_on, :created_on_old
      rename_column :updated_on, :updated_on_old
    end

    alter_table(:pacientes) do
      add_column :created_on, DateTime
      add_column :updated_on, DateTime
    end

    self[:pacientes].each do |row|
      created_on_old = row[:created_on_old]
      updated_on_old = row[:updated_on_old]
      self[:pacientes].where(id: row[:id]).update(created_on: created_on_old.to_datetime) if created_on_old
      self[:pacientes].where(id: row[:id]).update(updated_on: updated_on_old.to_datetime) if updated_on_old
    end

    alter_table(:pacientes) do
      drop_column :created_on_old
      drop_column :updated_on_old
    end
  end

  down do
    alter_table(:pacientes) do
      rename_column :created_on, :created_on_new
      rename_column :updated_on, :updated_on_new
    end

    alter_table(:pacientes) do
      add_column :created_on, Date
      add_column :updated_on, Date
    end

    self[:pacientes].each do |row|
      created_on_new = row[:created_on_new]
      updated_on_new = row[:updated_on_new]
      self[:pacientes].where(id: row[:id]).update(created_on: created_on_new.to_date) if created_on_new
      self[:pacientes].where(id: row[:id]).update(updated_on: updated_on_new.to_date) if updated_on_new
    end

    alter_table(:pacientes) do
      drop_column :created_on_new
      drop_column :updated_on_new
    end
  end
end
