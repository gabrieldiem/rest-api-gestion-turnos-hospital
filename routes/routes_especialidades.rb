Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }

module RoutesEspecialidades
  def self.registered(app)
    app.get '/especialidades' do
      logger.debug('GET /especialidades')
      especialidades = turnero.obtener_especialidades

      status 200
      {
        cantidad_total: especialidades.size,
        especialidades: especialidades.map do |especialidad|
          {
            id: especialidad.id,
            nombre: especialidad.nombre,
            duracion: especialidad.duracion,
            recurrencia_maxima: especialidad.recurrencia_maxima,
            codigo: especialidad.codigo,
            created_on: especialidad.created_on
          }
        end
      }.to_json
    end

    app.post '/especialidades' do
      logger.debug("POST /especialidades con params: #{@params}")
      especialidad = turnero.crear_especialidad(@params[:nombre].to_s,
                                                @params[:duracion].to_i,
                                                @params[:recurrencia_maxima].to_i,
                                                @params[:codigo].to_s)

      status 201
      {
        id: especialidad.id,
        nombre: especialidad.nombre,
        duracion: especialidad.duracion,
        recurrencia_maxima: especialidad.recurrencia_maxima,
        codigo: especialidad.codigo,
        created_on: especialidad.created_on
      }.to_json
    end
  end
end
