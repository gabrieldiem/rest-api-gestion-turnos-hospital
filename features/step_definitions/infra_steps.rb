Cuando('pido \/version') do
  get '/version'
end

Entonces('obtengo la version app') do
  expect(last_response.status).to be == 200
  expect(JSON.parse(last_response.body)['version']).to eq Version.current
end

Entonces('obtengo una respuesta de tipo json') do
  expect(last_response.headers['Content-Type']).to eq 'application/json'
end
