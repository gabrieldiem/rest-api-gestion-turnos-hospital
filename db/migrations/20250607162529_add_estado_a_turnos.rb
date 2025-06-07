Sequel.migration do
  up do
    extension :pg_enum
    create_enum(:turnos_estado, [0, 1, 2])

    alter_table(:turnos) do
      add_column :estado, :turnos_estado
    end
  end

  down do
    extension :pg_enum
    alter_table(:turnos) do
      drop_column :estado
    end

    drop_enum(:turnos_estado)
  end
end
