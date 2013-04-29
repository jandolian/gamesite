express = require 'express'
http = require 'http'
async = require 'async'
path = require 'path'
stylus = require 'stylus'
assets = require 'connect-assets'

config = require 'nconf'
logger = require './logger'
{identity, generate_hex} = require './identity'

routes = require './routes'
version = require './routes/version'

errorHandler = (err, req, res, next) ->
  res.status 500
  res.render 'error', error: err

###
The webserver class.
###
class WebServer
  constructor: ->
    @app = express()

    @app.set('views', path.resolve(__dirname, '../views'))
    @app.set('view engine', 'jade')
    @app.use(express.methodOverride())
    @app.use(express.bodyParser())
    @app.use(stylus.middleware(path.resolve(__dirname, '../public')))
    @app.use(assets())
    @app.use(express.static(path.resolve(__dirname, '../public')));
    @app.use(express.favicon())
    @app.use(@app.router)
    @app.use(errorHandler)

    @app.locals.environment = @app.settings.env
    @setup_routes()

    @srv = http.createServer(@app)
    @srv.listen(config.get('port'))
    logger.info "Webserver is up at: http://0.0.0.0:#{config.get('port')}"

  ###
  Sets up the webserver routes.
  ###
  setup_routes: =>
    @app.get '/', routes.index
    @app.get '/version', version.display

module.exports = WebServer
