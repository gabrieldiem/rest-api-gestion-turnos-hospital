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

  describe '- Capacidades de Pacientes - ' do
    it 'crea un paciente nuevo valido' do
      paciente = turnero.crear_paciente('juan.perez@example.com', '12345678', 'juanperez')

      expect(paciente).to have_attributes(email: 'juan.perez@example.com', dni: '12345678', username: 'juanperez', reputacion: 1.0)
    end

    it 'crea un paciente nuevo y lo guarda en el repositorio' do
      paciente = turnero.crear_paciente('juan.perez@example.com', '12345678', 'juanperez')

      paciente_guardado = repositorio_pacientes.all.first
      expect(repositorio_pacientes.all.size).to eq(1)
      expect(paciente_guardado).to have_attributes(email: paciente.email, dni: paciente.dni, username: paciente.username, reputacion: paciente.reputacion)
    end

    it 'no se puede crear un paciente con DNI repetido' do
      dni = '12345678'
      _paciente_valido = turnero.crear_paciente('gabriel.dominguez@example.com', dni, 'gabrieldominguez')

      expect do
        turnero.crear_paciente('juan.perez@example.com', dni, 'juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se puede crear un paciente con email sin arroba (@)' do
      expect do
        turnero.crear_paciente('juan.perezexample.com', '12345678', 'juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se puede crear un paciente con email sin dominio' do
      expect do
        turnero.crear_paciente('juan.perez@example', '12345678', 'juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se puede crear un paciente con email vacio' do
      expect do
        turnero.crear_paciente('', '12345678', 'juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se puede crear un paciente con DNI vacio' do
      expect do
        turnero.crear_paciente('juan.perez@example.com', '', 'juanperez')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'no se puede crear un paciente con username vacio' do
      expect do
        turnero.crear_paciente('juan.perez@example.com', '12345678', '')
      end.to raise_error(ActiveModel::ValidationError)
    end

    it 'se obtiene un paciente por username' do
      paciente = turnero.crear_paciente('juan.perez@example.com', '12345678', 'juanperez')
      paciente_encontrado = turnero.buscar_paciente_por_username('juanperez')
      expect(paciente_encontrado).to have_attributes(email: paciente.email, dni: paciente.dni, username: paciente.username, reputacion: paciente.reputacion)
    end

    it 'no se encuentra un paciente por username inexistente' do
      expect do
        turnero.buscar_paciente_por_username('noexiste')
      end.to raise_error(PacienteInexistenteException)
    end

    it 'no se encuentra un paciente por username vacio' do
      expect do
        turnero.buscar_paciente_por_username('')
      end.to raise_error(PacienteInexistenteException)
    end

    it 'se obtiene un paciente por dni' do
      paciente = turnero.crear_paciente('juan.perez@example.com', '12345678', 'juanperez')
      paciente_encontrado = turnero.buscar_paciente_por_dni('12345678')
      expect(paciente_encontrado).to have_attributes(email: paciente.email, dni: paciente.dni, username: paciente.username, reputacion: paciente.reputacion)
    end

    it 'no se encuentra un paciente por dni inexistente' do
      expect do
        turnero.buscar_paciente_por_dni('noexiste')
      end.to raise_error(PacienteInexistenteException)
    end
  end
end
