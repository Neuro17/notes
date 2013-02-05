//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Jan 08, 2013 12:08:05 PM
// Author: tomyeh
part of stream;

/**
 * Stream server.
 *
 * ##Start a server serving static resources only
 *
 *     new StreamServer().run();
 *
 * ##Start a full-featured server
 *
 *     new StreamServer({ //URI mapping
 *         "/your-uri-in-regex": yourHandler
 *       },[ //Error mapping
 *         [404, "/webapp/404.html"]
 *       ]).run();
 *  )
 */
abstract class StreamServer {
  /** Constructor.
   *
   * ##Request Handlers
   *
   * A request handler is responsible for handling a request. It is mapped
   * to particular URI patterns with [uriMapping].
   *
   * The first argument of a handler must be [HttpConnect]. It can have optional
   * arguments. If it renders the response, it doesn't need to return anything
   * (i.e., `void`). If not, it shall return an URI (which is a non-empty string,
   * starting with * `/`) that the request shall be forwarded to.
   *
   * * [uriMapping] - a map of URI mappings, `<String uri, Function handler>`. 
   * * [errorMapping] - a list of pairs of error mappings. Each pair is
   * `[int statusCode, String uri]`.
   */
  factory StreamServer({Map<String, Function> uriMapping,
    List<List> errorMapping, String homeDir,
    LoggingConfigurer loggingConfigurer})
  => new _StreamServer(uriMapping, errorMapping, homeDir, loggingConfigurer);

  /** The version.
   */
  String get version;
  /** The path of the home directory.
   */
  Path get homeDir;
  /** A list of names that will be used to locate the resource if
   * the given path is a directory.
   *
   * Default: `[index.html]`
   */
  List<String> get indexNames;

  /** The port. Default: 8080.
   */
  int port;
  /** The host. Default: "127.0.0.1".
   */
  String host;

  /** The timeout, in seconds, for sessions of this server.
   * Default: 1200 (unit: seconds)
   */
  int sessionTimeout;

  /** Indicates whether the server is running.
   */
  bool get isRunning;
  /** Starts the server
   *
   * If [serverSocket] is given (not null), it will be used ([host] and [port])
   * will be ignored. In additions, the socket won't be closed when the
   * server stops.
   */
  void run([ServerSocket socket]);
  /** Stops the server.
   */
  void stop();

  /** Forward the given [connect] to the given [uri].
   *
   * If [request] or [response] is ignored, [connect] is assumed.
   *
   * After calling this method, the caller shall not write the output stream, since the
   * request handler for the given URI might handle it asynchronously. Rather, it
   * shall make it a closure and pass it to the [success] argument. Then,
   * it will be resumed once the forwarded handler has completed.
   *
   * ##Difference between [forward] and [include]
   *
   * [forward] and [include] are almost the same, except
   *
   * * The included request handler shall not generate any HTTP headers (it is the job of the caller).
   *
   * * The request handler that invokes [forward] shall not call `connect.close` (it is the job
   * of the callee -- the forwarded request handler).
   */
  void forward(HttpConnect connect, String uri, {Handler success,
    HttpRequest request, HttpResponse response});
  /** Includes the given [uri].
   * If you'd like to include a request handler (i.e., a function), use [connectForInclusion]
   * instead.
   *
   * If [request] or [response] is ignored, [connect] is assumed.
   *
   * After calling this method, the caller shall not write the output stream, since the
   * request handler for the given URI might handle it asynchronously. Rather, it
   * shall make it a closure and pass it to the [success] argument. Then,
   * it will be resumed once the included handler has completed.
   *
   * ##Difference between [forward] and [include]
   *
   * [forward] and [include] are almost the same, except
   *
   * * The included request handler shall not generate any HTTP headers (it is the job of the caller).
   *
   * * The request handler that invokes [forward] shall not call `connect.close` (it is the job
   * of the callee -- the included request handler).
   */
  void include(HttpConnect connect, String uri, {Handler success,
    HttpRequest request, HttpResponse response});
  /** Gets the HTTP connect for inclusion.
   * If you'd like to include from URI, use [include] instead.
   * This method is used for including a request handler. For example
   *
   *     fooHandler(connectForInclusion(connect, success: () {continueToDo();}));
   */
  HttpConnect connectForInclusion(HttpConnect connect, {String uri, Handler success,
    HttpRequest request, HttpResponse response});

