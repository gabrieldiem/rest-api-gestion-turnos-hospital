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
  swagger_html = @response.body
  expect(@response.status).to eq 200
  expect(swagger_html).to include('SwaggerUI')
end

Cuando('solicito la interfaz Swagger') do
  @response = Faraday.get('/swagger')
end
