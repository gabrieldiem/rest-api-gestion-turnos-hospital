class CIDMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    correlation_id = "cid:#{UUID.new.generate}"
    Thread.current[:cid] = correlation_id
    SematicLogger.tagged(correlation_id) do
      @app.call(env)
    end
  end
end
