[English](README.md) | [Português](README.pt_BR.md)

# KofMut

KofMut é uma ferramenta de teste de mutação em desenvolvimento para Kof. A lógica de seleção, transformação, execução de processos e relatório pertence ao código Kof, com execução inicial na JVM em Linux.

**Estado de desenvolvimento: M1, M1R, M1P e o ciclo local do M2 implementados.** `run` executa baseline, mutações isoladas e relatório JSON v1 em projetos sintéticos. Robustez ampliada, concorrência entre execuções e aceitação externa no SiFuture pertencem ao M3. O valor `0.1.0` identifica este fonte em desenvolvimento.

## Requisitos

- Linux com Bash 4.4 ou posterior e GNU coreutils (`dirname`, `readlink`, `mktemp`, `rm`, `cat`, `sort`, `sha256sum` e `b2sum`), GNU findutils (`find`) e `cmp` do GNU diffutils.
- Distribuição Linux oficial do **Kof 0.6.4** no `PATH`, incluindo `lib/kof.jar` e seu JDK embutido.
- Permissão de escrita no checkout para `build/cache/` e `.agent/tmp/`, e espaço para cópias descartáveis no diretório temporário do sistema.
- `setsid` do util-linux, o comando externo `kill` e procfs montado em `/proc`. A validação também usa `ps`, `cp`, `ln`, `env` e `which`.

Kof 0.6.5 e outras versões são rejeitados até que seus contratos de frontend sejam verificados. O lançador oficial do Kof também exige `sed` e `head`. O lançador descobre a instalação por `kof info --json`; ele não baixa nem atualiza Kof.

Se outra versão estiver selecionada na máquina, coloque a instalação suportada primeiro no `PATH`:

```bash
export PATH="/path/to/kof-0.6.4-linux-x86_64/bin:$PATH"
kof info --json
```

## Executar a partir do fonte

Na raiz do checkout:

```bash
./bin/kof-mut --version
./bin/kof-mut --help
./scripts/check
```

O comando de versão imprime `KofMut 0.1.0`, lendo `VERSION`. Versão e ajuda retornam código 0. Comandos ou argumentos não suportados retornam 2. Um comando de versão ou ajuda não representa avaliação de qualidade.

A ponte Bash fixa o executável Kof por caminho real e obtém `info --json` fresco em cada chamada. Com cache quente, calcula os hashes dos inputs do lançador e do jar instalado inteiro, depois usa `exec` para iniciar `kofmut.launch.RuntimeEntry` compilado. Essa entrada Kof valida a evidência fresca da instalação, os caminhos e a identidade da imagem, remove seu contexto temporário, configura as propriedades da aplicação e chama `Default.Main.main` na mesma JVM. Versão, ajuda e demais comandos usam esse caminho. Argumentos, diretório de trabalho, ambiente, códigos de saída e sinais chegam diretamente à aplicação. Python não é necessário. O script oficial Kof 0.6.4 inicia também uma sondagem curta `java -version` antes da consulta da instalação: são duas JVMs de trabalho mais essa sondagem, e as medições de inicialização incluem as três execuções Java.

`scripts/bootstrap/Launch.kf` executa por `kof run` somente quando é necessário preparar o cache. Ele valida a instalação, confere os hashes dos inputs capturados, compila os bytes capturados dos fontes com `kof build --target jvm --classpath` e publica a imagem completa atomicamente sob bloqueio de arquivo. As duas entradas JVM e o runtime JSON gerado especificamente para a aplicação são compilados juntos. A imagem publicada inclui hashes SHA-256 das classes geradas; o lançador confere esses hashes antes da execução. Uma nova consulta ao cache sob bloqueio impede compilação duplicada. Falhas de validação e compilação retornam 2 sem executar uma imagem antiga como alternativa.

O cache usa `build/cache/kof-launch-v2/locations/` para descritores da instalação e `build/cache/kof-launch-v2/images/` para programas compilados. A identidade preliminar SHA-256 inclui modo, raiz do checkout, caminho e conteúdo do Kof fixado, JSON bruto fresco, lançadores, VERSION, manifesto e conteúdos dos fontes pertinentes, em ordem determinística com campos terminados por NUL. A identidade final SHA-256 inclui também o hash BLAKE2b de 512 bits do jar instalado inteiro, calculado pelo GNU `b2sum`. Os timestamps não determinam a validade. Alterações em um futuro projeto avaliado não recompilam o KofMut.

