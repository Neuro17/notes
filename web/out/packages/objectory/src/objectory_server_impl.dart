library objectory_server_impl;
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logging/logging.dart';
import 'vm_log_config.dart';

final IP = '127.0.0.1';
final PORT = 8080;
final URI = 'mongodb://127.0.0.1/objectory_server_test';

//Map<String, ObjectoryClient> connections;
List chatText;
Db db;
class RequestHeader {
  String command;
  String collection;
  int requestId;
  RequestHeader.fromMap(Map commandMap) {
    command = commandMap['command'];
    collection = commandMap['collection'];
    requestId = commandMap['requestId'];
  }
  Map toMap() => {'command': command, 'collection': collection, 'requestId': requestId};
  String toString() => 'RequestHeader(${toMap()})';
}
class ObjectoryClient {
  int token;
  String name;
  WebSocketConnection conn;
  bool closed = false;
  ObjectoryClient(this.name, this.token, this.conn) {
    conn.send(JSON_EXT.stringify([{'command':'hello'}, {'connection':this.name}]));
    conn.onMessage = (message) {
      log.fine('message is $message');
      var jdata = JSON_EXT.parse(message);
      var header = new RequestHeader.fromMap(jdata[0]);
      Map content = jdata[1];
      Map extParams = jdata[2];
      if (header.command == "insert") {
        save(header,content);
        return;
      }
      if (header.command == "update") {
        save(header,content);
        return;
      }
      if (header.command == "findOne") {
        findOne(header, content, extParams);
        return;
      }
      if (header.command == "find") {
        find(header, content, extParams);
        return;
      }
      if (header.command == "queryDb") {
        queryDb(header,content);
        return;
      }
      if (header.command == "dropDb") {
        dropDb(header);
        return;
      }
      if (header.command == "dropCollection") {
        dropCollection(header);
        return;
      }

      log.shout('Unexpected message: $message');
      sendResult(header,content);
    };

    conn.onClosed = (int status, String reason) {
      log.info('closed with $status for $reason');
      closed = true;
    };
  }
  sendResult(RequestHeader header, content) {
    log.fine('sendResult($header, $content) ');
    if (closed) {
      log.shout('ERROR: trying send on closed connection. $header, $content');
    } else {
      conn.send(JSON_EXT.stringify([header.toMap(),content]));
    }
  }
  save(RequestHeader header, Map mapToSave) {
    if (header.command == 'insert') {
      db.collection(header.collection).insert(mapToSave);
    }
    else
    {
      ObjectId id = mapToSave['_id'];
      if (id != null) {
        db.collection(header.collection).update({'_id': id},mapToSave);
      }
      else {
        log.shout('ERROR: Trying to update object without ObjectId set. $header, $mapToSave');
      }
    }
    db.getLastError().then((responseData) {
      log.fine('$responseData');
      sendResult(header, responseData);
    });
  }
  find(RequestHeader header, Map selector, Map extParams) {
    SelectorBuilder selectorBuilder = new SelectorBuilder();
    selectorBuilder.map = selector;        
    selectorBuilder.extParams.limit = extParams['limit'];
    selectorBuilder.extParams.skip = extParams['skip'];    
    db.collection(header.collection).find(selectorBuilder).toList().
    then((responseData) {
      sendResult(header, responseData);
    });
  }

  findOne(RequestHeader header, Map selector , Map extParams) {
    SelectorBuilder selectorBuilder = new SelectorBuilder();
    selectorBuilder.map = selector;        
    selectorBuilder.extParams.limit = extParams['limit'];
    selectorBuilder.extParams.skip = extParams['skip'];
    db.collection(header.collection).findOne(selectorBuilder).
    then((responseData) {
      sendResult(header, responseData);
    });
  }

  queryDb(RequestHeader header,Map query) {
    db.executeDbCommand(DbCommand.createQueryDBCommand(db,query))
    .then((responseData) {
      log.fine('$responseData');
      sendResult(header,responseData);
    });
  }
  dropDb(RequestHeader header) {
    db.drop()
    .then((responseData) {
      log.fine('$responseData');
      sendResult(header,responseData);
    });
  }

  dropCollection(RequestHeader header) {
    db.dropCollection(header.collection)
    .then((responseData) {
      log.fine('$responseData');
      sendResult(header,responseData);
    });
  }


  protocolError(String errorMessage) {
    log.shout('PROTOCOL ERROR: $errorMessage');
    conn.send(JSON_EXT.stringify({'error': errorMessage}));
  }


  String toString() {
    return "${name}_${token}";
  }
}

class ObjectoryServerImpl {
  String hostName;
  int port;
  String mongoUri;
  ObjectoryServerImpl(this.hostName,this.port,this.mongoUri, bool verbose){
    chatText = [];
    int token = 0;
    HttpServer server;
    db = new Db(mongoUri);
    db.open().then((_) {
      server = new HttpServer();
      WebSocketHandler wsHandler = new WebSocketHandler();
      server.addRequestHandler((req) => req.path == '/ws', wsHandler.onRequest);
      if (verbose) {
        configureConsoleLogger(Level.ALL);
      }
      else {
        configureConsoleLogger(Level.INFO);
      }
      wsHandler.onOpen = (WebSocketConnection conn) {
        token+=1;
        var c = new ObjectoryClient('objectory_client_${token}', token, conn);
        log.info('adding connection token = ${token}');
      };
      print('listing on http://$hostName:$port\n');
      log.fine('MongoDB connection: ${db.serverConfig.host}:${db.serverConfig.port}');
      server.listen(hostName, port);
    });
  }
}
