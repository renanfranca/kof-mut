# Implementar o KofMut: mutação de código Kof com testes do próprio projeto

## Purpose and success

Construir o **KofMut**, ferramenta de teste de mutação específica para Kof, com lógica escrita em Kof e execução inicial na JVM em Linux. O repositório é `renanfranca/kof-mut`, e o checkout local é `/home/renanfranca/projects/kof-mut`.

O usuário executará a ferramenta sobre arquivos de produção escolhidos. Ela confirmará a situação original dos testes, criará alterações individuais em cópias temporárias dos arquivos `.kf`, executará o comando de testes do projeto e apresentará quais alterações foram detectadas e quais sobreviveram. O código original e os testes originais permanecerão preservados.

O produto precisa funcionar sem Codex, Katacombs ou SiFuture. Um relatório JSON versionado permitirá integrar os sensores depois. A primeira entrega pública será **fonte utilizável com instruções**, licença GPLv3 e documentação em inglês e português. Não inclui instalador nem publicação de pacote binário.

**Estado deste documento:** plano elaborado em 2026-10-15; M1 e M1R implementados e validados em 2026-10-16. M1P implementado e validado em 2026-10-16, antes de M2, com a inicialização dentro de 10% da referência Python medida nas mesmas condições. M2 implementado e validado em 2026-10-16 conforme a autorização abaixo, incluindo JSON v1, orçamento global e encerramento de processos. As correções autorizadas em 2026-10-17 foram implementadas e validadas, incluindo proteção em erro, resolução de campos, contadores e descartes documentados. M3 concluído localmente em 2026-10-17, com relatórios independentes, concorrência/cancelamento/recuperação, equivalência e sete medições externas. Background concluiu; Meteor esgotou 85 segundos internos, ficando incomplete abaixo de 90 segundos externos. Isso é limitação medida e não prontidão geral dos sensores. M3P.1–3 implementados e inicialmente validados em 2026-10-21, com limite opcional de quatro mutantes e 39 testes do ciclo. Em 2026-10-22, M3P.3 foi reaberto, corrigido e validado com 41 testes do ciclo, preservando candidatos e resultados sob falha de cancelamento. As dez medições finais mantêm a aceitação de desempenho pendente para Meteor e escopo conjunto; a amostra fria atingiu o prazo externo sem JSON final. M4 conserva os guias ampliados, ainda pendentes. O usuário confirmou GPT 6.1 Sol, esforço xhigh. Novos commits e publicações exigem instrução explícita. Nunca apresentar pendências como validadas.

## Context and limits

### Correção M3P.3 autorizada em 2026-10-22

Base `438c775a922da6f95614304a8229f464987cced2`, branch existente `kofmut-frontend`, árvore inicialmente limpa. Reabrir M3P.3: falha no cancelamento não pode perder resultados nem candidatos. Manter Kof 0.6.4 Linux/JVM, schema v1, flags, limites e prazo compartilhado de limpeza. Sem alterações no Kof, sensores, commits, worktrees, subagentes, publicação ou novos benchmarks. Medições anteriores são históricas de `438c775` e não comprovam desempenho da árvore corrigida; M3P.4 continua pendente.

Primeiro ampliar o teste Kof de limpeza persistente em `src/test/kof/kofmut/Run.kf`: seis candidatos, quatro testes ativos com descendentes comprovados, dois aguardando, sinais ineficazes, orçamento 2500 ms e timeout 20000 ms. Exigir error/2, quatro TestError/test, dois Pending/parse com duração zero e duração do relatório <5500 ms. Registrar falha nas contagens antes da correção. Corrigir `src/main/kof/kofmut/Run.kf`: fechar admissão ao receber falha, conservar diagnósticos de stopCommands, recolher tarefas fora do lock, agregar por índice e só então propagar o erro.

Ampliar as provas pelo runner sintético: candidato 0 bloqueado e cinco Killed concluídos; depois descarte 0, Survived 2, Killed 1/3/4 e falha de limpeza no candidato 5. Ambos com marcadores explícitos de conclusão anterior, orçamento 5000 ms, timeout 20000 ms e duração <8000 ms. Exigir reconciliação completa, IDs, fases, logs e ordem sem duplicações; sinais reais no finally eliminam e conferem os resíduos. Preservar relatórios anteriores e provar recuperação.

Reconciliar contrato e READMEs EN/PT para Pending no encerramento por erro, motivo em evidence e status geral error/2. Validar com Kof 0.6.4 no início do PATH: `kof test src/test/kof/kofmut/Run.kf --tag parallel`, `kof test src/test/kof/kofmut/Run.kf --tag m3`, `./scripts/check`, `git diff --check`. Repetir `./scripts/check` em cópia limpa com espaços e PATH sem Python, criada da árvore corrigida incluindo alterações sem commit; comparar os inputs por SHA-256. Registrar comando, resultado e asserção por critério em `.agent/validation/kofmut-m3p.md`, preservar reproduções e manifesto histórico, identificar nova árvore por manifesto. Marcar a correção concluída somente após essas provas.

### Correções M2 autorizadas em 2026-10-17

Executar o plano de correção da base `7dd5ecc`, na branch existente, com GPT 6.1 Sol/xhigh e Kof 0.6.4. Sem commits, worktrees, subagentes, remotes ou publicações. A autorização altera o contrato anterior: candidatos rejeitados pelo lexer/parser ou por check válido e coerente serão documentados em `discardedCandidates`, separados de `mutants`. Descartes esperados permitem `complete`; não são mutações detectadas. Todos descartados resulta em `no_mutants/3`. Falhas da ferramenta, evidência inválida, timeout, orçamento e construções não suportadas no original continuam impedindo aprovação. `counts.compileError` permanece por compatibilidade, zero em novas execuções.

Executar um passo de cada vez com testes comportamentais Kof antes das correções: (1) impedir publicação interna quando a configuração não é validável, conferindo caminhos canônicos antes de efeitos; (2) separar campos de parâmetros/locais para `this.campo`; (3) validar os inteiros JSON originais antes da conversão, com `filesChecked` em 1..2147483647 e `errorCount` em 0..2147483647; (4) validar tokens com lexer oficial, reanalisar com parser oficial e descartar rejeições documentadas sem interromper os demais candidatos. Cada variante parte do snapshot independente. Divergência do token original e exceções inesperadas continuam erros da ferramenta.

Provas: testes do ciclo em `src/test/kof/kofmut/Run.kf`, frontend em `FrontendContracts.kf`, wrappers sintéticos em `src/test/fixtures/mutation-runner`; comandos focados com `kof test ... --tag <tag>` e `./scripts/launch contracts`; validação final pelo `PATH=/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64/bin:$PATH ./scripts/check`. Preservar os 21 contratos do lançador, reexecutar exemplos e reconciliar READMEs EN/PT, relatório M2 e manifesto. Evidências em `.agent/tmp/m2-corrections/`, com comandos, resultados e asserções no relatório de validação. M3 e M4 permanecem pendentes.

### Execução autorizada em 2026-10-16

O escopo atual é M2, autorizado pelo plano fornecido em 2026-10-16. Base observada: branch `kofmut-frontend`, HEAD `b1d8684762ad1d2f94a48d9dcd81270647a6fe52`, árvore limpa. Preservar M1/M1R/M1P e os 21 contratos do lançador. Usar GPT 6.1 Sol com xhigh e a distribuição Kof 0.6.4 explicitamente no PATH. Não criar worktrees, subagentes, commits, remotes ou publicações.

No M1R, o usuário autorizou iniciar o plano com **GPT 6.1 Sol, esforço xhigh**, substituindo Luna/high. A execução daquele marco encerrou no M1R aprovado. Durante seu planejamento, foi observado HEAD `adec628b08d1a221801295463ae642856ce502ee`, na mesma branch `kofmut-frontend`; commit e publicação externos àquela execução. O M1R foi então entregue localmente, sem novos commits, worktrees, subagentes ou publicações. O estado corrente e o escopo M1P estão registrados no parágrafo anterior.

No início, `kof info --json` confirmou Kof 0.6.4 com JDK 25 embutido. Durante a execução, o executável no PATH mudou externamente para 0.6.5. As provas finais usaram explicitamente o `bin/` da distribuição 0.6.4 no início do PATH; não foi atualizado ou alterado Kof por este trabalho. As fontes locais consultadas estavam em `53efd25fdb8dfec1fbbd989c1f482b2ee38c3ce8`; elas orientaram a pesquisa, e as provas executaram contra o jar 0.6.4. Seu SHA-256 é `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62`. A tabela abaixo preserva as observações históricas do planejamento.

### Ambiente e evidência observados

| Item | Observado durante o planejamento |
| --- | --- |
| Kof instalado | 0.6.4, distribuição Linux x86_64 com JDK 25 embutido; `kof info --json` |
| Fontes locais do Kof | `/home/renanfranca/projects/kof`, HEAD `284358f43db885ccd8b52b11f897ac0defec10de`; `VERSION` contém 0.6.5 |
| Checkout futuro | `/home/renanfranca/projects/kof-mut` estava ausente |
| GitHub futuro | Consulta somente de leitura não encontrou `renanfranca/kof-mut`; repetir a consulta antes de qualquer criação |
| Execução pelo usuário | Codex CLI acessado pelo Termux; comandos executam no Linux atual, sem requisito de Android |
| Modelo escolhido | `gpt-6-luna`, esforço `high`, para implementação; registrar a configuração efetiva na sessão futura |

Não atualizar Kof automaticamente. Começar com **0.6.4**, a versão na qual houve prova de interoperabilidade. O checkout de fontes 0.6.5 serve para pesquisa e não comprova o comportamento do binário 0.6.4. Registrar versão, instalação e API efetivamente usadas. Outra versão requer repetir os testes de contrato antes de declarar suporte.

Uma prova temporária compilou e executou Kof na JVM, usando `lib/kof.jar` como classpath externo e chamando `DiagnosticCollector`, `Lexer` e `Parser`. Resultado observado:

```text
compile=true
function=less
operator=<
token offset=29, length=1
Probe process exit=0
```

Outra prova leu 24 arquivos de produção do SiFuture com o lexer/parser oficiais, sem erros sintáticos. Isso demonstra acesso básico ao frontend, **não** uma ferramenta de mutação, um percurso completo da AST ou um teste de desempenho. Uma tentativa de `for-in` sobre a lista externa de tokens recebeu `SEM058`; a prova passou com acesso por índice. Não generalizar essa limitação para listas Kof.

O nome JVM descreve a execução do KofMut. Não exige que o projeto avaliado use esse destino. O mutador trabalha nos arquivos Kof e usa os comandos configurados pelo projeto, sem matriz obrigatória JVM/JS/WASI e sem reescrever testes em outra linguagem.

Sobre WASI, a decisão `D-WEB-WASI-DEFAULT-0710` determina sua adoção como padrão do frontend web e desktop. Na distribuição 0.6.4, uma consulta à matriz do próprio `kof.jar` produziu `WASI is backend: true` e `WASI is frontend: false`, com diagnóstico da unidade 15.4 pendente. Não tratar a troca do frontend como concluída nem migrar projetos neste trabalho.

