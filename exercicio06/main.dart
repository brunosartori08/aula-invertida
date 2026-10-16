import 'package:flutter/material.dart';

void main() => runApp(const MeuApp());

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerenciador de Produtos',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: false,
      ),
      home: const TelaProdutos(),
    );
  }
}

// Modelo de Dados com ID estável (Exercício 9), quantidade (Exercício 5)
class Produto {
  final int id;
  final String nome;
  final double preco;
  final int quantidade;
  final String descricao;

  const Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.quantidade,
    required this.descricao,
  });

  double get valorTotal => preco * quantidade; // Exercício 6
}

class TelaProdutos extends StatefulWidget {
  const TelaProdutos({super.key});

  @override
  State<TelaProdutos> createState() => _TelaProdutosState();
}

class _TelaProdutosState extends State<TelaProdutos> {
  final List<Produto> produtos = [];
  final TextEditingController buscaController = TextEditingController(); // Exercício 8
  String termoBusca = '';
  int proximoId = 1; // Exercício 9: Contador sequencial que não diminui

  void avisar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  // Exercício 6 e 10: Total geral de todo o estoque cadastrado
  double get totalGeralEstoque {
    double total = 0.0;
    for (var p in produtos) {
      total += p.valorTotal;
    }
    return total;
  }

  // Exercício 8: Lista filtrada conforme busca
  List<Produto> get produtosFiltrados {
    if (termoBusca.trim().isEmpty) return produtos;
    return produtos.where((p) => p.nome.toLowerCase().contains(termoBusca.toLowerCase().trim())).toList();
  }

  // Lista de nomes para validação de unicidade (Exercício 7)
  List<String> get nomesExistentes => produtos.map((p) => p.nome).toList();

  Future<void> cadastrar() async {
    final novoProduto = await Navigator.push<Produto>(
      context,
      MaterialPageRoute<Produto>(
        builder: () => TelaFormulario(
          proximoId: proximoId,
          nomesExistentes: nomesExistentes,
        ),
      ),
    );

    if (!mounted || novoProduto == null) return;

    setState(() {
      produtos.add(novoProduto);
      proximoId++; // Incrementa contador de ID permanente
    });
    avisar('Produto cadastrado com sucesso.');
  }

  Future<void> abrirDetalhes(Produto produto) async {
    final atualizado = await Navigator.push<Produto>(
      context,
      MaterialPageRoute<Produto>(
        builder: () => TelaDetalhes(
          produto: produto,
          nomesExistentes: nomesExistentes,
        ),
      ),
    );

    if (!mounted || atualizado == null) return;

    // Exercício 9: Localização por ID estável
    final indiceOriginal = produtos.indexWhere((p) => p.id == atualizado.id);
    if (indiceOriginal == -1) {
      avisar('Erro: Registro não encontrado para atualização.');
      return;
    }

    setState(() {
      produtos[indiceOriginal] = atualizado;
    });
    avisar('Produto atualizado com sucesso.');
  }

  Future<void> excluirPorId(int id) async {
    final indiceOriginal = produtos.indexWhere((p) => p.id == id);
    if (indiceOriginal == -1) {
      avisar('Erro: Registro não encontrado para exclusão.');
      return;
    }

    final produto = produtos[indiceOriginal];
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Deseja excluir "${produto.nome}" (ID: ${produto.id})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!mounted || confirmou != true) return;

