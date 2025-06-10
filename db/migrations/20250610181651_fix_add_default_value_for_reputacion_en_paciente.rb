require_relative '../../dominio/paciente'

Sequel.migration do
  up do
    set_column_default(:pacientes, :reputacion, Paciente::REPUTACION_INICIAL)
  end

  down do
    set_column_default(:pacientes, :reputacion, nil)
  end
end