### Fontes obrigatórias para o executor

Começar por [training/README.md](/home/renanfranca/projects/kof/training/README.md). Antes de decisões Kof, ler os tópicos pertinentes: [interop](/home/renanfranca/projects/kof/training/idioms/interop.md), [automation](/home/renanfranca/projects/kof/training/idioms/automation.md), [tipos](/home/renanfranca/projects/kof/training/language/types.md), [arquivos](/home/renanfranca/projects/kof/training/language/io.md), [CLI](/home/renanfranca/projects/kof/training/tooling/cli.md), [fake idioms](/home/renanfranca/projects/kof/training/anti-patterns/fake-idioms.md) e [abstrações desnecessárias](/home/renanfranca/projects/kof/training/anti-patterns/unnecessary-abstraction.md).

Para contratos e implementação, consultar [expressões](/home/renanfranca/projects/kof/docs/language-reference/expressions.md), [interoperabilidade para aprendizado](/home/renanfranca/projects/kof/learn/21-java-interoperability.md), [testes](/home/renanfranca/projects/kof/learn/23-testing.md), [comandos de processo](/home/renanfranca/projects/kof/learn/stdlib/process.md) e [argv dinâmico](/home/renanfranca/projects/kof/learn/stdlib/shell.md). Verificar a API real em `kof-compiler/src/main/java/dev/kof/compiler/` e `kof-cli/src/main/java/dev/kof/cli/`, dentro do checkout Kof. Implementação e testes atuais prevalecem sobre exemplos antigos. Compilar e executar provas das chamadas externas consequenciais antes de depender delas.

O [licenciamento do Kof](/home/renanfranca/projects/kof/docs/distribution/LICENSING.md) identifica o compilador como GPLv3 e distingue seu uso como compilador da incorporação de componentes. O KofMut usará o frontend como biblioteca e será GPLv3; preservar os avisos das dependências e não redistribuir o JDK ou o fat jar como parte desta entrega de fonte. Usar `GPL-3.0-only` como identificador do novo projeto, sem inventar exceções.

### Limites de trabalho

Trabalhar no checkout indicado, sem worktrees nem subagentes automáticos. Usar TDD por comportamento, testes Kof e provas do CLI. Não usar implement-approved-plan, controlador de fases, framework de mutação de outra linguagem ou um segundo parser de Kof.

A lógica de seleção, transformação, execução e relatório ficará em Kof. O lançador poderá apenas localizar a distribuição, compilar e iniciar o programa. Usar APIs existentes para arquivos, JSON e processos; interoperabilidade JVM fica nas fronteiras com o frontend, nas necessidades de processo que a stdlib não cubra e nas operações de bytes, hashes, bloqueio e publicação do bootstrap aprovadas no M1R. Se uma prova revelar que isso exige mover o motor para Java/Python/JS ou modificar Kof, parar nesse marco e registrar o bloqueio; não trocar a linguagem silenciosamente.

Não copiar fontes do SiFuture, transcrições, respostas integrais de modelos ou credenciais para o projeto público. Criar fixtures sintéticas pequenas. Não alterar Kof, Katacombs, SiFuture, skills globais ou a memória fora deste plano. Uma demonstração no SiFuture será somente de leitura do checkout original, com trabalho em cópias descartáveis.

## Decisions

### Decisões de execução do M1

O caminho real do executável Kof é resolvido uma vez, antes de consultar sua versão, e usado também na compilação. Uma prova descartável trocou o link `kof` depois de `info`: a forma sem fixar o caminho falhou ao compilar com a ferramenta substituta; a forma atual preservou a instalação descoberta e retornou a versão correta com exit 0.

Historicamente, M1 usou Bash e Python 3.9 para localizar a distribuição, calcular o cache, serializar a compilação e iniciar a JVM. M1R substitui essa decisão: essas responsabilidades serão escritas em Kof, com APIs JDK para bytes, SHA-256, bloqueio de arquivo e publicação atômica. A stdlib Kof será usada para JSON e subprocessos. O classpath continua usando o jar instalado, sem redistribuí-lo.

### Decisões aprovadas do M1R

`scripts/bootstrap/Launch.kf` será executado pelo Kof fixado por caminho real. `scripts/launch` será a ponte Bash mínima compartilhada pelos dois pontos de entrada. Ela preservará os argumentos originais fora de `kof run`, pois o CLI 0.6.4 interpreta opções como `--target` mesmo depois do arquivo. O bootstrap recebe apenas raiz, executável fixado, modo e caminho de entrega; escreve `kofmut-launch-v1` seguido do argv Java em campos UTF-8 terminados por NUL. Bash valida a entrega e faz `exec` com os argumentos originais, sem `eval` ou `sh -c`. stdout do bootstrap é encaminhado a stderr.

O cache usará `build/cache/kof-bootstrap-v1/`, separado do cache Python. A chave inclui modo, caminhos e informações da instalação fixada, conteúdo do jar, manifesto, VERSION, fontes e lançadores. Um bloqueio cobre a verificação e a compilação; o build será publicado por movimento atômico de diretório temporário no mesmo filesystem, somente após exit 0 e presença de `Default.Main`. Falha de preparação, compilação ou publicação retorna 2, sem reutilizar saída parcial. O bootstrap é compilado a cada chamada; não haverá um segundo cache para ele neste marco. Medir custo frio e quente sem alterar o orçamento de integração de 90 segundos.

As provas descartáveis contra 0.6.4 confirmaram JSON tipado, `shell.runWith` com cwd/ambiente, `RandomAccessFile`/`FileChannel.lock`, SHA-256 do jar, caminhos canônicos, diretório temporário, `ATOMIC_MOVE` e entrega NUL com Unicode. Usar `java.io.File.toPath()`; sobrecargas de `Paths.get` e `toRealPath` produziram bytecode inválido nessa versão. Essas provas não substituem os testes de aceitação do lançador completo.

A compilação usa `kof build --target jvm --classpath ... --output ...` com uma raiz `[sources] app` declarada no diretório temporário. Na versão instalada, entrada posicional não percorre subpacotes e a classe main do módulo é `Default.Main`, mesmo com os arquivos em `package kofmut`; ambos foram comprovados. O cache considera fontes, VERSION, manifesto, lançador, informações da instalação e conteúdo do jar, com bloqueio e rename da compilação pronta.

O `kof test` 0.6.4 não aceita `--classpath` nem `--module-root`. Os testes nomeados do CLI usam o comando oficial. O contrato do frontend é um programa Kof com `main()` e `assert`, compilado com o classpath real e executado pela JVM; não foi criado um framework ou harness de casos. O adaptador dos futuros projetos avaliados continua obrigado a consumir os protocolos oficiais de check e teste.

A lista externa de tokens é copiada por índice para uma lista Kof na fronteira, antes de passá-la a código Kof: passar `java.util.List` diretamente a um parâmetro `List` Kof emitiu bytecode incompatível com `ArrayList` em 0.6.4. O nome de tipo para o diagnóstico de AST é lido antes dos ramos `instanceof`, evitando uma falha de verificação observada ao consultá-lo após o estreitamento de tipos. As duas formas atuais compilam e executam nos casos suportados e no caso de AST não suportada. Não houve necessidade de modificar Kof ou mover a análise para outra linguagem.

### Decisões aprovadas do M2

Antecipar JSON v1, orçamento global monotônico e encerramento de grupos de processos para M2. M3 amplia concorrência, recuperação e aceitação no SiFuture dentro dos mesmos 90 segundos. Excluir concatenação reconhecida por literais, declarações e propagação local inequívoca na AST; aritmética de tipo incerto gera candidato validado pelo compilador. A decisão original classificava rejeição como `CompileError`, nunca `Killed`; a correção autorizada em 2026-10-17 substitui essa classificação por descarte em `discardedCandidates` quando a evidência do lexer/parser/check for válida e coerente. Usar ProcessBuilder com argv String[], logs separados e setsid na fronteira JVM. Capturar inputs uma vez, antes da baseline, preservando bytes e permissões; cada comando observa uma cópia independente desse snapshot.

### Contrato público mínimo, versão 1

Executável de fonte: `./bin/kof-mut`. Comandos:

```bash
./bin/kof-mut --version
./bin/kof-mut run --project /caminho/projeto --config kof-mut.json --files scope.json [--report-dir /caminho/relatorios] [--run-id UUID]
```

`--project` e `--files` são obrigatórios em `run`. `--report-dir` é opcional, padrão `<project>/.kof-mut/reports`; a flag removida `--report` retorna 2 antes de efeitos, orientando a migração. Resolver projeto, escopo e raiz de relatórios em relação ao cwd do chamador antes de iniciar subprocessos; `--config` é relativo ao projeto, salvo caminho absoluto explícito. O padrão de `--config` é `kof-mut.json`. `scope.json` contém um array JSON de caminhos relativos de arquivos de produção, sem globs. O chamador determina quais arquivos alterou; o KofMut não depende de Git para escolhê-los. Lista vazia retorna `no_scope`, sem testes nem aprovação. Normalizar, deduplicar e ordenar os caminhos. Arquivo inexistente, fora das raízes, teste, extensão diferente de `.kf`, caminho que escape do projeto ou link simbólico no escopo é erro de entrada, sem descarte silencioso. A seleção cobre arquivos inteiros, não só linhas do diff.

Cada execução reserva exclusivamente `<report-dir>/<project-id>/<run-id>-<sufixo-único>/report.json`. `project-id` é o SHA-256 hexadecimal completo do caminho absoluto canônico do projeto, independente de Git. Aliases canônicos compartilham identidade; projetos homônimos em caminhos distintos e chamadas simultâneas com o mesmo UUID têm resultados independentes. Antes do primeiro comando do projeto, imprimir exatamente uma linha `reportPath=<string JSON absoluta>`. O consumidor decodifica essa string e confere arquivo final, runId, schema, escopo, contagens e exit; o anúncio sozinho identifica uma reserva. Não há último resultado compartilhado. Publicação temporária e movimento atômico no mesmo filesystem; falha retorna 2 sem relatório final utilizável. Relatórios anteriores permanecem intactos.

Validar a raiz canônica antes de criar diretórios. Recusar raiz igual ao projeto ou sobreposta a fontes, testes, inputs explícitos, manifesto, configuração ou escopo. Com configuração inválida, destino interno é recusado sem efeitos; externo seguro pode receber erro atual. Excluir namespace padrão `.kof-mut/reports` e raiz customizada interna de todas as cópias, inclusive `inputs: ["."]`.

Configuração mínima:

```json
{
  "schemaVersion": 1,
  "sourceRoots": ["src"],
  "testRoots": ["tests"],
  "inputs": ["kof.toml", "src", "tests"],
  "checkCommand": ["kof", "check", "Main.kf", "--json"],
  "testCommand": ["kof", "test", "tests"],
  "commandTimeoutMs": 10000,
  "budgetMs": 90000,
  "maxParallelMutants": 1
}
```

