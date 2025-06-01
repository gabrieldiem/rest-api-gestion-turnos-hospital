Sequel.migration do
  up do
    create_table(:medicos) do
      primary_key :id
      String :nombre
      String :apellido
      String :matricula
      foreign_key :especialidad, :especialidades, null: false
      Timestamptz :created_on
      Timestamptz :updated_on
    end
  end

  down do
    drop_table(:medicos)
  end
end