    setState(() {
      produtos.removeAt(indiceOriginal);
    });
    avisar('Produto excluído.');
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listaVisivel = produtosFiltrados;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos em Memória'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Painel de Resumo / Indicadores Gerais (Exercício 6, 8, 10)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.teal.shade50,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cadastrados: ${produtos.length} | Encontrados: ${listaVisivel.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total Geral: R$ ${totalGeralEstoque.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Campo de Busca (Exercício 8)
                TextField(
                  controller: buscaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: termoBusca.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                buscaController.clear();
                                termoBusca = '';
                              });
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(8),
                  ),
                  onChanged: (valor) {
                    setState(() {
                      termoBusca = valor;
                    });
                  },
                ),
              ],
            ),
          ),
          // Lista de Produtos
          Expanded(
            child: produtos.isEmpty
                ? const Center(child: Text('Nenhum produto cadastrado.'))
                : listaVisivel.isEmpty
                    ? const Center(child: Text('Nenhum produto encontrado.'))
                    : ListView.builder(
                        itemCount: listaVisivel.length,
                        itemBuilder: (context, indice) {
                          final produto = listaVisivel[indice];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${produto.id}'),
                              ),
                              title: Text(
                                produto.nome,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'R$ ${produto.preco.toStringAsFixed(2)} | Qtd: ${produto.quantidade} un\nTotal Item: R$ ${produto.valorTotal.toStringAsFixed(2)}',
                              ),
                              onTap: () => abrirDetalhes(produto),
                              trailing: IconButton(
                                tooltip: 'Excluir produto',
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => excluirPorId(produto.id),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: cadastrar,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TelaDetalhes extends StatelessWidget {
  final Produto produto;
  final List<String> nomesExistentes;

  const TelaDetalhes({
    super.key,
    required this.produto,
    required this.nomesExistentes,
  });

  Future<void> editar(BuildContext context) async {
    final atualizado = await Navigator.push<Produto>(
      context,
      MaterialPageRoute<Produto>(
        builder: (_) => TelaFormulario(
          produto: produto,
          nomesExistentes: nomesExistentes,
        ),
      ),
    );

    if (!context.mounted || atualizado == null) return;
    Navigator.pop(context, atualizado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Produto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${produto.id}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            Text(produto.nome, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Preço unitário: R$ ${produto.preco.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Quantidade em estoque: ${produto.quantidade} unidades', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Valor total do item: R$ ${produto.valorTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 16),
            const Text('Descrição:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(produto.descricao.isEmpty ? 'Sem descrição.' : produto.descricao),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => editar(context),
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaFormulario extends StatefulWidget {
  final Produto? produto;
  final int? proximoId;
  final List<String> nomesExistentes;

  const TelaFormulario({
    super.key,
    this.produto,
    this.proximoId,
    required this.nomesExistentes,
  });

  @override
  State<TelaFormulario> createState() => _TelaFormularioState();
}

class _TelaFormularioState extends State<TelaFormulario> {
  final chave = GlobalKey<FormState>();
  late final TextEditingController nomeController;
  late final TextEditingController precoController;
  late final TextEditingController quantidadeController;
  late final TextEditingController descricaoController;

  @override
  void initState() {
    super.initState();
    final produto = widget.produto;
    nomeController = TextEditingController(text: produto?.nome ?? '');
    precoController = TextEditingController(text: produto?.preco.toString() ?? '');
    quantidadeController = TextEditingController(text: produto?.quantidade.toString() ?? '');
    descricaoController = TextEditingController(text: produto?.descricao ?? '');
  }

  double? converterPreco(String texto) {
    return double.tryParse(texto.trim().replaceAll(',', '.'));
  }

  String? validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe o nome.';
    }
    final nomeLimpo = valor.trim();
    // Exercício 3: Mínimo 3 caracteres
    if (nomeLimpo.length < 3) {
      return 'O nome deve ter pelo menos três caracteres.';
    }

    // Exercício 7: Unicidade do nome (case-insensitive)
    final nomeLower = nomeLimpo.toLowerCase();
    final nomeAtual = widget.produto?.nome.trim().toLowerCase();

    // Se estiver editando e o nome for o mesmo do próprio produto, é permitido
    final outrosNomes = widget.nomesExistentes
        .where((n) => nomeAtual == null || n.trim().toLowerCase() != nomeAtual)
        .map((n) => n.trim().toLowerCase())
        .toList();

    if (outrosNomes.contains(nomeLower)) {
      return 'Já existe um produto com este nome.';
    }

    return null;
  }

  String? validarPreco(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe o preço.';
    }
    final preco = converterPreco(valor);
    if (preco == null || !preco.isFinite) {
      return 'Digite um número válido.';
    }
    if (preco <= 0) {
      return 'O preço deve ser maior que zero.';
    }
    return null;
  }

  String? validarQuantidade(String? valor) {
    // Exercício 5: Quantidade obrigatória, inteira e >= 0
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe a quantidade.';
    }
    final qtd = int.tryParse(valor.trim());
    if (qtd == null) {
      return 'Digite um número inteiro válido.';
    }
    if (qtd < 0) {
      return 'A quantidade deve ser maior ou igual a zero.';
    }
    return null;
  }

  String? validarDescricao(String? valor) {
    // Exercício 3: Opcional, máximo 120 caracteres
    if (valor != null && valor.trim().length > 120) {
      return 'A descrição deve ter no máximo 120 caracteres.';
    }
    return null;
  }

  void salvar() {
    if (!chave.currentState!.validate()) return;

    final id = widget.produto != null ? widget.produto!.id : widget.proximoId!;

    final produto = Produto(
      id: id,
      nome: nomeController.text.trim(),
      preco: converterPreco(precoController.text)!,
      quantidade: int.parse(quantidadeController.text.trim()),
      descricao: descricaoController.text.trim(),
    );

    Navigator.pop(context, produto);
  }

  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    quantidadeController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.produto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar produto' : 'Cadastrar produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: chave,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome *', border: OutlineInputBorder()),
                validator: validarNome,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: precoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Preço (R$) *', border: OutlineInputBorder()),
                validator: validarPreco,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: quantidadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade em estoque *', border: OutlineInputBorder()),
                validator: validarQuantidade,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional - máx. 120 caracteres)',
                  border: OutlineInputBorder(),
                ),
                validator: validarDescricao,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: salvar,
                child: const Text('Salvar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
