require 'integration_helper'

require_relative '../../dominio/turnero'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/medico'
require_relative '../../dominio/calendario_de_turnos'

require_relative '../../persistencia/repositorio_especialidades'
require_relative '../../persistencia/repositorio_medicos'
require_relative '../../lib/proveedor_de_fecha'
require_relative '../stubs'

describe CalendarioDeTurnos do
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
  let(:repositorio_especialidades) { RepositorioEspecialidades.new(logger) }
  let(:repositorio_medicos) { RepositorioMedicos.new(logger) }
  let(:repositorio_pacientes) { RepositorioPacientes.new(logger) }
  let(:repositorio_turnos) { RepositorioTurnos.new(logger) }
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
  let(:proveedor_de_feriados) do
    ProveedorDeFeriados.new(api_feriados_url, logger)
  end
  let(:especialidad) do
    especialidad = Especialidad.new('Cardiología', 30, 5, 'card')
    repositorio_especialidades.save especialidad
    especialidad
  end

  let(:medico) do
    medico = Medico.new('Pablo', 'Pérez', 'NAC456', especialidad)
    repositorio_medicos.save medico
    medico
  end

  it 'obtener turnos disponibles de un médico' do
    fecha_de_maniana = fecha_de_hoy + 1
    calculador_de_turnos_libres = described_class.new(Hora.new(8, 0), Hora.new(18, 0),
                                                      proveedor_de_fecha, proveedor_de_hora, proveedor_de_feriados)

    turnos = calculador_de_turnos_libres.calcular_turnos_disponibles_por_medico medico

    expect(turnos).to eq([Horario.new(fecha_de_maniana, Hora.new(8, 0)),
                          Horario.new(fecha_de_maniana, Hora.new(8, 30)),
                          Horario.new(fecha_de_maniana, Hora.new(9, 0)),
                          Horario.new(fecha_de_maniana, Hora.new(9, 30)),
                          Horario.new(fecha_de_maniana, Hora.new(10, 0))])
  end

  it 'actualiza los proveedores de fecha y hora correctamente' do
    calculador = described_class.new(Hora.new(8, 0), Hora.new(18, 0),
                                     proveedor_de_fecha, proveedor_de_hora, proveedor_de_feriados)

    nuevo_proveedor_fecha_double = class_double(Date, today: Date.new(2030, 1, 1))
    nuevo_proveedor_hora_double = class_double(Time, now: DateTime.new(2030, 1, 1, 12, 0))

    nuevo_proveedor_de_fecha = ProveedorDeFecha.new(nuevo_proveedor_fecha_double)
    nuevo_proveedor_de_hora = ProveedorDeHora.new(nuevo_proveedor_hora_double)

    calculador.actualizar_proveedores_de_fecha_hora(nuevo_proveedor_de_fecha, nuevo_proveedor_de_hora)

    expect(calculador.fecha_actual).to eq(Date.new(2030, 1, 1))
    expect(calculador.hora_actual).to eq(Hora.new(12, 0))
  end




  it 'obtener turnos disponibles dado que ya se asigno un turno' do
    paciente = Paciente.new('j@perez.com', '999999999', 'juanperez', 1)
    repositorio_pacientes.save paciente

    calculador_de_turnos_libres = described_class.new(Hora.new(8, 0), Hora.new(18, 0),
                                                      proveedor_de_fecha, proveedor_de_hora, proveedor_de_feriados)
    fecha_de_maniana = fecha_de_hoy + 1

    turno = medico.asignar_turno(Horario.new(fecha_de_maniana, Hora.new(8, 0)), paciente)
    repositorio_turnos.save turno

    turnos = calculador_de_turnos_libres.calcular_turnos_disponibles_por_medico medico
    expect(turnos).to eq([Horario.new(fecha_de_maniana, Hora.new(8, 30)),
                          Horario.new(fecha_de_maniana, Hora.new(9, 0)),
                          Horario.new(fecha_de_maniana, Hora.new(9, 30)),
                          Horario.new(fecha_de_maniana, Hora.new(10, 0)),
                          Horario.new(fecha_de_maniana, Hora.new(10, 30))])
  end

  def cantidad_turnos_en_un_dia(hora_inicio_jornada, hora_fin_jornada, duracion_turno)
    minutos_totales_de_jornada = (hora_fin_jornada.hora - hora_inicio_jornada.hora) * 60
    minutos_totales_de_jornada += hora_fin_jornada.minutos - hora_inicio_jornada.minutos
    minutos_totales_de_jornada / duracion_turno
  end

  def asignar_un_turno(hora_a_asignar, fecha_a_llenar, paciente)
    repositorio_pacientes.save paciente
    turno = medico.asignar_turno(Horario.new(fecha_a_llenar, hora_a_asignar), paciente)
    repositorio_turnos.save turno
  end

  def llenar_turnos_de_un_dia(fecha_a_llenar, duracion_turno)
    dni = '100_'
    hora_inicio_jornada = Hora.new(8, 0)
    hora_fin_jornada = Hora.new(18, 0)
    cantidad_turnos = cantidad_turnos_en_un_dia(hora_inicio_jornada, hora_fin_jornada, duracion_turno)

    hora_a_asignar = hora_inicio_jornada

    cantidad_turnos.times do |i|
      hora_a_asignar += Hora.new(0, duracion_turno) if i != 0
      nuevo_dni = "#{dni}+#{i}"
      paciente = Paciente.new("j+#{i}@perez.com", nuevo_dni, "juanperez+#{i}", 1)
      asignar_un_turno(hora_a_asignar, fecha_a_llenar, paciente)
    end
  end

  it 'obtener turnos disponibles del 12/06 dado que hoy es 10/06 y no hay turnos disponibles el 11/06' do
    fecha_de_maniana = fecha_de_hoy + 1
    fecha_de_pasado_maniana = fecha_de_hoy + 2

    llenar_turnos_de_un_dia(fecha_de_maniana, especialidad.duracion)

    calculador_de_turnos_libres = described_class.new(Hora.new(8, 0), Hora.new(18, 0),
                                                      proveedor_de_fecha, proveedor_de_hora, proveedor_de_feriados)

    turnos = calculador_de_turnos_libres.calcular_turnos_disponibles_por_medico medico
    expect(turnos).to eq([Horario.new(fecha_de_pasado_maniana, Hora.new(8, 0)),
                          Horario.new(fecha_de_pasado_maniana, Hora.new(8, 30)),
                          Horario.new(fecha_de_pasado_maniana, Hora.new(9, 0)),
                          Horario.new(fecha_de_pasado_maniana, Hora.new(9, 30)),
                          Horario.new(fecha_de_pasado_maniana, Hora.new(10, 0))])
  end

  it 'obtener turnos disponibles de un médico dado que mañana es feriado me da turnos de pasado mañana' do
    fecha_de_maniana = fecha_de_hoy + 1
    fecha_de_pasado_maniana = fecha_de_hoy + 2
    cuando_pido_los_feriados(fecha_de_maniana.year, [fecha_de_maniana])

    calculador_de_turnos_libres = described_class.new(Hora.new(8, 0), Hora.new(18, 0),
                                                      proveedor_de_fecha, proveedor_de_hora, proveedor_de_feriados)

    turnos = calculador_de_turnos_libres.calcular_turnos_disponibles_por_medico medico

    expect(turnos).to eq([Horario.new(fecha_de_pasado_maniana, Hora.new(8, 0)),
                          Horario.new(fecha_de_pasado_maniana, Hora.new(8, 30)),
                          Horario.new(fecha_de_pasado_maniana, Hora.new(9, 0)),
                          Horario.new(fecha_de_pasado_maniana, Hora.new(9, 30)),
                          Horario.new(fecha_de_pasado_maniana, Hora.new(10, 0))])
  end

  it 'un horario es invalido cuando no es múltiplo de la duración' do
    hora_a_chequear = Hora.new(8, 1)

    calculador_de_turnos_libres = described_class.new(Hora.new(8, 0), Hora.new(18, 0),
                                                      proveedor_de_fecha, proveedor_de_hora, proveedor_de_feriados)
    duracion_turno = medico.especialidad.duracion
    expect(calculador_de_turnos_libres.es_hora_un_slot_valido(duracion_turno, hora_a_chequear)).to be false
  end

  it 'un horario es valido cuando es múltiplo de la duración' do
    hora_a_chequear = Hora.new(8, 30)

    calculador_de_turnos_libres = described_class.new(Hora.new(8, 0), Hora.new(18, 0),
                                                      proveedor_de_fecha, proveedor_de_hora, proveedor_de_feriados)
    duracion_turno = medico.especialidad.duracion
    expect(calculador_de_turnos_libres.es_hora_un_slot_valido(duracion_turno, hora_a_chequear)).to be true
  end

  it 'obtener turnos disponibles de un médico dado que mañana es sabado me da turnos del siguiente lunes' do
    fecha_viernes = Date.parse('13-06-2025')
    fecha_de_siguiente_lunes = fecha_viernes + 3
    cuando_pido_los_feriados(fecha_viernes.year, [])
    proveedor_double = class_double(Date, today: fecha_viernes)
    proveedor_de_fecha_viernes = ProveedorDeFecha.new(proveedor_double)

    calculador_de_turnos_libres = described_class.new(Hora.new(8, 0), Hora.new(18, 0),
                                                      proveedor_de_fecha_viernes, proveedor_de_hora, proveedor_de_feriados)

    turnos = calculador_de_turnos_libres.calcular_turnos_disponibles_por_medico medico

    expect(turnos).to eq([Horario.new(fecha_de_siguiente_lunes, Hora.new(8, 0)),
                          Horario.new(fecha_de_siguiente_lunes, Hora.new(8, 30)),
                          Horario.new(fecha_de_siguiente_lunes, Hora.new(9, 0)),
                          Horario.new(fecha_de_siguiente_lunes, Hora.new(9, 30)),
                          Horario.new(fecha_de_siguiente_lunes, Hora.new(10, 0))])
  end
end
