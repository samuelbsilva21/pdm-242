import 'dart:isolate';

void main() {
  // Exibe seu nome
  print('Lara Ingrid');


  runIsolatesExample();
}


void runIsolatesExample() async {
  ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(isolateFunction, receivePort.sendPort);


  receivePort.listen((data) {
    print('Dados recebidos do Isolate: $data');
    if (data == 'fim') {
      receivePort.close();
    }
  });
}

void isolateFunction(SendPort sendPort) {
  for (var i = 1; i <= 5; i++) {
    sendPort.send('Mensagem $i do Isolate');
  }
  sendPort.send('fim');
}
