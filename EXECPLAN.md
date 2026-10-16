# Implementar o KofMut: mutação de código Kof com testes do próprio projeto

## Purpose and success

Construir o **KofMut**, ferramenta de teste de mutação específica para Kof, com lógica escrita em Kof e execução inicial na JVM em Linux. O repositório é `renanfranca/kof-mut`, e o checkout local é `/home/renanfranca/projects/kof-mut`.

O usuário executará a ferramenta sobre arquivos de produção escolhidos. Ela confirmará a situação original dos testes, criará alterações individuais em cópias temporárias dos arquivos `.kf`, executará o comando de testes do projeto e apresentará quais alterações foram detectadas e quais sobreviveram. O código original e os testes originais permanecerão preservados.

O produto precisa funcionar sem Codex, Katacombs ou SiFuture. Um relatório JSON versionado permitirá integrar os sensores depois. A primeira entrega pública será **fonte utilizável com instruções**, licença GPLv3 e documentação em inglês e português. Não inclui instalador nem publicação de pacote binário.

**Estado deste documento:** plano elaborado em 2026-10-15; M1 e M1R implementados e validados em 2026-10-16. M1P implementado e validado em 2026-10-16, antes de M2, com a inicialização dentro de 10% da referência Python medida nas mesmas condições. M2 implementado e validado em 2026-10-16 conforme a autorização abaixo, incluindo JSON v1, orçamento global e encerramento de processos. M3 e M4 continuam pendentes. O usuário confirmou GPT 6.1 Sol, esforço xhigh. Novos commits e publicações exigem instrução explícita. Nunca apresentar pendências como validadas.

## Context and limits

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

Antecipar JSON v1, orçamento global monotônico e encerramento de grupos de processos para M2. M3 amplia concorrência, recuperação e aceitação no SiFuture dentro dos mesmos 90 segundos. Excluir concatenação reconhecida por literais, declarações e propagação local inequívoca na AST; aritmética de tipo incerto gera candidato validado pelo compilador. Rejeição é `CompileError`, nunca `Killed`. Usar ProcessBuilder com argv String[], logs separados e setsid na fronteira JVM. Capturar inputs uma vez, antes da baseline, preservando bytes e permissões; cada comando observa uma cópia independente desse snapshot.

### Contrato público mínimo, versão 1

Executável de fonte: `./bin/kof-mut`. Comandos:

```bash
./bin/kof-mut --version
./bin/kof-mut run --project /caminho/projeto --config kof-mut.json --files scope.json --report /caminho/resultado.json
```

