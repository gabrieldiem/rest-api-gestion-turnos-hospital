require_relative '../../dominio/especialidad'
require_relative '../../dominio/medico'
require_relative '../../dominio/asignador_de_turnos'

require_relative '../../persistencia/repositorio_especialidades'
require_relative '../../persistencia/repositorio_medicos'
require_relative '../../persistencia/repositorio_pacientes'
require_relative '../../persistencia/repositorio_turnos'
require_relative '../../lib/proveedor_de_fecha'
require_relative '../stubs'

describe AsignadorDeTurnos do
  include FeriadosStubs

  before(:each) do
    ENV['API_FERIADOS_URL'] = 'http://www.feriados-url.com'
    cuando_pido_los_feriados(2025, [])
  end

  let(:api_feriados_url) { ENV['API_FERIADOS_URL'] }

  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end
  let(:repositorio_turnos) { RepositorioTurnos.new(logger) }
  let(:fecha_de_hoy) { Date.new(2025, 6, 9) }
  let(:proveedor_de_feriados) do
    ProveedorDeFeriados.new(api_feriados_url, logger)
  end
  let(:proveedor_de_fecha) do
    proveedor_double = class_double(Date, today: fecha_de_hoy)
    ProveedorDeFecha.new(proveedor_double)
  end
  let(:proveedor_de_hora) do
    hora_actual = DateTime.new(2025, 1, 1, 8, 0)
    proveedor_double = class_double(Time, now: hora_actual)
    ProveedorDeHora.new(proveedor_double)
  end
  let(:especialidad) do
    repositorio_especialidades = RepositorioEspecialidades.new(logger)
    especialidad = Especialidad.new('Cardiología', 30, 5, 'card')
    repositorio_especialidades.save especialidad
    especialidad
  end

  let(:medico) do
    repositorio_medicos = RepositorioMedicos.new(logger)
    medico = Medico.new('Pablo', 'Pérez', 'NAC456', especialidad)
    repositorio_medicos.save medico
  end

  let(:paciente) do
    repositorio = RepositorioPacientes.new(logger)
    juan = Paciente.new('juan@test.com', '12345678', '@juanperez', 1)
    repositorio.save(juan)
  end

  let(:calculador_turnos_libres) do
    CalculadorDeTurnosLibres.new(Hora.new(8, 0), Hora.new(18, 0),
                                 proveedor_de_fecha, proveedor_de_hora, proveedor_de_feriados)
  end

  let(:asignador_de_turnos) do
    described_class.new(repositorio_turnos, proveedor_de_feriados, calculador_turnos_libres)
  end

  it 'se asigna un turno correctamente' do
    fecha_de_maniana = fecha_de_hoy + 1
    horario = Horario.new(fecha_de_maniana, Hora.new(8, 0))
    turno_asignado = asignador_de_turnos.asignar_turno(medico, paciente, horario)
    expect(turno_asignado).to have_attributes(paciente:, medico:, horario:)
  end
end
