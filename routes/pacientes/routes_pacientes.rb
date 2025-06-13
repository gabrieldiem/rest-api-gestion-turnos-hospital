Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/pacientes', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/error', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, './', '*.rb')].each { |file| require file }

module RoutesPacientes
  def self.registered(app)
    app.register RoutesResourcePacientes
    app.register RoutesResourceTurnosReservadosPacientes
  end
end
