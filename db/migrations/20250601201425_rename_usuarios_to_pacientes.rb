Sequel.migration do
  up do
    rename_table(:usuarios, :pacientes)
  end

  down do
    rename_table(:pacientes, :usuarios)
  end
end
