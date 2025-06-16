Dado('que hay {string} turnos reservados para {string}') do |cantidad_turnos, username|
  @paciente = obtener_paciente_por_username(username)

  reservar_turnos(@matricula, @paciente[:dni], cantidad_turnos.to_i)
end

Dado('{string} han sido asisitidos') do |cant_turnos|
  @turnos_pasados = []

  cant_turnos.to_i.times do |i|
    id_turno = @turno_ids[i]
    @turnos_pasados << cargar_asistencia_turno(id_turno, @paciente[:dni], true)
  end
end

Cuando('quiere ver su historial de turnos') do
  @respuesta = Faraday.get("/pacientes/#{@paciente[:dni]}/historial")
  @respuesta_parseada = JSON.parse(@respuesta.body, symbolize_names: true)
end

Entonces('debo ver un mensaje con la lista de mis turnos pasados y todos sus datos deben ser correctos') do
  expect(@respuesta.status).to eq(200)
  expect(@respuesta_parseada[:turnos]).to be_a(Array)
  expect(@respuesta_parseada[:turnos].length).to eq(@turnos_pasados.length)

  @respuesta_parseada[:turnos].each_with_index do |turno, i|
    turno_esperado = @turnos_pasados[i]
    expect(turno[:fecha]).to eq(turno_esperado[:fecha])
    expect(turno[:hora]).to eq(turno_esperado[:hora])
    expect(turno[:medico][:matricula]).to eq(turno_esperado[:medico][:matricula])
    expect(turno[:medico][:nombre]).to eq(turno_esperado[:medico][:nombre])
    expect(turno[:medico][:apellido]).to eq(turno_esperado[:medico][:apellido])
    expect(turno[:medico][:especialidad]).to eq(turno_esperado[:medico][:especialidad])
  end
  expect(@respuesta_parseada[:cantidad_de_turnos]).to eq(@turnos_pasados.length)
end
