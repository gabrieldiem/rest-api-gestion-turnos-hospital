Sequel.migration do
  up do
    add_index :turnos, :medico
    add_index :pacientes, :dni
    add_index :pacientes, :id
    add_index :medicos, :id
    add_index :medicos, :matricula
  end

  down do
    drop_index :medicos, :matricula
    drop_index :medicos, :id
    drop_index :pacientes, :dni
    drop_index :pacientes, :id
    drop_index :turnos, :medico
  end
end
