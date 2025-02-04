import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// MODELO DE DADOS
class Produto {
  final String nome;
  final double preco;

  Produto({required this.nome, required this.preco});
}

// PROVIDER
class CarrinhoProvider extends ChangeNotifier {
  final List<Produto> _produtosSelecionados = [];
  String _clienteNome = '';

  List<Produto> get produtos => _produtosSelecionados;
  String get clienteNome => _clienteNome;
  double get total => _produtosSelecionados.fold(0, (soma, produto) => soma + produto.preco);

  void adicionarProduto(Produto produto) {
    if (!_produtosSelecionados.contains(produto)) {
      _produtosSelecionados.add(produto);
      notifyListeners();
    }
  }

  void removerProduto(Produto produto) {
    _produtosSelecionados.remove(produto);
    notifyListeners();
  }

  void definirCliente(String nome) {
    _clienteNome = nome;
    notifyListeners();
  }

  void limparCarrinho() {
    _produtosSelecionados.clear();
    _clienteNome = '';
    notifyListeners();
  }
}

// APLICAÇÃO PRINCIPAL
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CarrinhoProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Loja Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            textStyle: TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      home: ProdutosScreen(),
    );
  }
}

// TELA DE SELEÇÃO DE PRODUTOS
class ProdutosScreen extends StatelessWidget {
  final List<Produto> produtos = [
    Produto(nome: 'Produto 1', preco: 10.0),
    Produto(nome: 'Produto 2', preco: 15.0),
    Produto(nome: 'Produto 3', preco: 8.0),
    Produto(nome: 'Produto 4', preco: 20.0),
  ];

  @override
  Widget build(BuildContext context) {
    var carrinho = Provider.of<CarrinhoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Selecione os Produtos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: produtos.map((produto) {
            final isSelected = carrinho.produtos.contains(produto);
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(produto.nome, style: TextStyle(fontSize: 18)),
                subtitle: Text('Preço: \$${produto.preco.toStringAsFixed(2)}'),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    value == true
                        ? carrinho.adicionarProduto(produto)
                        : carrinho.removerProduto(produto);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: carrinho.produtos.isEmpty
            ? null
            : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClienteScreen())),
        label: Text('Próximo'),
        icon: Icon(Icons.arrow_forward),
      ),
    );
  }
}

// TELA DE IDENTIFICAÇÃO DO CLIENTE
class ClienteScreen extends StatefulWidget {
  @override
  _ClienteScreenState createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var carrinho = Provider.of<CarrinhoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Identificar Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nome do Cliente',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: carrinho.definirCliente,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: carrinho.clienteNome.isEmpty
                  ? null
                  : () => Navigator.push(context, MaterialPageRoute(builder: (_) => PedidoScreen())),
              child: Text('Criar Pedido'),
            ),
          ],
        ),
      ),
    );
  }
}

// TELA DE PEDIDO FINALIZADO
class PedidoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var carrinho = Provider.of<CarrinhoProvider>(context);
    String itens = carrinho.produtos
        .map((produto) => '${produto.nome} - \$${produto.preco.toStringAsFixed(2)}')
        .join(' + ');

    return Scaffold(
      appBar: AppBar(title: Text('Resumo do Pedido')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${carrinho.clienteNome}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Produtos Selecionados:', style: TextStyle(fontSize: 18)),
            ...carrinho.produtos.map((produto) => Text(produto.nome)),
            SizedBox(height: 20),
            Text('Total: \$${carrinho.total.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$itens = Total \$${carrinho.total.toStringAsFixed(2)}'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text('Finalizar Compra'),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  carrinho.limparCarrinho();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text('Voltar ao Início'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
