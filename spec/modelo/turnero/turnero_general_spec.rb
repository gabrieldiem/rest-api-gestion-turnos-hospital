require 'integration_helper'

require_relative '../../../dominio/turnero'
require_relative '../../../dominio/especialidad'
require_relative '../../../dominio/medico'
require_relative '../../../dominio/paciente'
require_relative '../../../dominio/calendario_de_turnos'
require_relative '../../../dominio/exceptions/medico_inexistente_exception'
require_relative '../../../dominio/exceptions/paciente_inexistente_exception'
require_relative '../../../dominio/exceptions/fuera_de_horario_exception'
require_relative '../../../dominio/exceptions/turno_no_disponible_exception'
require_relative '../../../dominio/exceptions/sin_turnos_exception'
require_relative '../../../dominio/exceptions/turno_inexistente_exception'
require_relative '../../../dominio/exceptions/accion_prohibida_exception'
require_relative '../../../persistencia/repositorio_pacientes'
require_relative '../../../persistencia/repositorio_especialidades'
require_relative '../../../persistencia/repositorio_medicos'
require_relative '../../../lib/proveedor_de_fecha'
require_relative '../../../lib/proveedor_de_hora'
require_relative '../../../lib/proveedor_de_feriados'
require_relative '../../../lib/hora'
require_relative '../../stubs'

describe Turnero do
  include FeriadosStubs

  before(:each) do
    ENV['API_FERIADOS_URL'] = 'http://www.feriados-url.com'
    cuando_pido_los_feriados(2025, [])
  end

  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end
  let(:repositorio_turnos) { RepositorioTurnos.new(logger) }
  let(:repositorio_especialidades) { RepositorioEspecialidades.new(logger) }
  let(:repositorio_medicos) { RepositorioMedicos.new(logger) }
  let(:repositorio_pacientes) { RepositorioPacientes.new(logger) }
  let(:fecha_de_hoy) { Date.new(2025, 6, 10) }
  let(:proveedor_de_fecha) do
    proveedor_double = class_double(Date, today: fecha_de_hoy)
    ProveedorDeFecha.new(proveedor_double)
  end
  let(:proveedor_de_hora) do
    hora_actual = DateTime.new(2025, 1, 1, 8, 0)
    proveedor_double = class_double(Time, now: hora_actual)
    ProveedorDeHora.new(proveedor_double)
  end
  let(:repositorios) do
    RepositoriosTurnero.new(repositorio_pacientes,
                            repositorio_especialidades,
                            repositorio_medicos,
                            repositorio_turnos)
  end
  let(:turnero) do
    convertidor_de_tiempo = ConvertidorDeTiempo.new('%Y-%m-%d', ':', '%-H:%M')
    described_class.new(repositorios,
                        ProveedorDeFeriados.new(ENV['API_FERIADOS_URL'], logger),
                        proveedor_de_fecha,
                        proveedor_de_hora,
                        convertidor_de_tiempo)
  end
  let(:especialidad) { turnero.crear_especialidad('Cardiología', 30, 5, 'card') }

  describe '- Eliminación de todos los datos - ' do
    it 'con habilitación se eliminan todos los datos de turnos' do
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      turnero.crear_paciente('juan@mail.com', '123456', 'juanjuan')
      turnero.asignar_turno('NAC456', '2025-05-20', '8:00', '123456')
      habilitado = true
      turnero.borrar_todos_los_datos(habilitado)

      expect(repositorio_turnos.all.size).to eq(0)
    end

    it 'con habilitación se eliminan todos los datos de especialidades, medicos y pacientes' do
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      turnero.crear_paciente('juan@mail.com', '123456', 'juanjuan')
      turnero.asignar_turno('NAC456', '2025-05-20', '8:00', '123456')
      habilitado = true
      turnero.borrar_todos_los_datos(habilitado)

      expect(repositorio_medicos.all.size).to eq(0)
      expect(repositorio_pacientes.all.size).to eq(0)
      expect(repositorio_especialidades.all.size).to eq(0)
    end

    it 'sin habilitacion no se eliminan los datos de turnos ni medicos' do
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      turnero.crear_paciente('juan@mail.com', '123456', 'juanjuan')
      turnero.asignar_turno('NAC456', '2025-05-20', '8:00', '123456')
      habilitado = false

      expect do
        turnero.borrar_todos_los_datos(habilitado)
      end.to raise_error(AccionProhibidaException)

      expect(repositorio_turnos.all.size).to eq(1)
      expect(repositorio_medicos.all.size).to eq(1)
    end

    it 'sin habilitacion no se eliminan los datos de pacientes ni especialidades' do
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      turnero.crear_paciente('juan@mail.com', '123456', 'juanjuan')
      habilitado = false

      expect do
        turnero.borrar_todos_los_datos(habilitado)
      end.to raise_error(AccionProhibidaException)

      expect(repositorio_pacientes.all.size).to eq(1)
      expect(repositorio_especialidades.all.size).to eq(1)
    end
  end
end
