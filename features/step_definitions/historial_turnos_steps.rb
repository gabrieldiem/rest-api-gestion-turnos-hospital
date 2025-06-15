Dado('que hay {string} turnos reservados para {string}') do |cantidad_turnos, username|
  paciente = obtener_paciente_por_username(username)

  @fecha_de_hoy = Date.today

  hora_inicio = Time.parse('08:00')

  (1..cantidad_turnos.to_i).each do |i|
    fecha = Date.today + i
    hora = (hora_inicio + ((i - 1) * @duracion * 60)).strftime('%H:%M')
    turno = {
      fecha:,
      hora:
    }
    reservar_turno(turno, paciente[:dni], @matricula)
    expect(@response.status).to eq(201)
  end
end

Dado('{string} han sido asisitidos') do |cant_turnos|
  @cantidad_de_turnos_esperados = cant_turnos.to_i

  cant_turnos.to_i.times do |i|
    id_turno = @turno_ids[i]
    cargar_asistencia_turno(id_turno, @dni, true)
  end
end

Cuando('quiere ver su historial de turnos') do
  @respuesta = Faraday.get("/pacientes/#{@dni_registrado}/historial")
  @respuesta_parseada = JSON.parse(@respuesta.body, symbolize_names: true)
end

Entonces('debo ver un mensaje con la lista de mis turnos pasados y todos sus datos deben ser correctos') do
  expect(@respuesta.status).to eq(200)
  expect(@respuesta_parseada[:turnos]).to be_a(Array)
  expect(@respuesta_parseada[:turnos].empty?).to be false
  @respuesta_parseada[:turnos].each do |turno|
    expect(turno).to include(:fecha, :hora, :medico)
    expect(turno[:medico][:matricula]).to eq(@matricula)
    expect(turno[:medico][:nombre]).to eq(@medico_nombre)
    expect(turno[:medico][:apellido]).to eq(@medico_apellido)
    expect(turno[:medico][:especialidad]).to eq(@especialidad_codigo)
  end
  expect(@respuesta_parseada[:cantidad_de_turnos]).to eq(@cantidad_de_turnos_esperados)
end
