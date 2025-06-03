require 'integration_helper'

require_relative '../../dominio/turnero'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/medico'
require_relative '../../dominio/calculador_de_turnos_libres'

require_relative '../../persistencia/repositorio_especialidades'
require_relative '../../persistencia/repositorio_medicos'
require_relative '../../lib/proveedor_de_fecha'

describe CalculadorDeTurnosLibres do
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
    calculador_de_turnos_libres = described_class.new(Hora.new(8, 0),
                                                      Hora.new(18, 0),
                                                      proveedor_de_fecha,
                                                      proveedor_de_hora)

    turnos = calculador_de_turnos_libres.calcular_turnos_disponibles_por_medico medico

    expect(turnos).to eq([Horario.new(fecha_de_maniana, Hora.new(8, 0)),
                          Horario.new(fecha_de_maniana, Hora.new(8, 30)),
                          Horario.new(fecha_de_maniana, Hora.new(9, 0)),
                          Horario.new(fecha_de_maniana, Hora.new(9, 30)),
                          Horario.new(fecha_de_maniana, Hora.new(10, 0))])
  end

  it 'obtener turnos disponibles dado que ya se asigno un turno' do
    paciente = Paciente.new('j@perez.com', '999999999', 'juanperez')
    repositorio_pacientes.save paciente

    calculador_de_turnos_libres = described_class.new(Hora.new(8, 0),
                                                      Hora.new(18, 0),
                                                      proveedor_de_fecha,
                                                      proveedor_de_hora)
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
      paciente = Paciente.new("j+#{i}@perez.com", nuevo_dni, "juanperez+#{i}")
      asignar_un_turno(hora_a_asignar, fecha_a_llenar, paciente)
    end
  end

  it 'obtener turnos disponibles del 12/06 dado que hoy es 10/06 y no hay turnos disponibles el 11/06' do
    fecha_de_maniana = fecha_de_hoy + 1
    fecha_de_pasado_maniana = fecha_de_hoy + 2

    llenar_turnos_de_un_dia(fecha_de_maniana, especialidad.duracion)

    calculador_de_turnos_libres = described_class.new(Hora.new(8, 0),
                                                      Hora.new(18, 0),
                                                      proveedor_de_fecha,
                                                      proveedor_de_hora)

    turnos = calculador_de_turnos_libres.calcular_turnos_disponibles_por_medico medico
    expect(turnos).to eq([Horario.new(fecha_de_pasado_maniana, Hora.new(8, 0)),
                          Horario.new(fecha_de_pasado_maniana, Hora.new(8, 30)),
                          Horario.new(fecha_de_pasado_maniana, Hora.new(9, 0)),
                          Horario.new(fecha_de_pasado_maniana, Hora.new(9, 30)),
                          Horario.new(fecha_de_pasado_maniana, Hora.new(10, 0))])
  end
end