Este JSON estabelece o formato, não uma fixture executável pronta: os caminhos e comandos pertencem ao projeto. `inputs` são arquivos ou diretórios relativos explicitamente copiados para cada sandbox, incluindo fontes, testes e scripts necessários. Nunca copiar `.git`, saídas do mutador ou a própria sandbox. Não seguir links simbólicos para fora dos inputs. Não depender de arquivos ignorados omitidos sem declarar essa dependência. Preservar bytes e caminhos relativos, incluindo arquivos novos ainda não rastreados.

Extensão M3P autorizada: `maxParallelMutants` é inteiro JSON original em 1..4; ausência ou null significa 1. Validar antes de conversões e de efeitos sobre o projeto. Valores decimais, exponenciais, fora da faixa ou incompatíveis retornam 2, preservando as proteções de relatórios internos/externos. A configuração e o relatório mantêm schemaVersion 1; apenas o relatório humano mostra o limite efetivo. Projetos com recursos externos compartilhados devem usar avaliação serial; cópias de fontes não isolam esses recursos.

Executar `checkCommand` e `testCommand` como argv, com cwd na cópia temporária e o ambiente herdado, sem concatenar `sh -c`. Não acrescentar `--target` nem duplicar destinos. A versão 1 aceita o protocolo de evidência do `kof check --json` e das suítes nomeadas de `kof test`; wrappers podem preservar esses protocolos. Não anunciar suporte a qualquer runner arbitrário apenas porque retorna um código.

Antes da conversão tipada do check, exigir inteiros JSON originais: `filesChecked` em 1..2147483647 e `errorCount` em 0..2147483647. Para aprovação, exigir JSON válido com `success: true` e zero erros, além de exit 0. Rejeição só autoriza descarte com `success: false`, exit 1 e contagem de erros positiva e igual aos diagnósticos ERROR. Essa contagem pode ser apenas a entrada: não equivale ao número de imports verificados. Os testes de integração precisam provar que um erro em fonte importada é detectado. Para os testes, exigir conclusão reconhecida de pelo menos uma suíte Kof com casos executados, além do exit coerente. Reconhecer os resumos por suíte da versão suportada, sem confundir contagem de arquivos com contagem de casos. Saída truncada, zero casos, ausência de resumo ou resultado contraditório é `TestError`, não aprovação nem mutação detectada. Não criar um novo executor de testes Kof.

### Operadores iniciais e seleção

Usar lexer e parser oficiais para reconhecer expressões. Tokens dentro de comentários, strings e caracteres não são operadores de código. Delimitadores de genéricos não são comparações. Considerar métodos, funções, construtores, inicializadores de campos e lambdas; uma forma válida não percorrida deve aparecer como escopo não suportado, sem PASS.

| Família | Substituições exatas da versão 1 |
| --- | --- |
| Limites numéricos | `<` ↔ `<=`; `>` ↔ `>=` em expressões binárias |
| Igualdade | `==` ↔ `!=` em expressões binárias |
| Lógica | `&&` ↔ `||` em expressões binárias |
| Booleanos | literal `true` ↔ `false` |
| Aritmética | `+` ↔ `-`; `*` ↔ `/`, em expressões binárias; não alterar concatenação conhecida |

Cada candidato altera exatamente um token, usando os offsets do lexer da versão suportada. Não confiar que `BinaryExpr.position()` localiza o operador: o parser pode registrar a posição posterior à expressão. Provar a associação AST/token, inclusive com operadores repetidos e aninhados, antes de gerar mutações em arquivos reais. Um token ambíguo ou impossível de associar é uma limitação explícita. Conferir o token original no snapshot; após a substituição, comparar os tokens com o lexer oficial, exigindo que apenas o selecionado mude e considerando deslocamentos UTF-16. Reanalisar o arquivo alterado com o parser oficial antes do check. Rejeições do frontend e mudanças indevidas de tokens descartam o candidato; divergência do snapshot e exceção inesperada são erros da ferramenta.

Não incluir remoção de blocos, alteração de assinaturas, números arbitrários, operadores de incremento, código gerado ou mutação dos testes. Não adicionar sistema de plugins na versão 1. Não fazer transformação por regex sobre texto bruto. Uma troca aritmética rejeitada com evidência válida e coerente é descartada e documentada, jamais `Killed`.

### Ciclo, isolamento e classificação

Baseline na cópia intacta: executar exatamente um check e um comando de testes; qualquer falha interrompe a geração/execução dos mutantes. Selecionar candidatos em ordem determinística por caminho, offset e operador. A exceção M3P aprovada mantém um por vez com maxParallelMutants=1 e permite até quatro avaliações simultâneas quando configurado. Cada candidato parte de uma cópia limpa do mesmo snapshot inicial, com logs próprios. Uma vaga liberada admite o próximo candidato sem esperar pelos demais. Somente o coordenador agrega resultados, apresentando mutantes e descartes na ordem original; a ordem de início/conclusão dos processos não é prometida. Não alterar o projeto original, acumular mutações, selecionar testes por cobertura inexistente ou reutilizar resultados de outra execução.

O limite global usa relógio monotônico e inclui baseline, check e testes dos mutantes. Cada comando também tem limite individual, sempre reduzido ao tempo global restante. Parar de iniciar comandos ao acabar o orçamento, encerrar a árvore de processos em execução e finalizar o relatório parcial. Usar mecanismo de processos disponível no Linux/JVM e comprovar a limpeza de descendentes. O shutdown hook por execução coordena início/registro/cancelamento com lock JVM e limpeza idempotente, removido após saída normal. SIGINT/TERM durante comando ativo resultam em 130/143, limpeza do próprio grupo/sandbox e preservação das outras execuções. Interrupção externa não exige relatório parcial nem pode publicar complete falso. Processos que deliberadamente abandonem o grupo controlado não têm garantia. Não exigir cgroups, containers ou novas restrições de ambiente. `process.run` isoladamente não comprova cancelamento da árvore. Não deixar o processo de teste preso por leitura sequencial de stdout/stderr.

No M3P, o orçamento/cancelamento é conferido sob o mesmo lock de início e registro de cada comando. Cancelamento sinaliza todos os grupos antes de esperar, com um único prazo monotônico de limpeza de até 2000 ms, sem reiniciá-lo por grupo, tarefa ou nova tentativa. Falha de limpeza individual que escale para cancelamento conserva o relógio daquela tentativa. Recolher tarefas fora do lock antes de remover a sandbox e publicar. Falha inesperada ou de limpeza resulta em error/2 quando publicável e impede aprovação.

| Estado do mutante | Evidência exigida |
| --- | --- |
| `Killed` | Check válido; suíte executada e concluída; evidência reconhecida de falha dos testes |
| `Survived` | Check válido; suítes com casos executados e resultado verde |
| `CompileError` | Estado histórico; novas execuções usam `discardedCandidates` para rejeição coerente do compilador |
| `Timeout` | O limite encerrou check ou teste; registrar a fase e a limpeza |
| `TestError` | Runner não iniciou/concluiu corretamente ou a evidência é insuficiente |
| `Pending` | Candidato ou fase não iniciados por fim do orçamento ou encerramento por erro; motivo em `evidence` |

Baseline vermelha é `baseline_failed`; ferramenta indisponível, falha do frontend ou erro de entrada é `error`; orçamento encerrado ou qualquer avaliação inconclusiva é `incomplete`; ausência de candidatos aplicáveis é `no_mutants`. `Timeout`, `TestError`, `Pending` ou orçamento esgotado impedem `complete`; esses estados nunca elevam a avaliação. Descartes esperados permitem `complete` com pelo menos um mutante aplicável. Se todos forem descartados, retornar `no_mutants/3`, sem evidência de qualidade dos testes. `counts.compileError` permanece por compatibilidade com valor zero nas novas execuções. `complete` significa avaliação concluída, não aprovação: pode conter sobreviventes. Escopo com construções não suportadas também é `incomplete`.

Sem instrumentação de cobertura, não emitir `NoCoverage`. Um sobrevivente não prova ausência de cobertura, e uma mutação equivalente não prova teste fraco. Na versão 1, possíveis equivalentes permanecem como sobreviventes para análise humana; não oferecer comentário de supressão, exclusão automática ou classificação inferencial como prova. Não exigir um teste impossível para um comportamento equivalente.

### Relatórios e saída

JSON UTF-8 com `schemaVersion: 1`, `toolVersion`, `kofVersion`, `runId`, `status`, `scope`, evidência da `baseline`, `counts`, `mutants`, `discardedCandidates`, `limitations`, `startedAt` e `durationMs`. Cada mutante inclui `id`, `file`, `operator`, `original`, `replacement`, `location` com linha/coluna base 1 e offset/comprimento, `status`, fase, duração e resumo da evidência. Documentar que o offset segue os índices de String da JVM; comprovar Unicode para não confundir índice UTF-16 com byte UTF-8.

Forma normativa dos campos compartilhados com os sensores: `scope` é array de caminhos relativos; `counts` é objeto de inteiros não negativos com `candidates`, `executed`, `killed`, `survived`, `compileError`, `timeout`, `testError`, `pending`; `mutants` e `discardedCandidates` são arrays; `limitations` é array de strings; `startedAt` é ISO 8601 UTC; `durationMs` é inteiro não negativo. `runId` é UUID gerado pelo chamador e passado opcionalmente por `--run-id`; na ausência, o KofMut gera um UUID e o imprime no relatório humano. O adaptador dos sensores sempre fornece `--run-id` e confere igualdade no JSON.

`baseline` contém `status` (`passed`, `failed` ou `error`), `check` e `test`; cada fase contém `exitCode`, `durationMs` e `summary`, podendo ter valores JSON null quando não foi iniciada. O check acrescenta `filesChecked`; o teste acrescenta `executedTests` e `failedTests`. Uma baseline só é `passed` com check válido e pelo menos um caso executado com zero falhas.

Cada mutante usa `location: {line, column, offset, length}`, `phase` em `parse|check|test`, `durationMs` inteiro e `evidence` como resumo textual. `id` é string estável na execução, única por arquivo/offset/substituição. `operator` pertence a `boundary`, `equality`, `logical`, `boolean`, `arithmetic`. `original` e `replacement` são os textos dos tokens. Para um `Pending`, usar a fase que ainda falta iniciar e duração zero; candidatos que não chegaram a iniciar no encerramento por erro usam `parse` e motivo explícito em `evidence`. O resultado geral nesse encerramento permanece `error/2`. Campos obrigatórios ausentes ou tipos incompatíveis invalidam o relatório. A versão 1 não promete semântica para extensões do schema.

