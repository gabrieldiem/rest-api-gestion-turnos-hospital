Sequel.migration do
  up do
    create_table(:especialidades) do
      primary_key :id
      String :nombre
      Integer :duracion
      Integer :recurrencia_maxima
      String :codigo
      Date :created_on
      Date :updated_on
    end
  end

  down do
    drop_table(:especialidades)
  end
end
