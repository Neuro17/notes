library server;

//import 'dart:html';

import "package:objectory/src/objectory_server_impl.dart";
import "package:stream/stream.dart";
import "package:stream/plugin.dart";


part "config.dart";

class Server{
  void run(){

//    LoggingConfigurer log= new LoggingConfigurer();
    
    var serverObj = new ObjectoryServerImpl('127.0.0.1',8080,'mongodb://127.0.0.1/objectory_server_test',true);
//    homeDir: "webapp", uriMapping: _mapping

    new StreamServer( ).run();
  }
}


void main() {

  new Server().run();

}

String mainNotes(HttpConnect connect){
  
  
//  print(connect.request.headers.toString());
  
  

  
  
  return "/web/out/main.html";
}
