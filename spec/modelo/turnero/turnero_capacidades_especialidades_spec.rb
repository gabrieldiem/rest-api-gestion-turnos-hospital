require 'integration_helper'

require_relative '../../../dominio/turnero'

describe Turnero do
  before(:each) do
    ENV['API_FERIADOS_URL'] = 'http://www.feriados-url.com'
  end

  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end
  let(:repositorio_especialidades) { RepositorioEspecialidades.new(logger) }
  let(:repositorios) do
    RepositoriosTurnero.new(RepositorioPacientes.new(logger),
                            repositorio_especialidades,
                            RepositorioMedicos.new(logger),
                            RepositorioTurnos.new(logger))
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
  let(:turnero) do
    convertidor_de_tiempo = ConvertidorDeTiempo.new('%Y-%m-%d', ':', '%-H:%M')
    described_class.new(repositorios,
                        ProveedorDeFeriados.new(ENV['API_FERIADOS_URL'], logger),
                        proveedor_de_fecha,
                        proveedor_de_hora,
                        convertidor_de_tiempo)
  end
  let(:especialidad) { turnero.crear_especialidad('Cardiología', 30, 5, 'card') }

  describe '- Capacidades de Especialidades - ' do
    it 'crea una especialidad nuevo' do
      especialidad_nuevo = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      expect(especialidad_nuevo).to have_attributes(nombre: 'Cardiología', duracion: 30, recurrencia_maxima: 5, codigo: 'card')
    end

    it 'crea una especialidad nuevo y lo guarda en el repositorio' do
      especialidad_nuevo = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      especialidad_guardada = repositorio_especialidades.all.first
      expect(repositorio_especialidades.all.size).to eq(1)
      expect(especialidad_guardada).to have_attributes(nombre: especialidad_nuevo.nombre, duracion: especialidad_nuevo.duracion, recurrencia_maxima: especialidad_nuevo.recurrencia_maxima,
                                                       codigo: especialidad_nuevo.codigo)
    end

    it 'obtener todas las especialidades' do
      especialidad_una = turnero.crear_especialidad('Cardiología', 30, 5, 'card')
      especialidad_dos = turnero.crear_especialidad('Pediatría', 20, 3, 'pedi')
      especialidad_tres = turnero.crear_especialidad('Cirugía', 60, 2, 'ciru')

      especialidades = turnero.obtener_especialidades
      expect(especialidades.size).to eq(3)
      expect(especialidades).to include(
        have_attributes(nombre: especialidad_una.nombre, duracion: especialidad_una.duracion, recurrencia_maxima: especialidad_una.recurrencia_maxima,
                        codigo: especialidad_una.codigo),
        have_attributes(nombre: especialidad_dos.nombre, duracion: especialidad_dos.duracion, recurrencia_maxima: especialidad_dos.recurrencia_maxima,
                        codigo: especialidad_dos.codigo),
        have_attributes(nombre: especialidad_tres.nombre, duracion: especialidad_tres.duracion, recurrencia_maxima: especialidad_tres.recurrencia_maxima,
                        codigo: especialidad_tres.codigo)
      )
    end

    it 'no se pueden crear dos especialidades con el mismo código' do
      turnero.crear_especialidad('Cardiología', 30, 5, 'card')

      expect do
        turnero.crear_especialidad('Cardiología2', 45, 2, 'card')
      end.to raise_error(EspecialidadDuplicadaException)
    end
  end
end
