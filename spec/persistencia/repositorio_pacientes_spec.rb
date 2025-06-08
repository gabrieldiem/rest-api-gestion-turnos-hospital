require 'integration_helper'
require_relative '../../dominio/paciente'
require_relative '../../persistencia/repositorio_pacientes'

describe RepositorioPacientes do
  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end
  let(:especialidad) { Especialidad.new('Cardiología', 30, 5, 'card') }
  let(:repositorio_especialidades) { RepositorioEspecialidades.new(logger) }
  let(:repositorio_turnos) { RepositorioTurnos.new(logger) }
  let(:repositorio_medico) { RepositorioMedicos.new(logger) }

  it 'deberia guardar y asignar id si el paciente es nuevo' do
    juan = Paciente.new('juan@test.com', '12345678', '@juanperez', 1)
    described_class.new(logger).save(juan)
    expect(juan.id).not_to be_nil
  end

  it 'deberia recuperar todos' do
    repositorio = described_class.new(logger)
    cantidad_de_pacientes_iniciales = repositorio.all.size
    juan = Paciente.new('juan@test.com', '12345678', '@juanperez', 1)
    repositorio.save(juan)
    expect(repositorio.all.size).to be(cantidad_de_pacientes_iniciales + 1)
  end

  it 'deberia encontrar un paciente por dni' do
    repositorio = described_class.new(logger)
    juan = Paciente.new('juan@test.com', '12345678', '@juanperez', 1)
    repositorio.save(juan)
    juan_encontrado = repositorio.find_by_dni('12345678')
    expect(juan_encontrado).to have_attributes(email: juan.email, dni: juan.dni, username: juan.username)
  end

  it 'deberia encontrar un paciente por username' do
    repositorio = described_class.new(logger)
    juan = Paciente.new('juan@test.com', '12345678', '@juanperez', 1)
    repositorio.save(juan)
    juan_encontrado = repositorio.find_by_username('@juanperez')
    expect(juan_encontrado).to have_attributes(email: juan.email, dni: juan.dni, username: juan.username)
  end

  it 'deberia retornar nil si no encuentra un paciente por username' do
    repositorio = described_class.new(logger)
    expect(repositorio.find_by_username('@noexiste')).to be_nil
  end

  it 'obtener un paciente con turno tiene los turnos reservados' do
    horario = Horario.new(Date.new(2025, 6, 11), Hora.new(8, 0))
    repositorio_especialidades.save especialidad
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    paciente = Paciente.new('anagomez@example.com', '12345678', 'anagomez', 1)
    repositorio_pacientes = described_class.new(logger)
    repositorio_pacientes.save(paciente)
    repositorio_medico.save(medico)

    turno = medico.asignar_turno(horario, paciente)
    repositorio_turnos.save turno

    paciente = repositorio_pacientes.find_by_dni('12345678')
    expect(paciente.turnos_reservados).to eq [Turno.new(paciente, medico, horario)]
  end

  it 'obtener un paciente por id sin turno' do
    horario = Horario.new(Date.new(2025, 6, 11), Hora.new(8, 0))
    repositorio_especialidades.save especialidad
    medico = Medico.new('Juan', 'Perez', 'NAC123', especialidad)
    paciente = Paciente.new('anagomez@example.com', '12345678', 'anagomez', 1)
    repositorio_pacientes = described_class.new(logger)
    repositorio_pacientes.save(paciente)

    repositorio_medico.save(medico)

    turno = medico.asignar_turno(horario, paciente)
    repositorio_turnos.save turno

    paciente = repositorio_pacientes.find_without_loading_turnos(paciente.id)
    expect(paciente.turnos_reservados).to eq []
  end

  it 'cuando se crea un paciente la fecha de creacion tiene fecha y hora' do
    hora_actual = Time.new(2025, 6, 11, 12, 39)
    allow(Time).to receive(:now).and_return(hora_actual)

    repositorio = described_class.new(logger)
    juan = Paciente.new('juan@test.com', '12345678', '@juanperez', 1)
    repositorio.save(juan)
    juan_encontrado = repositorio.find_by_dni('12345678')
    expect(juan_encontrado).to have_attributes(email: juan.email, dni: juan.dni, username: juan.username)
    expect(juan_encontrado.created_on).to eq(hora_actual)
  end
end
