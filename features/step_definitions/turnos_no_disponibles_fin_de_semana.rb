def crear_medico_test(matricula)
  especialidad_body = { nombre: 'Kinesiologia', duracion: 20, recurrencia_maxima: 5, codigo: 'kine' }
  Faraday.post('/especialidades', especialidad_body.to_json, 'Content-Type' => 'application/json')

  medico_body = {
    nombre: 'Juan',
    apellido: 'Perez',
    matricula:,
    especialidad: 'kine'
  }
  Faraday.post('/medicos', medico_body.to_json, 'Content-Type' => 'application/json')
end

def obtener_fecha_a_partir_de_dia(dia)
  fechas = {
    "lunes": '09-06-2025',
    "martes": '10-06-2025',
    "miércoles": '11-06-2025',
    "jueves": '12-06-2025',
    "viernes": '13-06-2025',
    "sábado": '14-06-2025',
    "domingo": '15-06-2025',
    "lunes_feriado": '16-06-2025'
  }
  fechas[dia.to_sym]
end

def traducir_dia_al_ingles(dia)
  traducciones = {
    'lunes' => 'Monday',
    'martes' => 'Tuesday',
    'miércoles' => 'Wednesday',
    'jueves' => 'Thursday',
    'viernes' => 'Friday',
    'sábado' => 'Saturday',
    'domingo' => 'Sunday'
  }

  traducciones[dia]
end

Dado('que estoy consultando turnos disponibles') do
  crear_medico_test('MP9876')
  cuando_pido_los_feriados(2025, [])
  response = Faraday.get('/medicos/MP9876/turnos-disponibles')
  @parsed_response = JSON.parse(response.body)
  expect(response.status).to eq(200)
end

Cuando('consulto los turnos un {string}') do |dia|
  fecha = Date.parse(obtener_fecha_a_partir_de_dia(dia))
  allow(Date).to receive(:today).and_return(fecha)
  response = Faraday.get('/medicos/MP9876/turnos-disponibles')
  @turnos_response = JSON.parse(response.body)
  expect(response.status).to eq(200)
end

Entonces('el turnero me muestra los turnos disponibles para el {string} siguiente') do |dia_siguiente|
  fecha_recibida_turnos = @turnos_response['turnos'][0]['fecha']
  expect(Date.parse(fecha_recibida_turnos).strftime('%A')).to eq(traducir_dia_al_ingles(dia_siguiente))
end

Cuando('consulto los turnos un {string} y el {string} siguiente es feriado') do |dia, feriado|
  fecha = Date.parse(obtener_fecha_a_partir_de_dia(dia))
  fecha_feriado = Date.parse(obtener_fecha_a_partir_de_dia("#{feriado}_feriado"))
  allow(Date).to receive(:today).and_return(fecha)
  cuando_pido_los_feriados(fecha.year, [fecha_feriado])
  response = Faraday.get('/medicos/MP9876/turnos-disponibles')
  @turnos_response = JSON.parse(response.body)
  expect(response.status).to eq(200)
end
