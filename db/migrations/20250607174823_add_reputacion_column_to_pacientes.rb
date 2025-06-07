Sequel.migration do
  up do
    add_column :pacientes, :reputacion, Float
  end

  down do
    drop_column :pacientes, :reputacion
  end
end
