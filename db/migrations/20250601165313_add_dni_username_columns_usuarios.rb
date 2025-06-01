Sequel.migration do
  up do
    alter_table(:usuarios) do
      add_column :dni, String
      add_column :username, String
    end
  end

  down do
    alter_table(:usuarios) do
      drop_column :dni
      drop_column :username
    end
  end
end
