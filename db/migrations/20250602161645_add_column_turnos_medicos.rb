Sequel.migration do
  up do
    drop_column :especialidades, :created_on
    drop_column :especialidades, :updated_on

    add_column :especialidades, :created_on, DateTime
    add_column :especialidades, :updated_on, DateTime
  end

  down do
    drop_column :especialidades, :created_on
    drop_column :especialidades, :updated_on

    add_column :especialidades, :created_on, Date
    add_column :especialidades, :updated_on, Date
  end
end