  /** The resource loader used to load the static resources.
   * It is called if the path of a request doesn't match any of the URL
   * mapping given in the constructor.
   */
  ResourceLoader resourceLoader;

  /** The error mapping to map the status code to URI for displaying
   * the error.
   */
  Map<int, String> get errorMapping;
  /** The error handler. Default: null.
   */
  ConnectErrorHandler onError;
  /** The logger for logging information.
   * The default level is `INFO`.
   */
  Logger get logger;
}
/** A generic server error.
 */
class ServerError implements Error {
  final String message;

  ServerError(String this.message);
  String toString() => "ServerError($message)";
}

///The implementation
class _StreamServer implements StreamServer {
  final String version = "0.5.1";
  final HttpServer _server;
  String _host = "127.0.0.1";
  int _port = 8080;
  int _sessTimeout = 20 * 60; //20 minutes
  final Logger logger;
  Path _homeDir;
  final List<_Mapping> _uriMapping = [];
  ResourceLoader _resLoader;
  ConnectErrorHandler _cxerrh;
  bool _running = false;

  _StreamServer(Map<String, Function> uriMapping,
    List<List> errorMapping, String homeDir,
    LoggingConfigurer loggingConfigurer)
    : _server = new HttpServer(), logger = new Logger("stream") {
    (loggingConfigurer != null ? loggingConfigurer: new LoggingConfigurer())
      .configure(logger);
    _init();
    _initDir(homeDir);
    _initMapping(uriMapping, errorMapping);
  }
  void _init() {
    _cxerrh = (HttpConnect cnn, err, [st]) {
      _handleErr(cnn, err, st);
    };
    final server = "Rikulo Stream $version";
    _server.defaultRequestHandler =
      (HttpRequest req, HttpResponse res) {
        res.headers
          ..add(HttpHeaders.SERVER, server)
          ..date = new DateTime.now();
        _handle(
          new _HttpConnect(this, req, res, _cxerrh)
            ..on.close.add((){res.outputStream.close();}));
      };
    _server.onError = (err) {
      _handleErr(null, err);
    };
  }
  void _initDir(String homeDir) {
    var path;
    if (homeDir != null) {
      path = new Path(homeDir);
    } else {
      homeDir = new Options().script;
      path = homeDir != null ? new Path(homeDir).directoryPath: new Path("");
    }

    if (!path.isAbsolute)
      path = new Path(new Directory.current().path).join(path);

    //look for webapp
    for (final orgpath = path;;) {
      final nm = path.filename;
      path = path.directoryPath;
      if (nm == "webapp")
        break; //found and we use its parent as homeDir
      final ps = path.toString();
      if (ps.isEmpty || ps == "/")
        throw new ServerError(
          "The application must be under the webapp directory, not ${orgpath.toNativePath()}");
    }

    _homeDir = path;
    if (!new Directory.fromPath(_homeDir).existsSync())
      throw new ServerError("$homeDir doesn't exist.");
    _resLoader = new ResourceLoader(_homeDir);
  }
  void _initMapping(Map<String, Function> uriMapping, List<List> errorMapping) {
    if (uriMapping != null)
      for (final uri in uriMapping.keys) {
        if (!uri.startsWith("/"))
          throw new ServerError("URI must start with '/': $uri");
        final hd = uriMapping[uri];
        if (hd is! Function)
          throw new ServerError("Function is required for $uri");
        _uriMapping.add(new _Mapping(new RegExp("^$uri\$"), hd));
      }

    if (errorMapping != null)
      for (final mapping in errorMapping) {
        final code = mapping[0],
          uri = mapping[1];
        if (uri == null || uri.isEmpty)
          throw new ServerError("Invalid error mapping: URI required for $code");
        this.errorMapping[code] = uri;
      }
  }