A entrega anterior `kofmut-launch-v1` foi substituída por `kofmut-location-v1`, cujos campos terminados por NUL carregam os caminhos validados de Java e jar. Bash lê esses campos sem interpretar JSON nem avaliar texto de comandos. Cada chamada passa cinco argumentos internos (raiz, Kof fixado, modo, diretório do contexto e diretório da imagem), seguidos dos argumentos originais da aplicação. Nenhum argumento da aplicação passa pelo parser de opções de `kof run`. Entradas dos caches Python e `kof-bootstrap-v1` são ignoradas.

Descritores ausentes ou inconsistentes e imagens incompletas acionam preparação automática. Para descartar o novo cache e recuperar após uma interrupção abrupta, execute `rm -rf -- build/cache/kof-launch-v2` na raiz do checkout. Isso também remove diretórios temporários sem uso e força preparação na próxima chamada. O filesystem do cache precisa oferecer bloqueios de arquivo e movimentos atômicos de diretórios. O custo de preparação inicial e a comparação de inicialização quente estão no [relatório de validação M1P](.agent/validation/kofmut-m1p.md); a meta de cache quente não se aplica ao primeiro build.

A inicialização quente cumpriu a meta M1P: mediana Kof **0.7129 s**, mediana Python **0.6738 s** (5.81% acima do Python, dentro de 10%), em 33 pares alternados sem compilação. Três chamadas com cache vazio levaram 5.05 s, 5.15 s, 5.17 s. Veja dispersão, resultados brutos e condições no [relatório M1P](.agent/validation/kofmut-m1p.md). O orçamento de integração de 90 segundos continua sem comprovação.

## Executar uma avaliação

Na raiz do checkout, com Kof 0.6.4 no PATH:

```bash
./bin/kof-mut run --project fixtures/detected \
  --files fixtures/detected/scope.json --report .agent/tmp/detected.json
# exit 0: uma mutação Killed

./bin/kof-mut run --project fixtures/survived \
  --files fixtures/survived/scope.json --report .agent/tmp/survived.json
# exit 1: uma mutação Survived

./bin/kof-mut run --project fixtures/invalid \
  --files fixtures/invalid/scope.json --report .agent/tmp/invalid.json
# exit 3: no_mutants, um candidato descartado com ARITH001
```

`--project`, `--files` e `--report` são obrigatórios e relativos ao cwd do chamador. `--config` é relativo ao projeto, com padrão `kof-mut.json`. `--run-id UUID` é opcional; sem ele, a ferramenta gera um UUID. Flags desconhecidas, argumentos incompletos e entradas inválidas retornam 2.

Cada fixture contém este formato de configuração:

```json
{
  "schemaVersion": 1,
  "sourceRoots": ["src"],
  "testRoots": ["tests"],
  "inputs": ["kof.toml", "src", "tests"],
  "checkCommand": ["kof", "check", "src/math/Calc.kf", "--json"],
  "testCommand": ["kof", "test", "tests"],
  "commandTimeoutMs": 10000,
  "budgetMs": 90000
}
```

Escolha um destino de relatório fora das raízes de fonte/teste e dos caminhos de inputs copiados explicitamente. Inputs, configuração, arquivos de escopo, manifesto e fontes Kof são protegidos contra sobrescrita pelo relatório, incluindo aliases canônicos por links simbólicos. Se a configuração não puder ser validada, o relatório de erro só será publicado fora do projeto avaliado. Um destino interno será recusado com exit 2 e explicação no terminal, sem criar diretórios de saída nem iniciar comandos do projeto.

O escopo é um array JSON explícito, como `["src/math/Calc.kf"]`, sem globs. Os caminhos são normalizados, deduplicados e ordenados. Arquivo ausente, teste, extensão diferente de `.kf`, caminho fora de `sourceRoots`, escape do projeto e link simbólico no caminho selecionado são recusados antes de comandos do projeto.