`--project`, `--files` e `--report` são obrigatórios em `run`. Resolver esses três argumentos em relação ao cwd do chamador antes de iniciar subprocessos; `--config` é relativo ao projeto, salvo caminho absoluto explícito. O padrão de `--config` é `kof-mut.json`. `scope.json` contém um array JSON de caminhos relativos de arquivos de produção, sem globs. O chamador determina quais arquivos alterou; o KofMut não depende de Git para escolhê-los. Lista vazia retorna `no_scope`, sem testes nem aprovação. Normalizar, deduplicar e ordenar os caminhos. Arquivo inexistente, fora das raízes, teste, extensão diferente de `.kf`, caminho que escape do projeto ou link simbólico no escopo é erro de entrada, sem descarte silencioso. A seleção cobre arquivos inteiros, não só linhas do diff.

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
  "budgetMs": 90000
}
```

Este JSON estabelece o formato, não uma fixture executável pronta: os caminhos e comandos pertencem ao projeto. `inputs` são arquivos ou diretórios relativos explicitamente copiados para cada sandbox, incluindo fontes, testes e scripts necessários. Nunca copiar `.git`, saídas do mutador ou a própria sandbox. Não seguir links simbólicos para fora dos inputs. Não depender de arquivos ignorados omitidos sem declarar essa dependência. Preservar bytes e caminhos relativos, incluindo arquivos novos ainda não rastreados.

Executar `checkCommand` e `testCommand` como argv, com cwd na cópia temporária e o ambiente herdado, sem concatenar `sh -c`. Não acrescentar `--target` nem duplicar destinos. A versão 1 aceita o protocolo de evidência do `kof check --json` e das suítes nomeadas de `kof test`; wrappers podem preservar esses protocolos. Não anunciar suporte a qualquer runner arbitrário apenas porque retorna um código.

Para o check, exigir JSON válido com `success: true`, `filesChecked > 0` e zero erros, além de exit 0. Essa contagem pode ser apenas a entrada: não equivale ao número de imports verificados. Os testes de integração precisam provar que um erro em fonte importada é detectado. Para os testes, exigir conclusão reconhecida de pelo menos uma suíte Kof com casos executados, além do exit coerente. Reconhecer os resumos por suíte da versão suportada, sem confundir contagem de arquivos com contagem de casos. Saída truncada, zero casos, ausência de resumo ou resultado contraditório é `TestError`, não aprovação nem mutação detectada. Não criar um novo executor de testes Kof.

### Operadores iniciais e seleção

Usar lexer e parser oficiais para reconhecer expressões. Tokens dentro de comentários, strings e caracteres não são operadores de código. Delimitadores de genéricos não são comparações. Considerar métodos, funções, construtores, inicializadores de campos e lambdas; uma forma válida não percorrida deve aparecer como escopo não suportado, sem PASS.

| Família | Substituições exatas da versão 1 |
| --- | --- |
| Limites numéricos | `<` ↔ `<=`; `>` ↔ `>=` em expressões binárias |
| Igualdade | `==` ↔ `!=` em expressões binárias |
| Lógica | `&&` ↔ `||` em expressões binárias |
| Booleanos | literal `true` ↔ `false` |
| Aritmética | `+` ↔ `-`; `*` ↔ `/`, em expressões binárias; não alterar concatenação conhecida |

Cada candidato altera exatamente um token, usando os offsets do lexer da versão suportada. Não confiar que `BinaryExpr.position()` localiza o operador: o parser pode registrar a posição posterior à expressão. Provar a associação AST/token, inclusive com operadores repetidos e aninhados, antes de gerar mutações em arquivos reais. Um token ambíguo ou impossível de associar é uma limitação explícita. Reanalisar o arquivo alterado antes da compilação.

Não incluir remoção de blocos, alteração de assinaturas, números arbitrários, operadores de incremento, código gerado ou mutação dos testes. Não adicionar sistema de plugins na versão 1. Não fazer transformação por regex sobre texto bruto. Uma troca aritmética que o compilador rejeite é `CompileError`, jamais `Killed`.

### Ciclo, isolamento e classificação

Baseline na cópia intacta: executar check e testes; qualquer falha interrompe a geração/execução dos mutantes. Depois executar candidatos em ordem determinística por caminho, offset e operador, um por vez, cada qual a partir de uma cópia limpa da mesma baseline. Não alterar o projeto original, acumular mutações, selecionar testes por cobertura inexistente ou reutilizar resultados de outra execução.

O limite global usa relógio monotônico e inclui baseline, check e testes dos mutantes. Cada comando também tem limite individual, sempre reduzido ao tempo global restante. Parar de iniciar comandos ao acabar o orçamento, encerrar a árvore de processos em execução e finalizar o relatório parcial. Usar mecanismo de processos disponível no Linux/JVM e comprovar a limpeza de descendentes. `process.run` isoladamente não comprova cancelamento da árvore. Não deixar o processo de teste preso por leitura sequencial de stdout/stderr.

| Estado do mutante | Evidência exigida |
| --- | --- |
| `Killed` | Check válido; suíte executada e concluída; evidência reconhecida de falha dos testes |
| `Survived` | Check válido; suítes com casos executados e resultado verde |
| `CompileError` | O compilador rejeitou a variante, com diagnóstico registrado |
| `Timeout` | O limite encerrou check ou teste; registrar a fase e a limpeza |
| `TestError` | Runner não iniciou/concluiu corretamente ou a evidência é insuficiente |
| `Pending` | Candidato não executado por fim do orçamento |

Baseline vermelha é `baseline_failed`; ferramenta indisponível, falha do frontend ou erro de entrada é `error`; orçamento encerrado ou qualquer avaliação inconclusiva é `incomplete`; ausência de candidatos aplicáveis é `no_mutants`. Qualquer `CompileError`, `Timeout`, `TestError` ou `Pending` impede `complete`; esses estados nunca elevam a avaliação. `complete` significa avaliação concluída, não aprovação: pode conter sobreviventes. Escopo com construções não suportadas também é `incomplete`.

Sem instrumentação de cobertura, não emitir `NoCoverage`. Um sobrevivente não prova ausência de cobertura, e uma mutação equivalente não prova teste fraco. Na versão 1, possíveis equivalentes permanecem como sobreviventes para análise humana; não oferecer comentário de supressão, exclusão automática ou classificação inferencial como prova. Não exigir um teste impossível para um comportamento equivalente.

### Relatórios e saída

JSON UTF-8 com `schemaVersion: 1`, `toolVersion`, `kofVersion`, `runId`, `status`, `scope`, evidência da `baseline`, `counts`, `mutants`, `limitations`, `startedAt` e `durationMs`. Cada mutante inclui `id`, `file`, `operator`, `original`, `replacement`, `location` com linha/coluna base 1 e offset/comprimento, `status`, fase, duração e resumo da evidência. Documentar que o offset segue os índices de String da JVM; comprovar Unicode para não confundir índice UTF-16 com byte UTF-8.

Forma normativa dos campos compartilhados com os sensores: `scope` é array de caminhos relativos; `counts` é objeto de inteiros não negativos com `candidates`, `executed`, `killed`, `survived`, `compileError`, `timeout`, `testError`, `pending`; `mutants` é array; `limitations` é array de strings; `startedAt` é ISO 8601 UTC; `durationMs` é inteiro não negativo. `runId` é UUID gerado pelo chamador e passado opcionalmente por `--run-id`; na ausência, o KofMut gera um UUID e o imprime no relatório humano. O adaptador dos sensores sempre fornece `--run-id` e confere igualdade no JSON.

`baseline` contém `status` (`passed`, `failed` ou `error`), `check` e `test`; cada fase contém `exitCode`, `durationMs` e `summary`, podendo ter valores JSON null quando não foi iniciada. O check acrescenta `filesChecked`; o teste acrescenta `executedTests` e `failedTests`. Uma baseline só é `passed` com check válido e pelo menos um caso executado com zero falhas.

Cada mutante usa `location: {line, column, offset, length}`, `phase` em `parse|check|test`, `durationMs` inteiro e `evidence` como resumo textual. `id` é string estável na execução, única por arquivo/offset/substituição. `operator` pertence a `boundary`, `equality`, `logical`, `boolean`, `arithmetic`. `original` e `replacement` são os textos dos tokens. Para um `Pending`, usar a fase que ainda falta iniciar e duração zero. Campos obrigatórios ausentes ou tipos incompatíveis invalidam o relatório. A versão 1 não promete semântica para extensões do schema.

Manter por arquivo a quantidade de candidatos e de mutantes de cada estado no relatório humano; o JSON permite derivá-la agrupando `mutants`. `counts.candidates` é o tamanho de `mutants`; `counts.executed` soma todos os estados exceto `Pending`; `counts.pending` conta `Pending`. As demais contagens correspondem exatamente aos estados homônimos. Cada candidato precisa terminar em um estado; as contagens devem reconciliar. Não fornecer percentual de aprovação na versão 1. O relatório humano mostra totais, limitações e localizações dos sobreviventes. Logs detalhados ficam em área local de evidência e não no repositório público.

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

Implementar `run --project … --config … --files … --report … [--run-id UUID]`, configuração/escopo validados antes de comandos, snapshot único dos inputs, baseline obrigatória e variantes sequenciais independentes. Seleção e transformação usam somente AST/tokens oficiais, copiados antes do parse; substituir as 14 direções das cinco famílias, percorrer os contextos contratados e registrar formas não suportadas.

Provar em 0.6.4 processos com argv separado/cwd/stdin fechado, JSON aninhado com null e metadados de arquivos antes de depender dessas APIs. Cada comando usa setsid, stdout/stderr separados e prazo mínimo entre commandTimeoutMs e orçamento restante. Exigir check JSON válido/coerente e protocolo de teste completo por suíte; resultados inválidos são inconclusivos. Publicar JSON v1 por rename atômico e relatório humano por arquivo, com sobreviventes localizados, sem percentual.

TDD pelo CLI em Kof: detected, survived, invalid, operadores, entradas/isolamento, protocolos, prazos e relatório. Validação: `./scripts/check`; `./bin/kof-mut run --project fixtures/detected --files fixtures/detected/scope.json --report .agent/tmp/detected.json` (exit 0); comandos equivalentes `survived` (1) e `invalid` (3). Configuração padrão dentro de cada projeto. Repetir suíte em cópia limpa com espaços e sem Python no PATH. Atualizar READMEs EN/PT com comandos, requisitos, estados e limites. Registrar evidência por critério, revisar a força das asserções e executar `git diff --check`.

Critérios de aceitação M2: baseline antes de gerar candidatos, dois casos contados separadamente de arquivos, SKIP/filtros/truncamento/contradições sem falsa aprovação, inputs novos/importados preservados, escopo normalizado/deduplicado/ordenado, teste/link/escape recusados sem comandos, cada variante observada pelos comandos com uma troca e sem estado anterior, 14 substituições e contextos obrigatórios, concatenações conhecidas excluídas, Unicode/CRLF/genéricos e operandos de chamada corretos, construção válida não suportada impede complete, timeout individual e global com descendentes comprovados encerrados, restantes Pending e contagens reconciliadas, relatório atual mesmo após baseline falhar.

### M3 — Robustez ampliada e aceitação externa

Ampliar os contratos de saída, orçamento global e cancelamento entregues no M2; testar concorrência entre duas execuções, recuperação e preservação da árvore original. Confirmar que faltas de ferramenta ou de evidência dos testes não se tornam mutações detectadas.

Preservar e ampliar as provas M2 de baseline vermelha, zero testes, runner quebrado, descendentes e timeout, acrescentando concorrência entre execuções e recuperação. Adicionar a fixture equivalente, que deve usar uma transformação como `if (x < 0) { x = 0 }` → `if (x <= 0) { x = 0 }`, sem inventar uma diferença funcional. Seu resultado esperado é sobrevivência e sinalização para análise, sem exclusão automática.

Ensaiar leitura externa do SiFuture com inputs/escopo em cópias temporárias; não adicionar configuração ao SiFuture neste plano. Medir custo num arquivo pequeno e num representativo, registrando tempo, candidatos concluídos/pendentes e versão. O orçamento de referência dos sensores é 90 s; esta medição não autoriza aumentá-lo. Se não houver conclusão dentro dele, registrar a limitação de uso no hook e o gargalo; não prometer adoção diária pronta, filtrar candidatos silenciosamente ou adicionar cobertura/incremental sem novo planejamento.

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
- [ ] M3 — Robustez ampliada, concorrência/recuperação, fixture equivalente e aceitação externa no SiFuture dentro de 90 s.
- [ ] M4 — Documentação e entrega revisável; publicação apenas quando autorizada.

## Validation

M1, M1R, M1P e M2 foram executados em 2026-10-16. A evidência de M2 abaixo e no relatório por critério distingue os contratos já observados das ampliações M3/M4. A tabela histórica ao final preserva os critérios originais; seu estado atual é reconciliado pela evidência M2.

### Evidência observada do M2

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