  //@override
  void forward(HttpConnect connect, String uri, {Handler success,
    HttpRequest request, HttpResponse response}) {
    if (uri.indexOf('?') >= 0)
      throw new UnsupportedError("Forward with query string"); //TODO

    _handle(new _ForwardedConnect(connect, request, response, _toAbsUri(connect, uri), _cxerrh)
      ..on.close.add((){
          if (success != null)
            success();
          connect.close(); //spec: it is the forwarded handler's job to close
        }));
  }
  //@override
  void include(HttpConnect connect, String uri, {Handler success,
    HttpRequest request, HttpResponse response}) {
    if (uri.indexOf('?') >= 0)
      throw new UnsupportedError("Include with query string"); //TODO
    _handle(connectForInclusion(
      connect, uri: uri, success: success, request: request, response: response));
  }
  //@override
  HttpConnect connectForInclusion(HttpConnect connect, {String uri, Handler success,
    HttpRequest request, HttpResponse response}) {
    final inc = new _IncludedConnect(connect, request, response,
        uri != null ? _toAbsUri(connect, uri): null, _cxerrh);
    if (success != null)
      inc.on.close.add(success);
    return inc;
  }
  String _toAbsUri(HttpConnect connect, String uri) {
    if (!uri.startsWith('/')) {
      final pre = connect.request.uri;
      final i = pre.lastIndexOf('/');
      if (i >= 0)
        uri = "${pre.substring(0, i + 1)}$uri";
      else
        uri = "/$uri";
    }
    return uri;
  }
  void _handle(HttpConnect connect) {
    try {
      String uri = connect.request.uri;
      if (!uri.startsWith('/')) uri = "/$uri"; //not possible; just in case

      final hdl = _getHandler(uri);
      if (hdl != null) {
        final ret = hdl(connect);
        if (ret is String)
          forward(connect, ret);
        return;
      }

      //protect from access
      if (!connect.isForwarded && !connect.isIncluded &&
      (uri.startsWith("/webapp/") || uri == "/webapp"))
        throw new Http403(uri);

      resourceLoader.load(connect, uri);
    } catch (e, st) {
      _handleErr(connect, e, st);
    }
  }
  Function _getHandler(String uri) {
    //TODO: cache the matched result for better performance
    for (final mp in _uriMapping)
      if (mp.regexp.hasMatch(uri))
        return mp.handler;
  }
  void _handleErr(HttpConnect connect, error, [stackTrace]) {
    if (connect == null) {
      _shout(error, stackTrace);
      return;
    }

    try {
      if (onError != null)
        onError(connect, error, stackTrace);
      if (connect.isError) {
        _shout(error, stackTrace);
        _close(connect);
        return; //done
      }

      connect.isError = true;
      if (error is HttpStatusException) {
        _forwardErr(connect, error, error, stackTrace);
      } else {
        _shout(error, stackTrace);
        _forwardErr(connect, new Http500(error) , error, stackTrace);
        _shout(error, stackTrace);
      }
    } catch (e) {
      _close(connect);
    }
  }
  void _forwardErr(HttpConnect connect, HttpStatusException err, srcErr, st) {
    final code = err.statusCode;
    connect.response
      ..statusCode = code
      ..reasonPhrase = err.message;

    final uri = errorMapping[code];
    if (uri != null) {
      //TODO: store srcErr and st to HttpRequest.data (when SDK supports it)
      forward(connect, uri);
    } else {
      //TODO: render a page
      _close(connect);
    }
  }
  void _shout(err, st) {
    logger.shout(st != null ? "$err:\n$st": err);
  }
  void _close(HttpConnect connect) {
    try {
      connect.response.outputStream.close();
    } catch (e) { //silent
    }
  }

  @override
  Path get homeDir => _homeDir;
  @override
  final List<String> indexNames = ['index.html'];

  @override
  int get port => _port;
  @override
  void set port(int port) {
    _assertIdle();
    _port = port;
  }
  @override
  String get host => _host;
  @override
  void set host(String host) {
    _assertIdle();
    _host = host;
  }
  @override
  int get sessionTimeout => _sessTimeout;
  @override
  void set sessionTimeout(int timeout) {
    _sessTimeout = _server.sessionTimeout = timeout;
  }

  @override
  ResourceLoader get resourceLoader => _resLoader;
  void set resourceLoader(ResourceLoader loader) {
    if (loader == null)
      throw new ArgumentError("null");
    _resLoader = loader;
  }

  @override
  final Map<int, String> errorMapping = new Map();
  @override
  ConnectErrorHandler onError;

  @override
  bool get isRunning => _running;
  //@override
  void run([ServerSocket socket]) {
    _assertIdle();
    if (socket != null)
      _server.listenOn(socket);
    else
      _server.listen(host, port);

    logger.info("Rikulo Stream Server $version starting on "
      "${socket != null ? '$socket': '$host:$port'}\n"
      "Home: ${homeDir}");
  }
  //@override
  void stop() {
    _server.close();
  }
  void _assertIdle() {
    if (isRunning)
      throw new StateError("Already running");
    _server.close();
  }
}

class _Mapping {
  final RegExp regexp;
  final Function handler;
  _Mapping(this.regexp, this.handler);
}
