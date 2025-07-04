require 'integration_helper'

require_relative '../../../dominio/turnero'
require_relative '../../stubs'

describe Turnero do
  include FeriadosStubs
  before(:each) do
    ENV['API_FERIADOS_URL'] = 'http://www.feriados-url.com'
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

  describe '- Capacidades de Feriados - ' do
    it 'obtener turnos disponibles de un médico dado que mañana es feriado me da turnos de pasado mañana' do
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      fecha_de_maniana = fecha_de_hoy + 1
      fecha_de_pasado_maniana = fecha_de_hoy + 2
      cuando_pido_los_feriados(fecha_de_maniana.year, [fecha_de_maniana])

      turnos = turnero.obtener_turnos_disponibles('NAC456')

      expect(turnos).to eq([Horario.new(fecha_de_pasado_maniana, Hora.new(8, 0)),
                            Horario.new(fecha_de_pasado_maniana, Hora.new(8, 30)),
                            Horario.new(fecha_de_pasado_maniana, Hora.new(9, 0)),
                            Horario.new(fecha_de_pasado_maniana, Hora.new(9, 30)),
                            Horario.new(fecha_de_pasado_maniana, Hora.new(10, 0))])
    end

    it 'obtener turnos disponibles de un médico dado que hoy es feriado me da los turnos de mañana' do
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      fecha_de_maniana = fecha_de_hoy + 1
      cuando_pido_los_feriados(fecha_de_hoy.year, [fecha_de_hoy])

      turnos = turnero.obtener_turnos_disponibles('NAC456')

      expect(turnos).to eq([Horario.new(fecha_de_maniana, Hora.new(8, 0)),
                            Horario.new(fecha_de_maniana, Hora.new(8, 30)),
                            Horario.new(fecha_de_maniana, Hora.new(9, 0)),
                            Horario.new(fecha_de_maniana, Hora.new(9, 30)),
                            Horario.new(fecha_de_maniana, Hora.new(10, 0))])
    end

    it 'obtener turnos disponibles de un médico dado que mañana y pasado mañana me da turnos dentro de 3 días' do
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      fecha_de_maniana = fecha_de_hoy + 1
      fecha_de_pasado_maniana = fecha_de_hoy + 2
      fecha_dentro_de_3_dias = fecha_de_hoy + 3
      cuando_pido_los_feriados(fecha_de_hoy.year, [fecha_de_maniana, fecha_de_pasado_maniana])

      turnos = turnero.obtener_turnos_disponibles('NAC456')

      expect(turnos).to eq([Horario.new(fecha_dentro_de_3_dias, Hora.new(8, 0)),
                            Horario.new(fecha_dentro_de_3_dias, Hora.new(8, 30)),
                            Horario.new(fecha_dentro_de_3_dias, Hora.new(9, 0)),
                            Horario.new(fecha_dentro_de_3_dias, Hora.new(9, 30)),
                            Horario.new(fecha_dentro_de_3_dias, Hora.new(10, 0))])
    end

    it 'obtener turnos disponibles de un medico dado que hoy es viernes me da los del lunes siguiente' do
      convertidor_de_tiempo = ConvertidorDeTiempo.new('%Y-%m-%d', ':', '%-H:%M')

      fecha_viernes = Date.parse('13-06-2025')
      proveedor_double_viernes = class_double(Date, today: fecha_viernes)
      proveedor_de_fecha_viernes = ProveedorDeFecha.new(proveedor_double_viernes)

      turnero2 = described_class.new(repositorios,
                                     ProveedorDeFeriados.new(ENV['API_FERIADOS_URL'], logger),
                                     proveedor_de_fecha_viernes,
                                     proveedor_de_hora,
                                     convertidor_de_tiempo)

      turnero2.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      siguiente_lunes = fecha_viernes + 3
      cuando_pido_los_feriados(fecha_viernes.year, [])

      turnos = turnero2.obtener_turnos_disponibles('NAC456')

      expect(turnos).to include(Horario.new(siguiente_lunes, Hora.new(8, 0)))
    end

    it 'no se puede reservar un turno mañana si es feriado' do
      turnero.crear_medico('Pablo', 'Pérez', 'NAC456', especialidad.codigo)
      turnero.crear_paciente('robertito@mail.com', '123000', 'NAC456')
      fecha_de_maniana = fecha_de_hoy + 1
      cuando_pido_los_feriados(fecha_de_hoy.year, [fecha_de_maniana])

      expect do
        turnero.asignar_turno('NAC456', fecha_de_maniana.to_s, '8:00', '123000')
      end.to raise_error(TurnoFeriadoNoEsReservableException)
    end
  end
end
