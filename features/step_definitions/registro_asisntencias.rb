Dado('que existe un paciente con DNI {string}') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('existe un turno con ID {string} para ese paciente') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando('envío los datos de asistencia con DNI {string}, ID de turno {string} y asistencia {string}') do |_string, _string2, _string3|
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces('el estado del turno queda como {string}') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('ya está registrada la asistencia para este turno como {string}') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Cuando('envío los datos actualizados con DNI {string}, ID de turno {string} y asistencia {string}') do |_string, _string2, _string3|
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces('el estado del turno queda actualizado como {string}') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que no existe un paciente con DNI {string}') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces('recibo un mensaje de error indicando que el paciente no existe') do
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('no existe un turno con ID {string}') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces('recibo un mensaje de error indicando que el turno no existe') do
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('existe un paciente con DNI {string}') do |_string|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('existe un turno con ID {string} asignado al paciente con DNI {string}') do |_string, _string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Entonces('recibo un mensaje de error indicando que el turno no pertenece a ese paciente') do
  pending # Write code here that turns the phrase above into concrete actions
end
