Cuando('solicito la especificación de la API con estándar OpenAPI') do
  @response = Faraday.get('/openapi.json')
end

Entonces('la recibo exitosamente y sigue el estándar') do
  openapi = JSON.parse(@response.body)
  expect(@response.status).to eq 200
  expect(openapi['openapi']).to eq '3.0.0'
  expect(openapi['info']['title']).to eq 'Turnero Verde'
end

Entonces('la recibo exitosamente') do
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando('solicito la interfaz Swagger') do
  pending # Write code here that turns the phrase above into concrete actions
end
