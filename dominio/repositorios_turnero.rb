class RepositoriosTurnero
  attr_reader :repositorio_pacientes, :repositorio_especialidades,
              :repositorio_medicos, :repositorio_turnos
  def initialize(repositorio_pacientes,
                 repositorio_especialidades,
                 repositorio_medicos,
                 repositorio_turnos)
    @repositorio_pacientes = repositorio_pacientes
    @repositorio_especialidades = repositorio_especialidades
    @repositorio_medicos = repositorio_medicos
    @repositorio_turnos = repositorio_turnos
  end
end