Manter por arquivo a quantidade de candidatos e de mutantes de cada estado no relatório humano; o JSON permite derivá-la agrupando `mutants`. `counts.candidates` é o tamanho de `mutants`; `counts.executed` soma todos os estados exceto `Pending`; `counts.pending` conta `Pending`. As demais contagens correspondem exatamente aos estados homônimos. Cada candidato deve terminar em um estado de mutante ou ser documentado em `discardedCandidates`; os descartes não entram nas contagens de mutantes. As contagens devem reconciliar também quando o cancelamento apresentar falha de limpeza, preservando os resultados já concluídos e seus IDs, fases e logs. Não fornecer percentual de aprovação na versão 1. O relatório humano mostra totais, limitações e localizações dos sobreviventes. Logs detalhados ficam em área local de evidência e não no repositório público.

Cada item de `discardedCandidates` contém `id`, `file`, `operator`, `original`, `replacement`, `location`, `phase` (`parse` ou `check`), `durationMs` e `evidence`, nos mesmos formatos dos mutantes. Preservar todos os diagnósticos do Kof, códigos e referências aos logs. Falha exclusiva da comparação de tokens usa a mensagem fixa `Variant changes tokens other than the selected token`. IDs e logs mantêm os índices originais mesmo após descartes.

Validar a segurança canônica do destino antes de autorizar publicação, inclusive em erro. Sem configuração validável, só publicar fora do projeto avaliado; destino interno retorna 2 com explicação no terminal, preservando bytes/permissões e sem criar diretórios ou iniciar comandos. Com configuração válida, proteger inputs, raízes, manifesto, configuração e escopo, inclusive aliases por links simbólicos.

Publicar o JSON por gravação temporária seguida de rename; `runId` e escopo devem ser os da execução solicitada. Não ler um relatório antigo como resultado atual. Caminhos de evidência gerada são por execução, sem concorrência sobre arquivo fixo.

Códigos de saída: `0` somente para `complete` com pelo menos um mutante avaliado, todos `Killed` e nenhuma limitação; `1` para `complete` com sobreviventes; `2` para entrada inválida, baseline vermelha ou falha da ferramenta; `3` para `incomplete`, `no_scope` ou `no_mutants`. O JSON diferencia os motivos. `--version` e ajuda retornam 0 sem representar avaliação de qualidade.

## Milestones

### M1 — Base do projeto e prova do frontend em Kof

Criar o checkout local somente quando este plano for autorizado para execução. Se o diretório já existir, ler suas instruções e preservar o conteúdo. Adicionar `AGENTS.md`, `kof.toml`, `VERSION` inicial `0.1.0`, `LICENSE`, `README.md`, `README.pt_BR.md`, `bin/kof-mut`, `scripts/check` e módulos em `src/main/kof/kofmut/`, com testes em `src/test/kof/kofmut/`. Os scripts de lançamento não conterão o motor de mutação.

O lançador descobre `kof` e a instalação por `kof info --json`, localiza seu `lib/kof.jar` e o Java embutido, verifica a versão suportada e usa o classpath explícito no build e no runtime. Cache de build local deve incluir versão do Kof e fontes do KofMut, sem aproveitar binários incompatíveis. Provar a execução pelo lançador usando `kof build --classpath` e classe main efetivamente emitida; não presumir que `kof run --classpath` seja suportado.

Provas: leitura de arquivo, lexer/parser, associação precisa de um operador à sua expressão, percurso de método/lambda/inicializador e saída de erro do frontend. Nenhuma regex substitui a gramática. Adotar um percurso explícito da AST com diagnóstico de forma não suportada; não depender de uma API pública de transformação pós-parse que não foi comprovada.

Validação futura: `./bin/kof-mut --version` e `./scripts/check`. A versão exibida deve vir de `VERSION`; os testes precisam executar chamadas reais ao frontend instalado e verificar localização de um operador. Se o acesso necessário ao frontend não funcionar em Kof, registrar a prova mínima e parar antes de M2, sem implementar o núcleo em outra linguagem.

### M1R — Bootstrap em Kof, sem Python

Pré-condição para iniciar M2. Substituir `scripts/launch.py` por `scripts/bootstrap/Launch.kf` e pela ponte mínima `scripts/launch`; atualizar `bin/kof-mut` e `scripts/check`. Preservar seleção e frontend existentes. Remover o arquivo Python após a substituição comprovada. Atualizar README.md e README.pt_BR.md, mantendo identificadores técnicos canônicos.

Expandir os testes Kof do CLI para executar sem Python no PATH; comprovar argumentos vazios, espaços, Unicode, nova linha, metacaracteres, `--target` e `--deps`, cwd e ambiente; invalidação de cache por VERSION e fonte; executável fixado mesmo após troca de link; rejeição de versão e JSON inválidos; falha de compilação mesmo com classes emitidas; concorrência com cache frio sem builds duplicados; interrupção sem cache parcial utilizável e nova tentativa bem-sucedida. Manter os dois comportamentos originais do CLI e as nove provas do frontend.

Validar por `PATH=/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64/bin:$PATH ./scripts/check`, exit 0, e repetir em cópia sem `.git`, `build/` ou logs pessoais, num caminho com espaços e PATH sem Python. Registrar tempos de chamadas fria/quente, prova negativa com versão incompatível e `git diff --check`. Acrescentar `.agent/validation/kofmut-m1r.md` e manifesto de fontes próprio, preservando relatório e manifesto históricos do M1. Nenhuma aceitação pendente pode ser marcada como concluída; se 0.6.4 impedir uma garantia necessária, registrar o bloqueio sem restaurar Python silenciosamente ou alterar Kof.

### M1P — Aproximar a inicialização Kof do tempo do Python

Transformar `scripts/bootstrap/Launch.kf` em preparação somente na falta de cache válido. Compilar `kofmut.launch.RuntimeEntry` junto com a aplicação, incluindo um único runtime com os métodos JSON gerados daquele programa. A ponte Bash fixa o Kof, captura `info --json`, identifica mudanças e faz `exec` na imagem. A entrada Kof valida a instalação fresca, caminhos e identidade, consome e remove o contexto, configura as propriedades existentes e chama `Default.Main.main` na mesma JVM com `Class[]` e `Object[]` explícitos. Cinco argumentos internos: raiz, Kof fixado, modo, contexto e imagem; depois, argv original. Versão, ajuda e demais comandos compartilham esse caminho, com duas JVMs de trabalho no cache quente. O script oficial 0.6.4 inicia também `java -version` antes de `info`; em 2026-10-16 o usuário confirmou manter o executável oficial e documentar essa sondagem. Contando todos os processos Java são três, e a medição do comando completo inclui todos eles.

Usar `build/cache/kof-launch-v2/`, separando descritores de localização e imagens. A chave preliminar SHA-256 contém modo, raiz, Kof fixado e conteúdo, JSON bruto fresco, lançadores, VERSION, manifesto e fontes pertinentes, em ordem determinística com campos NUL. Kof publica atomicamente `kofmut-location-v1` com Java e jar em campos NUL, sem JSON em Bash ou `eval`. Incorporar BLAKE2b de 512 bits do jar inteiro, via GNU `b2sum`, na identidade final SHA-256. Kof confere hashes e compila os bytes capturados. Preservar bloqueio, nova consulta ao cache sob bloqueio e publicação atômica somente com compilação bem-sucedida e ambas as entradas JVM. Descriptor/imagem ausentes ou inconsistentes provocam preparação automática; erro retorna 2 sem alternativa antiga. Projetos avaliados não participam da identidade.

Conduzir por TDD em Kof, um comportamento por ciclo; `./scripts/check` mantém os 11 comportamentos CLI e nove provas do frontend. Demonstrar cache quente com `run`/`build` recusados, invalidação por fontes/inicializador/VERSION/manifesto/instalação/jar (inclusive timestamps preservados e distribuição descartável), recuperação de cache incompleto, concorrência, falha/interrupção e nova tentativa. Provar argv especial, cwd, ambiente, exit e sinal na JVM da aplicação; repetir em cópia limpa com espaços e PATH sem Python contendo utilitários GNU necessários. Rever o desenho com `refactor-design` somente após comportamentos e checkpoint público verdes.

Comparar `--version` ao Python do commit `adec628` com mesmo Kof e fontes. Um aquecimento por lançador; três blocos de 11 pares alternados; registrar os 33 tempos por lançador, saídas, medianas e dispersão, sem compilações. Exigir mediana Kof ≤ 1,10 × mediana Python (referência histórica: 0,65 s; Kof: 2,70 s). Medir também três caches vazios e documentar custo inicial. Marcar concluído apenas com comportamentos e desempenho aprovados. Atualizar EN/PT, relatório e manifesto M1P preservando evidências anteriores; documentar utilitários, migração e recuperação pela remoção do namespace. M2 e a comprovação do orçamento de 90 s permanecem pendentes.

### M2 — Primeiro ciclo completo e operadores definidos

**Registro histórico do contrato M2, substituído pelo M3:** Implementar `run --project … --config … --files … --report … [--run-id UUID]`, configuração/escopo validados antes de comandos, snapshot único dos inputs, baseline obrigatória e variantes sequenciais independentes. Seleção e transformação usam somente AST/tokens oficiais, copiados antes do parse; substituir as 14 direções das cinco famílias, percorrer os contextos contratados e registrar formas não suportadas.

Provar em 0.6.4 processos com argv separado/cwd/stdin fechado, JSON aninhado com null e metadados de arquivos antes de depender dessas APIs. Cada comando usa setsid, stdout/stderr separados e prazo mínimo entre commandTimeoutMs e orçamento restante. Exigir check JSON válido/coerente e protocolo de teste completo por suíte; resultados inválidos são inconclusivos. Publicar JSON v1 por rename atômico e relatório humano por arquivo, com sobreviventes localizados, sem percentual.

**Registro histórico M2:** o exemplo deste parágrafo usa a flag --report da entrega original; o contrato M3 vigente substitui essa flag por --report-dir. TDD pelo CLI em Kof: detected, survived, invalid, operadores, entradas/isolamento, protocolos, prazos e relatório. Validação: `./scripts/check`; `./bin/kof-mut run --project fixtures/detected --files fixtures/detected/scope.json --report .agent/tmp/detected.json` (exit 0); comandos equivalentes `survived` (1) e `invalid` (3). Configuração padrão dentro de cada projeto. Repetir suíte em cópia limpa com espaços e sem Python no PATH. Atualizar READMEs EN/PT com comandos, requisitos, estados e limites. Registrar evidência por critério, revisar a força das asserções e executar `git diff --check`.

Critérios de aceitação M2: baseline antes de gerar candidatos, dois casos contados separadamente de arquivos, SKIP/filtros/truncamento/contradições sem falsa aprovação, inputs novos/importados preservados, escopo normalizado/deduplicado/ordenado, teste/link/escape recusados sem comandos, cada variante observada pelos comandos com uma troca e sem estado anterior, 14 substituições e contextos obrigatórios, concatenações conhecidas excluídas, Unicode/CRLF/genéricos e operandos de chamada corretos, construção válida não suportada impede complete, timeout individual e global com descendentes comprovados encerrados, restantes Pending e contagens reconciliadas, relatório atual mesmo após baseline falhar.