Declare em `inputs` fontes, imports, testes, manifesto e scripts necessários, incluindo arquivos novos não rastreados. Os comandos precisam verificar e testar o escopo escolhido. `.git`, relatórios e evidências do mutador são excluídos. Links internos de inputs são materializados somente quando o destino também pertence aos inputs; destinos externos e ciclos são recusados. A ferramenta captura os inputs antes da baseline e preserva bytes e permissões dos scripts. Cada variante recebe uma cópia independente desse snapshot. Alterações produzidas pelos comandos não passam para a próxima variante. Os originais e os testes são preservados.

Os comandos usam argv separado, cwd da sandbox, ambiente herdado e stdin fechado. Cada processo começa em um grupo próprio. O prazo é o menor entre `commandTimeoutMs` e o orçamento global restante, medido por relógio monotônico desde a entrada de `run`, incluindo preparação e baseline. Ao vencer, o grupo é encerrado e a ausência de membros ativos é conferida em `/proc`; zombies não são processos ativos. Nenhum comando seguinte começa depois do orçamento. Sandboxes são removidas; stdout e stderr separados ficam por execução em `.agent/tmp/` do checkout da ferramenta. Comandos que abandonem deliberadamente seu grupo de processos não têm garantia de cancelamento nesta versão.

## Operadores e evidência

O lexer e o parser oficiais do Kof 0.6.4 selecionam e reanalisam uma troca por token. Famílias: `boundary` (`< ↔ <=`, `> ↔ >=`), `equality` (`== ↔ !=`), `logical` (`&& ↔ ||`), `boolean` (`true ↔ false`) e `arithmetic` (`+ ↔ -`, `* ↔ /`). Símbolos em comentários, strings, caracteres e delimitadores de genéricos são excluídos. Concatenações reconhecidas por literais, declarações e propagação local inequívoca também são excluídas. Aritmética de tipo incerto é validada pelo compilador. `this.campo` resolve o campo da classe independentemente de parâmetros e variáveis locais com o mesmo nome; identificadores sem `this` respeitam o escopo lexical.

O percurso cobre funções, métodos, construtores, campos, lambdas, condicionais, laços, switch, try/catch/finally, declarações, chamadas, atribuições, acessos a arrays e retornos. Formas ainda não percorridas, como declarações de `record`, produzem limitações explícitas que impedem `complete`. Linha e coluna começam em 1; offset e comprimento usam índices UTF-16 de String da JVM, não bytes UTF-8. Compilação rejeitada e falta de evidência nunca contam como mutação detectada.

Os contadores do check devem ser inteiros JSON originais antes da conversão tipada: `filesChecked` entre 1 e 2147483647 e `errorCount` entre 0 e 2147483647. Valores fracionários, negativos, fora da faixa ou de tipo incompatível invalidam a evidência. A baseline exige check JSON válido, exit coerente, `success: true` e zero erros, além de suítes Kof concluídas com casos executados e zero falhas. `filesChecked` não conta imports. O protocolo de `kof test` é interpretado por suíte e caso, separando filtros e SKIP de casos executados. Zero casos, resumo ausente, saída truncada ou contraditória são inconclusivos. Wrappers precisam preservar esses protocolos de 0.6.4.

| Estado de mutante | Significado |
| --- | --- |
| `Killed` | Check válido e testes concluídos com falha reconhecida |
| `Survived` | Check válido e testes concluídos sem falhas |
| `CompileError` | Estado legado; novas execuções registram rejeições coerentes do compilador em `discardedCandidates` |
| `Timeout` | Prazo encerrou check ou teste, com fase e limpeza registradas |
| `TestError` | Evidência insuficiente, inválida ou falha do runner |
| `Pending` | Avaliação não iniciada ou fase não iniciada por fim do orçamento |

Para cada candidato independente, a ferramenta confere o token original, aplica uma substituição, compara os tokens originais e modificados com o lexer oficial (considerando diferenças de comprimento UTF-16) e reanalisa com o parser oficial. Somente um candidato que preserve os demais tokens e passe pela reanálise chega ao check; somente um check aprovado chega aos testes. Rejeição do lexer/parser, alteração indevida de tokens e rejeição coerente do check são registradas como candidatos descartados, com diagnósticos do Kof e referências aos logs. Quando só a comparação de tokens falha, a mensagem fixa é `Variant changes tokens other than the selected token`. Divergência do snapshot, exceções inesperadas e falhas de infraestrutura continuam sendo erros da ferramenta. Evidência de check inválida ou contraditória continua como `TestError` e nunca autoriza descarte.

