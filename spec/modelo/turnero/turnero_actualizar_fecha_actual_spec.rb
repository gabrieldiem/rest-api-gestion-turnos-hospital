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
require_relative '../../../dominio/exceptions/paciente_invalido_exception'
require_relative '../../../dominio/exceptions/recurrencia_maxima_alcanzada_exception'
require_relative '../../../dominio/exceptions/turno_invalido_exception'
require_relative '../../../dominio/exceptions/reputacion_invalida_exception'
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
    RepositoriosTurnero.new(RepositorioPacientes.new(logger),
                            RepositorioEspecialidades.new(logger),
                            RepositorioMedicos.new(logger),
                            RepositorioTurnos.new(logger))
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
  let(:medico) { turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo) }
  let(:paciente) { turnero.crear_paciente('paciente@test.com', '999999999', 'paciente_test') }

  describe '- Cambiar la fecha actual del turnero - ' do
    xit 'actualiza la fecha actual y obtiene los turnos disponibles del médico' do
      # Actualizar la fecha actual a 2030-01-01 y hora a 12:00
      nuevo_proveedor_fecha = ProveedorDeFecha.new(class_double(Date, today: Date.new(2030, 1, 1)))
      nuevo_proveedor_hora = ProveedorDeHora.new(class_double(Time, now: DateTime.new(2030, 1, 1, 12, 0)))
      turnero.actualizar_fecha_actual(true, nuevo_proveedor_fecha, nuevo_proveedor_hora)

      turnos = turnero.obtener_turnos_disponibles('NAC456')
      # Espera que los turnos sean para el día siguiente a la fecha actual (según tu lógica de calendario)
      fecha_de_maniana = Date.new(2030, 1, 2)
      horarios_esperados = [
        Horario.new(fecha_de_maniana, Hora.new(8, 0)),
        Horario.new(fecha_de_maniana, Hora.new(8, 30)),
        Horario.new(fecha_de_maniana, Hora.new(9, 0)),
        Horario.new(fecha_de_maniana, Hora.new(9, 30)),
        Horario.new(fecha_de_maniana, Hora.new(10, 0))
      ]
      expect(turnos).to include(*horarios_esperados)
    end
  end
end