### M3 — Relatórios por execução, concorrência e aceitação externa

Execução autorizada em 2026-10-17 na base `37b72ca21309f0250497e3b45be77f6d2961c314`, branch `kofmut-frontend`, árvore limpa. GPT 6.1 Sol/xhigh, Kof 0.6.4 Linux/JVM, sem subagentes, worktrees, commits, remotes ou publicações. O plano fornecido pelo usuário é a intenção vigente. M4 conserva os guias ampliados como etapa posterior.

**M3.1, relatórios independentes:** editar `Main.kf`, `Inputs.kf`, `Sandbox.kf`, `Run.kf` e os testes Kof do ciclo. Substituir `--report` por `--report-dir` opcional, padrão `<project>/.kof-mut/reports`; caminhos de projeto/escopo/raiz relativos ao cwd e configuração relativa ao projeto. `--report` retorna 2 antes de efeitos. Reservar exclusivamente `<raiz>/<SHA-256 do caminho canônico do projeto>/<runId>-<sufixo>/report.json`, anunciar exatamente uma linha `reportPath=<string JSON absoluta>` antes dos comandos e publicar atomicamente. Preservar JSON v1/exits M2 e relatórios anteriores. Validar destino canônico antes de diretórios; excluir namespace padrão e raiz interna customizada do snapshot, inclusive com `inputs: ["."]`. Configuração inválida recusa destinos internos; externo seguro pode receber erro atual. Provar padrão/customizado, Unicode/espaços, aliases, preservação e migração das asserções antigas.

**M3.2, cancelamento e recuperação:** provar interoperabilidade do shutdown hook na distribuição suportada; registrar os recursos ativos com coordenação entre iniciar/registrar/cancelar e limpeza idempotente. Remover hook na saída normal. INT/TERM durante comando ativo devem dar 130/143, limpar grupo e sandbox, preservar outra execução e permitir execução posterior. Orçamento monotônico desde entrada em `run`, sem iniciar próximo comando após esgotar. Provar timeout em baseline/check/teste, candidatos Pending com duração zero, concorrência simultânea com mesmo UUID e projetos homônimos, falha real de publicação sem JSON final e recuperação. Usar grupos Linux/JVM existentes, sem cgroups/containers nem promessa para processos que abandonem deliberadamente o grupo.

**M3.3, equivalência e regressões:** criar `fixtures/equivalent`, ajuste `if (x < 0) { x = 0 }` com entradas negativa/zero/positiva e resultados zero/zero/positivo. Esperar exatamente um Survived, complete/1, nenhum descarte; documentar equivalência sem supressão. Reexecutar contratos M2 de evidência, baseline, descarte, contagens e isolamento.

**M3.4, ensaio externo:** original `/home/renanfranca/projects/kof-sifuture` somente lido; cópias em temporários do sistema e somente logs/resultados em `.agent/tmp/`. Confirmar revisão e casos reais de `GameJourney.kf`. Adaptador temporário reutiliza `prepared_sources` e check oficial JSON, sem alterar wrapper original. Provar baseline check/testes e erro importado detectado em cópia; recriar intacta. Escopos Background.kf e Meteor.kf, commandTimeoutMs=10000, budgetMs=85000, limite externo 90 s desde invocação completa. Aquecimento, três amostras quentes por escopo e uma pequena com cache KofMut vazio em cópia descartável. Registrar tempos, durationMs, baseline, estados, descartes, Pending, versões e exits, inclusive limitações. Não ajustar orçamento/testes/candidatos para obter conclusão.

**M3.5, documentação e entrega:** reconciliar READMEs EN/PT, contrato vigente deste plano, plano externo dos sensores, guia inicial e plano externo original KofMut. Preservar histórico datado; documentar `--report-dir`, descoberta pela invocação, organização, validação JSON, discardedCandidates e 85 s internos/90 s externos. Não implementar/ativar sensores. Criar `.agent/validation/kofmut-m3.md` por critério e manifesto SHA-256 dos arquivos entregues.

Validação em cada limite e no handoff: `PATH=/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64/bin:$PATH kof test src/test/kof/kofmut/Run.kf --tag m3`, `./scripts/check`, `./scripts/launch contracts`, `git diff --check`. Novos cenários com tag m3; fixtures CLI detected/survived/invalid/equivalent com exits 0/1/3/1. Repetir validação completa em cópia limpa com espaços e PATH sem Python; wrapper Python do ensaio externo é independente. Avaliar separadamente a correção normativa da expectativa e a força de cada verificação. M3 termina com robustez comprovada, ensaios executados e documentos reconciliados; prontidão dos sensores depende dos tempos medidos.

Texto histórico do escopo M3 original, preservado para contexto:

Ampliar os contratos de saída, orçamento global e cancelamento entregues no M2; testar concorrência entre duas execuções, recuperação e preservação da árvore original. Confirmar que faltas de ferramenta ou de evidência dos testes não se tornam mutações detectadas.

Preservar e ampliar as provas M2 de baseline vermelha, zero testes, runner quebrado, descendentes e timeout, acrescentando concorrência entre execuções e recuperação. Adicionar a fixture equivalente, que deve usar uma transformação como `if (x < 0) { x = 0 }` → `if (x <= 0) { x = 0 }`, sem inventar uma diferença funcional. Seu resultado esperado é sobrevivência e sinalização para análise, sem exclusão automática.

Ensaiar leitura externa do SiFuture com inputs/escopo em cópias temporárias; não adicionar configuração ao SiFuture neste plano. Medir custo num arquivo pequeno e num representativo, registrando tempo, candidatos concluídos/pendentes e versão. O orçamento de referência dos sensores é 90 s; esta medição não autoriza aumentá-lo. Se não houver conclusão dentro dele, registrar a limitação de uso no hook e o gargalo; não prometer adoção diária pronta, filtrar candidatos silenciosamente ou adicionar cobertura/incremental sem novo planejamento.

### M3P — Paralelismo limitado e prazo dos sensores

Execução local autorizada em 2026-10-21, base `c09861a`, branch existente `kofmut-frontend`. Sem worktrees, subagentes, commits ou publicações. O plano M3P fornecido pelo usuário prevalece. Kof 0.6.4 Linux/JVM; SiFuture `82111142c85f98b970ccd65fbf044e492d017729`, 114 casos canônicos, original somente lido.

**M3P.1, configuração e provas:** ampliar `Inputs.kf`, `JsonShape.kf` e testes CLI em `Run.kf`: `maxParallelMutants` inteiro JSON 1..4, ausente/null = 1, rejeição antes de comandos e efeitos internos. Provar `spawn`, `Channel<T>`, `Handle<T>`, `done`/`await`, resultados compostos e falhas no binário 0.6.4 antes de depender deles.

**M3P.2, executor:** `Run.kf`, `RunResources.kf`, `Evidence.kf` e runner sintético. Baseline única antes dos mutantes; avaliação individual retorna resultado próprio; fila tipada e até min(limite, candidatos) tarefas, distribuição dinâmica, snapshots e variantes independentes, agregação somente no coordenador em ordem original. Caminho serial com limite 1. JSON v1/flags/contagens/exits preservados; limite no relatório humano.

**M3P.3, encerramento:** registro de todos os grupos, orçamento conferido sob o lock imediatamente antes de iniciar cada comando, timeout individual reduzido ao prazo global. Orçamento fecha admissão/cancela grupos, não iniciados Pending; grupos interrompidos Timeout na fase. Sinalizar todos antes de esperar, prazo de limpeza compartilhado de até dois segundos. Recolher tarefas antes de limpar/publicar; falha inesperada error/2, falha de limpeza impede aprovação. Provar check/test, INT/TERM, outra invocação preservada, recuperação e publicação obstruída.

**M3P.4, aceitação e documentação:** `./scripts/check`, cópia limpa com espaços e PATH sem Python. Três pares quentes alternados Meteor limites 1/4, Meteor 4 com cache vazio, Background e escopo conjunto; commandTimeoutMs=10000, budgetMs=85000, teto externo 90 s desde CLI. Exigir complete sem Timeout/TestError/Pending/limitações e reconciliar os 41 candidatos Meteor entre mutantes e descartes. Registrar duração externa/baseline/candidato, recursos com método/limitações, preservação e árvore testada em `.agent/validation/kofmut-m3p.md`. Se o prazo não for atingido, manter aceitação de desempenho pendente. READMEs EN/PT documentam a opção, recursos e dependências externas compartilhadas; guias completos continuam M4.

### M4 — Documentação pública e entrega revisável

Concluir os dois READMEs, `docs/cli.md`, `docs/cli.pt_BR.md`, `docs/operators.md`, `docs/operators.pt_BR.md`, `docs/report-format.md` e `docs/report-format.pt_BR.md`. Documentar os mesmos comandos e campos em ambos os idiomas, limites de compatibilidade, dependências, exemplos detectado/sobrevivente, distinção entre mutador e executor de testes, cancelamento e ausência de cobertura. JSON e IDs do CLI são canônicos e não são traduzidos.

Criar `.agent/validation/kofmut-v0.1.0.md` com a revisão testada, comandos, resultados essenciais e pendências; guardar logs em `.agent/tmp/` excluído localmente. Verificar links, `git diff --check`, todo `./scripts/check` e uma execução a partir de uma cópia limpa que não dependa de caches pessoais nem de caminhos `/home/renanfranca` embutidos no produto.

Se houver autorização explícita para publicação, verificar nome/disponibilidade, publicar fonte no repositório público previsto, inspecionar o checkout remoto e registrar URL/SHA. Se a autorização cobrir apenas implementação local, entregar a árvore local revisável e listar publicação como pendência. Não criar release instalável, automação de CI ou pipeline de publicação neste plano.

## Progress

