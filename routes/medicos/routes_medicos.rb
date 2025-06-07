Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/medicos', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/error', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, './', '*.rb')].each { |file| require file }

module RoutesMedicos
  def self.registered(app)
    app.register RoutesResourceMedicos
    app.register RoutesResourceTurnosDisponibles
    app.register RoutesResourceTurnosReservados
  end
end