Não há instrumentação de cobertura ou estado `NoCoverage`. Sobreviventes e possíveis equivalentes exigem análise humana; não há exclusão automática nem percentual de aprovação.

## Relatório JSON v1 e saídas

O JSON UTF-8 é publicado por rename atômico e contém `schemaVersion`, `toolVersion`, `kofVersion`, `runId`, `status`, `scope`, `baseline`, `counts`, `mutants`, `discardedCandidates`, `limitations`, `startedAt` em UTC e `durationMs`. `baseline` contém `status` (`passed`, `failed`, `error`), `check` e `test`, com `exitCode`, `durationMs`, `summary`, `filesChecked`, `executedTests` e `failedTests`; valores não aplicáveis ou fases não iniciadas usam JSON null.

`counts` contém inteiros não negativos: `candidates`, `executed`, `killed`, `survived`, `compileError`, `timeout`, `testError` e `pending`. Cada mutante contém `id`, `file`, `operator`, `original`, `replacement`, `location` (`line`, `column`, `offset`, `length`), `status`, `phase` (`parse`, `check`, `test`), `durationMs` e `evidence`, incluindo referências aos logs. `counts.candidates` equivale a `mutants.length`; `executed` soma todos os estados dos mutantes exceto `Pending`. `counts.compileError` permanece por compatibilidade e vale zero em novas execuções. O relatório humano imprime o UUID, totais por arquivo, localizações dos sobreviventes e candidatos descartados.

`discardedCandidates` é um array separado (vazio quando não há descartes) com `id`, `file`, `operator`, `original`, `replacement`, `location`, `phase` (`parse` ou `check`), `durationMs` e `evidence`, nos mesmos formatos dos mutantes. Os descartes preservam os IDs originais dos candidatos e logs distintos e não entram nas contagens dos mutantes. O contrato anterior do M2 emitia `CompileError` e impedia `complete`; a correção aprovada substitui esse comportamento mantendo o schema JSON na versão 1.

| Exit | Status e interpretação |
| --- | --- |
| `0` | `complete`, pelo menos um mutante aplicável, todos `Killed`, sem limitações |
| `1` | `complete` com sobreviventes |
| `2` | `error` ou `baseline_failed` |
| `3` | `incomplete`, `no_scope` ou `no_mutants` |

Descartes esperados permitem `complete/0` com pelo menos um mutante aplicável e todos `Killed`, ou `complete/1` com sobreviventes. Se todos os candidatos forem descartados, o resultado será `no_mutants/3`; descartes não são evidência de qualidade dos testes. `Timeout`, `TestError`, `Pending`, orçamento esgotado ou limitação impedem `complete`. Um relatório anterior nunca é lido como resultado atual; use `--run-id` para conferir a identidade de uma avaliação automatizada. Falha de publicação retorna 2 e deve ser tratada como erro, mesmo se um relatório antigo continuar no destino.

## Validação e próximos marcos

`./scripts/check` preserva os 21 contratos do lançador, executa testes Kof pelo CLI real e compila o programa de asserções do frontend com o jar instalado no classpath. O `kof test` de 0.6.4 não aceita `--classpath`; as provas de frontend usam o estilo oficial de programa completo com `assert`, sem um novo harness de testes.

M3 amplia concorrência e recuperação e mede a aceitação externa no SiFuture dentro dos mesmos 90 segundos. Os resultados sintéticos do M2 não comprovam esse custo. M4 conclui os guias públicos detalhados. Veja [o plano](EXECPLAN.md), [a validação M2](.agent/validation/kofmut-m2.md) e os relatórios históricos [M1R](.agent/validation/kofmut-m1r.md) e [M1P](.agent/validation/kofmut-m1p.md).

## Licença

KofMut usa **GPL-3.0-only**. Veja [LICENSE](LICENSE) e [NOTICE](NOTICE). O jar do Kof e seu JDK embutido permanecem na instalação do usuário e não são incluídos neste checkout de fonte.
