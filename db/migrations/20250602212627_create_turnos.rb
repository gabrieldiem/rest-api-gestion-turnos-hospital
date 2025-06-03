Sequel.migration do
  up do
    create_table(:turnos) do
      primary_key :id
      foreign_key :medico, :medicos, null: false
      foreign_key :paciente, :pacientes, null: false
      DateTime :horario
      DateTime :created_on
      DateTime :updated_on
    end
  end

  down do
    drop_table(:turnos)
  end
end