- [x] Direção, limites, licença, idiomas e contrato de integração documentados.
- [x] Evidência básica de interoperabilidade e limites do ambiente registrados.
- [x] M1 — Base, lançador, leitura de arquivo, associação AST/token, percurso requerido e diagnósticos comprovados em Kof 0.6.4; evidências em `.agent/validation/kofmut-v0.1.0.md`.
- [x] M1R — Bootstrap em Kof, sem Python; 11 testes do CLI e nove provas do frontend verdes, inclusive em cópia limpa com espaços e PATH sem Python; evidências em `.agent/validation/kofmut-m1r.md`.
- [x] M1P — Imagem conjunta, contratos aprovados em cópia limpa sem Python e mediana até 10% acima do Python; duas JVMs de trabalho mais a sondagem oficial autorizada.
- [x] M2 — Ciclo completo sintético, cinco famílias e 14 direções, isolamento por snapshot, protocolos, prazos/descendentes e JSON v1; 21 contratos do lançador, 17 testes do ciclo e 14 provas do frontend verdes, inclusive em cópia limpa sem Python.
- [x] Correções M2, proteção — reprodução antes da correção destruiu o input binário; suíte posterior passou em 18 casos, incluindo bytes/permissões, alias canônico, ausência de comandos/diretórios e relatório externo atual com UUID.
- [x] Correções M2, seleção — prova inicial identificou `this.value` numérico ocultado por local String; 15 grupos do frontend e cenário CLI com dois mutantes (Killed/Survived, complete/1) passaram.
- [x] Correções M2, contadores — suíte de 20 testes passou; contadores inválidos na baseline e variante não autorizam aprovação/descarte, e limite superior de filesChecked é aceito.
- [x] Correções M2, descarte — rejeições coerentes do check, parser e lexer e divergência de tokens documentadas; próximo candidato independente continua, descartes não entram nas contagens e todos descartados resultam em no_mutants/3.
- [x] Correções M2, revisão de caminhos — projeto `/` reproduziu a mesma perda de bytes com configuração inválida; regra de prefixo corrigida e prova completa de preservação passou novamente.
- [x] Correções M2, entrega — scripts/check retornou 0 com 21 contratos do lançador, 22 testes do ciclo e 15 grupos do frontend; repetição do ciclo após a última correção passou nos 22 casos. READMEs EN/PT, relatório M2 e manifesto atualizados, com histórico preservado.
- [x] M3.1 — Reserva exclusiva, descoberta JSON, identidade canônica, rejeição de --report e snapshot sem relatórios comprovados em dois cenários m3 (snapshot-green.log, 14380 ms); regressões M2 migradas para descoberta e revalidadas no checkout e cópia limpa.
- [x] M3.2 — Seis cenários m3 passaram (robustness-complete.log, 28359 ms): INT/130 e TERM/143, processos e sandboxes limpos, execução simultânea preservada, publicação obstruída com exit 2, recuperação, orçamento em preparação/baseline/check/teste e identidades/cwd. A falha real revelou IOException escapando de catch String; catch Exception foi comprovado em 0.6.4.
- [x] M3.3 — Fixture equivalente com três casos reais e um Survived/complete/1 sem descartes; scripts/check retornou 0 com 21 contratos do lançador, 29 testes do ciclo e 15 grupos frontend. Exemplos CLI retornaram 0/1/3/1, fontes preservadas. Prova adicional da janela iniciar/registrar distinguiu lock funcional de cópia sem coordenação. Repetição limpa sem Python também aprovada.
- [x] M3.4 — Sete medições com 85/90 s, baseline de 114 casos e erro importado comprovados. Background completo nas quatro amostras; Meteor incomplete nas três, com limitação medida preservada. Checkout original intacto.
- [x] M3.5 — READMEs EN/PT, contrato vigente, sensores, guia inicial e plano externo original reconciliados; relatório por critério e manifestos M3 entregues, históricos preservados. Sensores não ativados.
- [x] M3P.1 — Configuração validada antes de conversões/efeitos; dois cenários parallel-config passaram (19450 ms). Prova real de spawn, Channel, Handle, done/await, resultado composto e exceção passou na distribuição 0.6.4. Campo opcional lido como Object e convertido somente após validação original; Int ausente falha no decoder e atribuição nullable Int gerou VerifyError nessa distribuição, sem alterar Kof.
- [x] M3P.2 — Três cenários parallel passaram (17444 ms): limites/padrão, sobreposição e reposição dinâmica, snapshot independente, baseline única bloqueante e classificação/ordem com descarte, Killed, Survived e TestError. Kof 0.6.4 exige spawn em função nomeada fora de try/finally com receptor explícito; a forma efetiva foi comprovada em módulo com package antes de uso.
- [x] M3P.3 — Corrigido e validado em 2026-10-22 na base 438c775: dez cenários parallel e sete m3 verdes; scripts/check e cópia limpa com espaços/PATH sem Python retornaram 0, com 21 contratos, 41 testes do ciclo e 15 grupos frontend. Os 49 inputs coincidem por SHA-256; seis candidatos preservados em cada regressão, sem perder Killed, Survived ou descarte, e Pending por erro explícito. Reprodução vermelha, crash intermediário da JVM e auditoria por critério registrados em .agent/validation/kofmut-m3p.md.
- [ ] M3P.4 — Desempenho pendente. Evidência histórica da revisão 438c775: scripts/check final e cópia limpa sem Python passaram em 21 contratos, 39 testes do ciclo e 15 grupos frontend. Dez medições finais preservaram 114 casos, comandos, orçamento e original. Background concluiu com limites 1/4; Meteor 4 quente concluiu 36/41 com quatro Timeout e um Pending, frio atingiu 90 s sem JSON, conjunto concluiu 35/42. Aceitação de desempenho permanece pendente; marco não está marcado como satisfeito.
- [ ] M4 — Documentação e entrega revisável; publicação apenas quando autorizada.

## Validation

### Correção M3P.3: evidência de 2026-10-22

Primeira fronteira, regressões antes da implementação: `kof test src/test/kof/kofmut/Run.kf --tag parallel`, exit 1, três falhas em dez cenários (55634 ms). Todas falharam em `assertParallelCandidates`: faltam candidatos no relatório de erro. Os testes já haviam confirmado pais/descendentes ativos, sinais ineficazes com descendentes ainda ativos após error/2 e, nos dois cenários parciais, marcadores de conclusão antes do vencimento. `.agent/tmp/m3p-preservation/parallel-all-red.log`, `red-reports/` e `red-engine.sha256` preservam a prova; `four-active-red.log/json` preservam a primeira regressão isolada. O manifesto anterior está em `.agent/validation/kofmut-m3p-438c775.sha256`. Segunda fronteira: após capturar erros de cancelamento e de join, o coordenador recolhe/agrega antes de propagar a falha. `parallel-final.log`: dez cenários, exit 0, 59076 ms; `m3.log`: sete cenários, exit 0, 32973 ms. Os três relatórios preservam seis candidatos únicos; contagens observadas em `acceptance-focused.json`. Asserções adicionais conferem os arquivos de log efetivamente referenciados, fases, durações, posições e preservação do relatório anterior. Revisão refactor-design no escopo alterado não justificou outra refatoração: agregação continua exclusiva do coordenador, estado por execução, tarefas recolhidas fora do lock e relógio de limpeza intacto. A validação completa posterior está registrada na fronteira final abaixo.

Registro de falhas: a primeira tentativa de teste não compilou por usar toString em List; a asserção usa json.encode. A primeira execução após a correção (`parallel-green.log`) passou nos cenários parciais, mas falhou genericamente no cenário de quatro tarefas antes de salvar um relatório novo. A inspeção posterior identificou `SIGSEGV` da JVM embutida no C2 CompilerThread2 durante java.util.regex.Matcher::match, aos 2,8 s, no mesmo cenário (`jvm-crash/hs_err_pid903853.log` e replay). A causa interna do crash não foi diagnosticada; Kof/JDK e opções de execução permanecem intactos. O teste passou a incluir stdout/stderr no diagnóstico de exit e preservar observações após a limpeza real. Repetições `parallel-diagnostic.log` (dez cenários, 56540 ms) e `parallel-final.log` passaram. Esses registros não são apagados.

Fronteira final: `./scripts/check` retornou 0 no checkout (21 contratos/293773 ms, 41 testes/390468 ms, 15 grupos frontend; 691.746 s externos) e na cópia limpa `/tmp/kofmut-preservation-kdtycd_i/checkout with spaces` (21/284829 ms, 41/359525 ms, 15 grupos; 656.689 s externos). Kof 0.6.4 no início do PATH; cópia sem .git/build/cache/logs anteriores e PATH sem python/python3. Os 49 inputs de validação coincidem por SHA-256 e não mudaram durante os testes. Documentação foi finalizada após os testes sem alterar esses inputs. `git diff --check` e sintaxe Bash passaram. Relatórios finais em `reports/` no checkout e na cópia limpa preservam seis candidatos únicos e as contagens planejadas, com duração 4553–4554 ms no primeiro cenário e 7012–7017 ms nos cenários parciais. `delivery-audit.json` confere ambos os conjuntos e preservação das 257 evidências históricas. O jar mantém seu hash original e as fontes Kof permanecem limpas.

M3P.3 está corrigido e validado. A causa interna do crash isolado da JVM observado na tentativa intermediária continua sem diagnóstico; a evidência foi preservada, os processos confirmados inativos e a sandbox sintética residual removida com identificação positiva. Não houve alteração no Kof/JDK nem opções para contornar o crash. M3P.4 continua pendente por desempenho; não foram feitos novos benchmarks. READMEs EN/PT, este contrato, relatório por critério e manifesto reconciliados; manifesto anterior preservado em `kofmut-m3p-438c775.sha256`. Sem commits, worktrees, subagentes ou publicação.

### Evidência histórica observada do M3P na revisão 438c775

Execução autorizada em 2026-10-21, HEAD `c09861a`, preservando alterações locais. M3P.1: `.agent/tmp/m3p/config-red.log` reproduz aceitação indevida; `config-validated.log` passa nos dois cenários, incluindo ausência/null/1..4 e 12 formas inválidas. A ampliação final cobre 13 formas inválidas, bytes e permissões. `.agent/tmp/m3p/probes/concurrency.log` confirma primitivas no binário 0.6.4. Fontes locais Kof consultadas em `7c237861a9035d84b1f7ec4cfddd89daef4c6ddd`, sem modificações. Evidência completa por critério e pendências em [.agent/validation/kofmut-m3p.md](.agent/validation/kofmut-m3p.md).

M3P.2/M3P.3: `.agent/tmp/m3p/parallel-complete.log` passa nos sete cenários; `m3.log` preserva sete cenários históricos, inclusive obstrução real de publicação e equivalente; `config-final-complete.log` passa com bytes/permissões e 13 valores inválidos. `failure-red.log` reproduz espera indevida por tarefa irmã após falha de log; a versão corrigida recolhe tarefas antes de limpar/publicar e retorna error/2 com fase correta. `deadline-race-red/green` reproduz e corrige Timeout classificado como TestError após desescalonamento. `transition.log` distingue cancelamento com/sem lock na janela start/registro; `budget-boundary.log` distingue orçamento válido de valor calculado antes da proteção. Essas provas intermediárias foram complementadas pela auditoria de repetição de limpeza e pela validação final abaixo. O cancelamento final usa um relógio compartilhado de 2000 ms, com todos os sinais antes das esperas e duração restante por espera.

Auditoria posterior encontrou reinício do prazo entre chamadas de limpeza após falha persistente. `shared-cleanup-red.log` falhou com quatro grupos ativos; `shared-cleanup-green.log` passou em oito cenários (44840 ms). O relógio stopClock agora pertence ao cancelamento inteiro, incluindo escalonamento de falha individual. Prova individual com commandTimeoutMs=500 caiu de 4532 para 2526 ms, preservando error/2. A verificação final `scripts/check` retornou 0: 21 contratos/233254 ms, 39 testes/371880 ms e 15 grupos frontend. Cópia limpa com espaços e PATH sem Python: exit 0, 21/282541 ms, 39/328202 ms, 15 grupos, 622.654 s externos. Os 49 inputs de compilação/testes coincidem por SHA-256. Logs em `check-final.log` e `final-clean/`.

