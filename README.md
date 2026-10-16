# Estudo Autônomo: Formulários Validados e CRUD em Memória no Flutter
**Disciplina:** Programação / Desenvolvimento Mobile (Flutter & Dart)  
**Professor:** Clerivaldo Roccia  
**Aluno:** Bruno de Santis Sartori  
**Instituição:** Escola de Engenharia de Piracicaba (EEP)  

---

## 1. Descrição do Repositório
Este repositório contém a resolução integral dos exercícios práticos, checkpoints teóricos, tabelas de conferência (T1 a T14) e desafios propostos no capítulo de estudo autônomo sobre **Formulários Validados e CRUD em Memória no Flutter**.

O projeto encontra-se dividido em dois eixos fundamentais:
1. `formulario_nome/`: Estudo inicial de `Form`, `TextFormField`, validações com `validator`, chave `GlobalKey<FormState>` e controlo de limpeza com `reset()` (Exercícios 1 e 2).
2. `produtos_memoria_completo/`: Arquitetura completa de CRUD em memória com reutilização de formulário para cadastro e edição, navegação com retorno de objetos (`Navigator.push<Produto>` / `Navigator.pop`), diálogo modal assíncrono para confirmação de exclusão (`showDialog<bool>`), integrando:
   - Validações completas de nome (mínimo 3 caracteres e unicidade case-insensitive);
   - Preço numérico estritamente maior que zero com suporte a vírgula;
   - Descrição opcional limitada a 120 caracteres;
   - Quantidade em estoque inteira e não negativa (`int.tryParse`);
   - Cálculo automático do valor do item e total geral do estoque;
   - Filtro de pesquisa com contagem separada de cadastrados e visíveis;
   - Identificadores estáveis (`id` sequencial permanente) com atualização segura via `indexWhere`.

*Nota de Persistência:* Os dados deste aplicativo residem exclusivamente na memória de execução (`List<Produto>` gerenciada pelo `State`). Ao reiniciar a aplicação (hot restart ou encerramento do processo), o estado é reinicializado.