Dez medições na árvore final, depois de terminar as suítes, preservaram SiFuture `82111142c85f98b970ccd65fbf044e492d017729`, 114 casos e commandTimeoutMs=10000/budgetMs=85000/teto externo 90 s. Meteor serial quente: 85.740–85.793 s, incomplete/3. Meteor 4 quente: 85.749–85.834 s, sempre 26 Killed, 10 Survived, quatro Timeout/check e um Pending. Frio 4: interrupção externa aos 90 s, 90.365 s incluindo encerramento, 143 sem JSON final; baseline de 114 casos verificada nos logs. Background 1/4: complete/0 em 10.987/10.688 s. Conjunto 4: incomplete/3 em 85.826 s, 27 Killed, oito Survived, quatro Timeout, três Pending. Relatórios publicados reconciliam 41/42 candidatos, sem descartes/TestError/CompileError. Só Background 4 cumpriu o critério entre seis amostras paralelas exigidas. RSS paralelo quente amostrado 2.24–2.31 GiB; custo mediano por candidato concluído 8651–8746 ms, contra 4600–4769 ms serial. Não calcular aceleração a partir das execuções seriais interrompidas.

Inventários de conteúdo/permissões do original e de cada projeto descartável coincidem antes/depois; hashes do motor também coincidem. Kof e SiFuture originais permanecem limpos, jar 0.6.4 mantém SHA-256 `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62`. READMEs EN/PT reconciliados com a exceção serial autorizada e com os resultados medidos. Dados preliminares anteriores à correção persistente foram preservados separadamente e não substituem as medições finais. M3P.1–3 estão concluídos; M3P.4 mantém pendência de desempenho, M4 e sensores permanecem fora desta entrega. Sem commits ou publicações.

M1, M1R, M1P e M2 foram executados em 2026-10-16; as correções M2 foram executadas em 2026-10-17. A evidência de M2 abaixo e no relatório por critério distingue os contratos já observados das ampliações M3/M4. A tabela histórica ao final preserva os critérios originais; seu estado atual é reconciliado pelas evidências M2 e M3.

### Evidência observada do M3

Base `37b72ca`, alterações locais identificadas pelo manifesto M3, sem commits. `kof test src/test/kof/kofmut/Run.kf --tag m3`: sete cenários, exit 0, repetição final 32382 ms após medições. `./scripts/check`: exit 0, CLI 21/242933 ms, ciclo 29/312145 ms, frontend 15 grupos. Cópia limpa com espaços e PATH sem Python: exit 0, CLI 21/277673 ms, ciclo 29/276335 ms, frontend 15; 566.446 s externos. `./scripts/launch contracts` retornou 0. Fixtures CLI detected/survived/invalid/equivalent: 0/1/3/1, originais preservados. Falhas iniciais e provas de força das asserções em [kofmut-m3.md](.agent/validation/kofmut-m3.md), incluindo janela iniciar/registrar e FileSystemException real. `git diff --check`, Bash e links auditados.

SiFuture `82111142c85f98b970ccd65fbf044e492d017729`, baseline de 114 casos, check de entrada/imports comprovado, original preservado por inventários. Background quente: 10.082–10.434 s; frio: 15.242 s, sempre complete/0 com um Killed. Meteor: 85.773–85.777 s externos, sempre incomplete/3 após esgotar budgetMs=85000, com Timeout/Pending. Todas abaixo do teto externo de 90 s; commandTimeoutMs=10000. A limitação não foi contornada com filtros/testes reduzidos/orçamento maior. Não declarar prontidão geral para sensores. READMEs e três documentos externos reconciliados; M4 e ativação dos sensores permanecem futuros. Nenhuma alteração no Kof, SiFuture original ou sensores.

### Evidência observada das correções M2

Base `7dd5ecc4da16f95acbbb2ed1f8cee4135931dbab`, Kof 0.6.4 confirmado por `kof info --json`. Proteção: `kof test src/test/kof/kofmut/Run.kf --tag preservation` falhou antes da correção com `invalid config must preserve binary input` (`.agent/tmp/m2-corrections/preservation-red.log`). Suíte completa posterior: exit 0, 18 testes, 175894 ms (`preservation-green.log`). Campos: `./scripts/launch contracts` falhou com `explicit numeric field must ignore a String local` (`fields-red.log`); após separar campos e escopo lexical, 15 grupos passaram (`fields-green.log`), e `kof test .../Run.kf --tag fields` passou com dois mutantes, Killed/Survived e complete/1 (`fields-cli.log`).

Contadores: falha inicial em `counters-red.log`, antes de adicionar o novo array ao decoder dos testes. A suíte posterior (`counters-green.log`) retornou 0, 20 casos, 240148 ms. Rejeição coerente do check: `discard-check-red.log` falhou especificamente porque o status anterior era incomplete; `discard-check-green.log` passou com no_mutants/3 e ARITH001. Comentários: `discard-parse-red.log` e reprodução CLI `comment-repro.json` observaram error/2 após baseline aprovada, com PARSE025; `discard-parse-green.log` passou tanto na rejeição do parser quanto na divergência de tokens com parser válido, sem check para o descarte e com próximo candidato Killed/complete/0.

Revisão final: o caso de projeto `/` com configuração inválida falhou antes da correção com `filesystem root project must classify every absolute destination as internal` (`root-preservation-red.log`). A regra de prefixo agora reconhece todos os caminhos absolutos sob `/`; `kof test .../Run.kf --tag preservation` passou, exit 0, 15931 ms (`root-preservation-green.log`). A prova não inicia comandos nem percorre inputs de `/`: usa apenas configuração inválida e destino binário sintéticos. Provas finais adicionais: campos String com parâmetro/local numérico (`fields-cli-final.log`); lexer LEX002, parser e divergência de tokens (`discard-parse-final.log`, exit 0, 20323 ms); timeout após descarte com candidatos restantes Pending (`budget-focused.log`, exit 0, 28297 ms); proteção canônica de todos os inputs (`report-final.log`, exit 0). A validação completa `PATH=/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64/bin:$PATH ./scripts/check` retornou **0**: 21 contratos do lançador (259816 ms), 22 testes do ciclo (277920 ms) e 15 grupos do frontend, em `check-final.log`. Após a última correção, `kof test src/test/kof/kofmut/Run.kf` retornou **0**, 22 testes, 273787 ms (`run-consolidated.log`). Os exemplos documentados retornaram detected=0/complete/Killed, survived=1/complete/Survived e invalid=3/no_mutants/um descarte com ARITH001 (`fixtures.tsv`, logs e JSONs em `.agent/tmp/`). `git diff --check`, sintaxe Bash, links locais e coerência dos identificadores EN/PT passaram. O jar Kof mantém o SHA-256 original.

A auditoria final não deixou critérios de correção M2 falhos ou inconclusivos. As fontes consultadas permanecem externas e não foram alteradas; o motor segue integralmente em Kof, com frontend oficial e sem nova gramática. Revisão estrutural limitada às correções não justificou outra refatoração. O relatório [M2](.agent/validation/kofmut-m2.md) mapeia cada cenário a comando, resultado e asserções. O [manifesto atual](.agent/validation/kofmut-m2.sha256) cobre a entrega corrigida, e [kofmut-m2-initial.sha256](.agent/validation/kofmut-m2-initial.sha256) preserva o manifesto anterior. A decisão atual de descarte substitui explicitamente CompileError em novas execuções, sem apagar o histórico abaixo. Não houve novo benchmark de inicialização nem repetição da prova histórica de checkout limpo; os 21 contratos do lançador foram preservados. M3, SiFuture dentro de 90 s e documentação ampliada M4 seguem pendentes, sem commits ou publicação nesta entrega.

### Evidência histórica observada do M2

Implementação local na base `b1d8684`, sem commits, worktrees, subagentes ou publicação. A lógica permanece em `src/main/kof/kofmut/`: configuração/escopo em `Inputs.kf`, captura/materialização/limpeza em `Sandbox.kf`, processos e protocolos em `Evidence.kf`, validação de formas JSON da plataforma em `JsonShape.kf`, ciclo/relatório em `Run.kf` e percurso/associação AST/token em `Frontend.kf`. Fixtures `detected`, `survived` e `invalid`, testes Kof e READMEs EN/PT atualizados.

Provas pequenas em 0.6.4 confirmaram ProcessBuilder com String[] (a sobrecarga ArrayList falha nessa versão), cwd, stdin fechado, logs separados, waitFor/TimeUnit, PID e relógio monotônico; JSON aninhado preservou null; captura/reaplicação POSIX funcionou. `7 / 0` recebeu ARITH001 no check. O decoder tipado admite coerções: a validação inspeciona formas originais decodificadas pela plataforma, inclusive impedindo que uma versão inteira muito grande seja convertida para 1. Nenhum parser JSON ou executor de testes alternativo foi criado. O jar instalado permaneceu com SHA-256 `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62`.

`PATH=/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64/bin:$PATH ./scripts/check` retornou **0**, com 21 testes do lançador, 17 do ciclo e 14 grupos de asserções do frontend. Após a revisão estrutural, a suíte do ciclo retornou 0 novamente (17 casos, 144441 ms reportados pelo Kof), e as 14 provas frontend passaram. A prova final de isolamento foi reforçada com `1 - 1` no arquivo importado não selecionado: os comandos receberam seus bytes originais em todas as variantes, e apenas os dois candidatos do arquivo selecionado foram gerados.

Os três comandos documentados `./bin/kof-mut run --project fixtures/<nome> --files fixtures/<nome>/scope.json --report .agent/tmp/<nome>.json` retornaram **detected=0, survived=1, invalid=3**. Os JSONs contêm respectivamente um Killed, um Survived e um CompileError com ARITH001; todos têm baseline aprovada. O sobrevivente está em `src/math/Calc.kf:4:38`. Logs locais: `.agent/tmp/m2-probes/fixtures.tsv` e arquivos `<nome>.log`.

Uma cópia sem `.git`, build ou logs prévios, em `.agent/tmp/m2-clean/checkout with spaces`, repetiu **todo `./scripts/check` com exit 0**. PATH restrito em `.agent/tmp/m2-clean/tools` não encontrou `python` nem `python3`; Kof info confirmou 0.6.4. Resultado: 21 testes CLI (247482 ms reportados), 17 testes de ciclo (137761 ms) e 14 provas frontend. Os 41 arquivos de fontes, fixtures, scripts, VERSION, manifesto e READMEs foram comparados por conteúdo com o checkout. Logs locais em `.agent/tmp/m2-probes/check-clean.log` e `no-python-info.log`.

As asserções foram avaliadas separadamente contra duas implementações erradas em cópias descartáveis. Classificar todo teste concluído como Killed fez a prova de sobrevivente falhar; reusar a variante com mutação/estado acumulados fez a prova de isolamento observar dois Killed e falhar. Ambos os runners de teste retornaram 1. A revisão estrutural classificou como riscos a publicação anterior à limpeza, a cópia materializada parecer fonte de verdade e a duplicação das contagens. Agora a limpeza precede a publicação, análise/variantes partem dos bytes capturados em memória e a mesma regra conta JSON e saída humana. As provas do frontend usam apenas seu contrato de análise e a ordenação da stdlib, sem depender do helper de ordenação do ciclo.

[Relatório por critério](.agent/validation/kofmut-m2.md) e [manifesto da entrega](.agent/validation/kofmut-m2.sha256) registram observações, força das asserções, limites e recuperação. `git diff --check`, sintaxe Bash e links locais dos documentos passaram. Relatórios são publicados por rename atômico; destinos que sobrepõem fontes, testes, configuração, escopo ou inputs explícitos são recusados para preservar o projeto. Formas válidas não percorridas, como `record`, permanecem limitações explícitas e impedem complete. Cancelamento cobre os membros ativos do grupo herdado, com conferência em `/proc`; processos que se desanexem deliberadamente não têm garantia nesta versão.

M3 mantém concorrência/recuperação ampliadas, a fixture equivalente e a medição externa no SiFuture dentro dos mesmos **90 segundos**. M2 sintético não comprova esse custo. M4 mantém os guias completos EN/PT. Nenhum sensor foi integrado.

### Evidência observada do M1P

M1P concluído na base `7604142`, branch `kofmut-frontend`, sem novos commits ou publicações. A ponte captura info fresco, identifica conteúdos e seleciona a imagem; Kof valida instalação, prepara o cache e inicia a aplicação na mesma JVM da entrada compilada. A aplicação e RuntimeEntry compartilham um único runtime JSON gerado. O protocolo de localização é `kofmut-location-v1`, e o namespace é `build/cache/kof-launch-v2/`.

Os testes lideraram as correções de cache quente, descritor retido, imagem danificada, limpeza após validação inválida, entrega NUL truncada e retorno de erro de hash. A revisão estrutural removeu uma conferência redundante de imagem, preservando a validação após preparação. A validação final executou `./scripts/check` em cópia limpa sem `.git`, build ou logs, com espaços no caminho e PATH restrito sem Python: exit 0, **21 testes CLI e nove provas frontend**. Foram preservados os 11 contratos anteriores; novas provas cobrem ausência de compilação em versão/ajuda/argumentos, invalidação de todos os inputs com timestamps preservados, mudança de instalação e jar descartável válido, reparação do cache e mesma JVM com TERM/143. Versão e ajuda no checkout também passaram; Kof 0.6.5 foi rejeitado. O trace confirma duas JVMs de trabalho mais `java -version`, conforme autorização do usuário.

A medição final usou Python de `adec628`, o mesmo Kof e fontes idênticos, com aquecimento e três blocos de 11 pares alternados de `--version`. Medianas: Kof **0.712937439 s**, Python **0.673821451 s**; razão **1.058050969**, dentro de 1,10; limite observado **0.741203596 s**. Zero compilações nas 66 chamadas quentes, todas com exit 0 e saída correta. Caches vazios: 5.053044044 s, 5.152825790 s, 5.165226537 s. A preparação inicial não está coberta pela meta quente.

[Relatório M1P](.agent/validation/kofmut-m1p.md), [manifesto](.agent/validation/kofmut-m1p.sha256), [tempos individuais](.agent/validation/kofmut-m1p-performance.tsv) e [dispersão e resumo](.agent/validation/kofmut-m1p-performance.json) registram a entrega. Os READMEs EN/PT documentam utilitários, migração, sondagem oficial e recuperação removendo somente o novo namespace. Evidências históricas M1/M1R preservadas. Naquele marco, M2 permanecia pendente; sua entrega atual está na seção M2 acima. O orçamento de integração externa de **90 segundos** continua sem comprovação.

### Evidência observada do M1R

`scripts/launch.py` foi removido. `scripts/bootstrap/Launch.kf` prepara os modos `app` e `contracts`, e `scripts/launch` faz a entrega `kofmut-launch-v1` e o `exec` final. As cópias usam bytes pela stdlib Kof: a sobrecarga de `Files.copy` produziu falha de geração de bytecode em 0.6.4. A revisão estrutural identificou o risco de ler fontes em momentos diferentes para chave e cópia; agora `SourceSnapshot` conserva os mesmos bytes para ambas. Uma prova separada confirmou o record com `Int[]`, JSON e cópia idêntica por `cmp` contra 0.6.4.

`PATH=/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64/bin:$PATH ./scripts/check` retornou 0: 11 testes do CLI e nove provas do frontend. Foram comprovados: ausência de Python; argumentos exatos, cwd externo, ambiente e exit 23 da fixture; erro de preparação com exit 2; reutilização e invalidação por VERSION/fonte; rejeição de JSON inválido e versão incompatível antes do cache; executável fixado após troca de link; compilador retornando erro após emitir classes; duas chamadas simultâneas com uma compilação; interrupção após classes emitidas e nova compilação bem-sucedida. Os testes de ausência de Python e erro de preparação registraram falhas antes das respectivas correções.

Uma cópia sem `.git`, `build/` ou logs, num caminho com espaços, repetiu `./scripts/check` com exit 0 e os mesmos 20 comportamentos. Preparação e execução usaram PATH restrito a `bash`, `dirname`, `readlink`, `sed`, `head`, `mktemp`, `rm`, `env` e o Kof fixado; `command -v python` e `command -v python3` não encontraram executáveis. As ferramentas auxiliares dos testes foram chamadas por caminhos absolutos, sem Python.

Após preservar o build validado fora da cópia, uma chamada de `--version` com cache frio levou **4,46 s** e a seguinte com cache quente levou **2,64 s**, ambas exit 0, stdout `KofMut 0.1.0` e stderr vazio. São amostras locais de inicialização, não prova do orçamento da futura integração. O bootstrap continua compilando a cada chamada; o orçamento de 90 segundos permanece inalterado. O PATH padrão com Kof 0.6.5 foi rejeitado com exit 2. Não foi declarado novo suporte.

README.md e README.pt_BR.md documentam os mesmos requisitos, protocolo, namespace de cache e limites. `git diff --check` e `bash -n` dos lançadores e fixtures retornaram 0. O relatório e manifesto históricos do M1 foram preservados. O [relatório M1R](.agent/validation/kofmut-m1r.md) e seu [manifesto](.agent/validation/kofmut-m1r.sha256) identificam a árvore daquele marco, preservada como evidência histórica. Naquele marco, M2 continuava pendente, começando por função aritmética detectada e fixture sobrevivente. A entrega atual está na seção M2 acima. Nenhum sensor foi ativado.

### Evidência observada do M1

Com o `bin/` da instalação 0.6.4 primeiro no PATH, `./bin/kof-mut --version` retornou 0 e `KofMut 0.1.0`. `./scripts/check` retornou 0, com dois testes nomeados do CLI e nove provas do frontend: token exato; campos/construtores/métodos/lambdas; arquivo real; operadores repetidos/aninhados; comentários/strings/genéricos; Unicode/CRLF/UTF-16; diagnósticos lexicais e sintáticos; AST não suportada; arquivo ausente.

Uma cópia sem `.git`, `build/` ou logs pessoais, num caminho com espaços, executou `./scripts/check` com exit 0. O lançador funcionou com cwd externo ao checkout. Mudanças em VERSION e depois no fonte, somente na cópia descartável e depois de builds já existentes, apareceram corretamente em novos lançamentos. O PATH padrão com 0.6.5 foi rejeitado com exit 2. Não foi declarado suporte a 0.6.5.

O ciclo de TDD registrou ausência do lançador, ausência da API de análise, análise sem candidatos e ausência da API de arquivo como falhas anteriores às implementações correspondentes. Os casos adicionais de erro e associação verificaram guardas já presentes. As expectativas de offsets foram conferidas de forma independente, incluindo offset UTF-16 44 contra byte UTF-8 46 no exemplo com emoji.

O relatório histórico de validação registra os limites: seleção inicial somente de `<` para `<=`, outros operadores e formas de AST ainda pendentes; `run` indisponível; nenhum baseline, mutante executado, JSON, orçamento global ou cancelamento implementado. Não avançar ao plano dos sensores a partir deste marco. A continuação atual está registrada no M1R acima; M2 permanece como próximo marco.

| Critério | Contexto, ação e resultado esperado | Evidência futura |
| --- | --- | --- |
| Testes lideram a implementação | Novo comportamento começa com teste Kof vermelho, passa e é refatorado com suíte verde | Registro conciso por marco; `./scripts/check` |
| Baseline é pré-condição | Baseline com teste falhando interrompe antes de executar mutantes | CLI exit 2, `baseline_failed`, zero mutantes executados |
| Mutação detectada | Troca `+`/`-` altera resultado observado pelo teste | Exit 0, `Killed`, check válido e falha comprovada da suíte |
| Sobrevivente | Teste insuficiente continua verde com alteração | Exit 1, `Survived` e localização correta |
| Sem falsas mortes | Variante inválida, runner quebrado, zero testes ou timeout | Estados próprios; jamais contabilizados como `Killed` |
| Cópias independentes | Duas mutações no mesmo arquivo | Cada variante contém somente sua alteração; original preservado |
| Escopo fiel | Um arquivo escolhido e outro não escolhido, incluindo arquivo novo | Só o escolhido é alterado; o outro pode ser importado e testado |
| Sintaxe respeitada | Símbolos em comentários/strings/genéricos e Unicode antes de operador | Candidatos somente em expressões suportadas; localização e bytes corretos |
| Limites honestos | Tempo ou forma não suportada interrompe avaliação | Exit 3, `incomplete`, estados pendentes e limitações reconciliados |
| Sem arquivo antigo | Relatório anterior existe e a nova execução falha ou concorre | `runId` correto ou erro explícito; nunca reutilização silenciosa |
| Processo encerrado | Teste bloqueado com descendente | Prazo limitado, descendente encerrado e relatório parcial válido |
| Portabilidade do fonte | Checkout limpo com Kof 0.6.4 suportado | Comandos documentados funcionam sem fontes do SiFuture/Codex |
| Documentação coerente | Leituras EN/PT do CLI/JSON e exemplos | Mesmos contratos, links válidos e limitações explícitas |

Antes de cada entrega, conferir separadamente se a expectativa de cada teste corresponde ao contrato e se sua execução distingue o comportamento de uma implementação plausivelmente errada. Registrar comando, resultado e lacuna. Uma suíte verde não substitui essa auditoria. Não marcar o produto como pronto se houver critérios de aceitação inconclusivos.

Atualizar este plano na criação, nos limites de marco, em mudança material de direção e antes do handoff. Manter decisões, progresso e evidência reconciliados, sem transcrição integral da conversa.
