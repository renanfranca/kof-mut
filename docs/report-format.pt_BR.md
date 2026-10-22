[English](report-format.md) | [Português](report-format.pt_BR.md) | [KofMut](../README.pt_BR.md)

# Referência do relatório JSON v1

Este é o contrato público de integração do fonte atual. Identificadores de CLI, campos JSON, valores e capitalização são canônicos e não são traduzidos. Para chamadas/configuração, use [CLI](cli.pt_BR.md); para conceitos de mutação, use [operadores](operators.pt_BR.md).

## Descobrir o relatório atual

Por exemplo, chame a [fixture detected](../README.pt_BR.md#executar-uma-avaliação), opcionalmente fornecendo `--run-id UUID` gerado pelo chamador. Após validar a segurança do destino, a ferramenta reserva um diretório exclusivo e imprime exatamente uma linha de descoberta antes do primeiro comando do projeto:

```text
reportPath="/absolute/reports/<project-id>/<run-id>-<unique-suffix>/report.json"
```

Os caracteres após `reportPath=` formam uma string JSON. Decodifique com um parser JSON, incluindo aspas escapadas, Unicode e caracteres de controle; remover aspas é insuficiente. O caminho é absoluto. `project-id` é o SHA-256 hexadecimal completo em minúsculas do caminho absoluto canônico do projeto em UTF-8, sem quebra de linha adicional e independente de Git. Aliases canônicos compartilham ID; locais distintos com o mesmo nome final não. Até chamadas simultâneas com o mesmo UUID reservam diretórios diferentes. Não existe último resultado compartilhado.

O anúncio identifica uma **reserva**, não um arquivo publicado. Aguarde o término do processo e exija o arquivo final naquele caminho exato. A publicação grava JSON UTF-8 num temporário e faz movimento atômico no mesmo filesystem. Falha de publicação no filesystem retorna 2 sem relatório final utilizável. Erros de argumentos, destinos inseguros ou falha do lançador podem retornar 2 sem anúncio nem JSON. Erro após reserva válida do destino pode publicar relatório `error`. Interrupção externa não promete relatório parcial. Nunca procure o arquivo mais recente nem substitua por relatório anterior.

Um consumidor pode implementar este procedimento sem dependência de Python:

```text
Escolha expectedRunId e expectedScope para esta chamada.
Inicie run com --run-id expectedRunId; capture stdout, stderr e seu exit.
Exija exatamente uma linha de stdout começando com reportPath=.
Decodifique o restante como string JSON; exija caminho absoluto.
Aguarde o término e abra o JSON final somente no caminho decodificado.
Valide campos obrigatórios, tipos e schemaVersion == 1.
Compare runId com expectedRunId e scope com o escopo solicitado normalizado.
Reconcilie IDs, arrays, counts, baseline, limitations, status e exit do processo.
Se descoberta/publicação/validação falhar, registre evidência atual indisponível.
```

Numa execução rejeitada durante a validação de inputs, `scope` ainda pode estar vazio; trate como erro e não aceite como evidência do escopo solicitado. Um UUID gerado pela ferramenta aparece na saída humana e no JSON; o integrador deve fornecer seu próprio UUID para conferir a identidade independentemente. Conferir apenas UUID é insuficiente porque o mesmo UUID pode ser reutilizado entre chamadas.

## Exemplo

Este relatório esquemático de `detected` mostra todos os campos. Durações, timestamp e caminhos absolutos de logs são ilustrativos, não tempos esperados ou caminhos portáteis. A localização do fonte corresponde à fixture. Execuções reais têm sua própria identidade e caminhos de evidência.

```json
{
  "schemaVersion": 1,
  "toolVersion": "0.1.0",
  "kofVersion": "0.6.4",
  "runId": "d7df680d-2304-43a3-9741-4b0ebd61686e",
  "status": "complete",
  "scope": ["src/math/Calc.kf"],
  "baseline": {
    "status": "passed",
    "check": {
      "exitCode": 0,
      "durationMs": 1000,
      "summary": "stdout: /example/kof-mut/.agent/tmp/run-example/baseline-check.stdout; stderr: /example/kof-mut/.agent/tmp/run-example/baseline-check.stderr; process group cleanup confirmed",
      "filesChecked": 1,
      "executedTests": null,
      "failedTests": null
    },
    "test": {
      "exitCode": 0,
      "durationMs": 1000,
      "summary": "0 failed of 1 executed tests; stdout: /example/kof-mut/.agent/tmp/run-example/baseline-test.stdout; stderr: /example/kof-mut/.agent/tmp/run-example/baseline-test.stderr; process group cleanup confirmed",
      "filesChecked": null,
      "executedTests": 1,
      "failedTests": 0
    }
  },
  "counts": {
    "candidates": 1,
    "executed": 1,
    "killed": 1,
    "survived": 0,
    "compileError": 0,
    "timeout": 0,
    "testError": 0,
    "pending": 0
  },
  "mutants": [
    {
      "id": "src/math/Calc.kf:68:-",
      "file": "src/math/Calc.kf",
      "operator": "arithmetic",
      "original": "+",
      "replacement": "-",
      "location": {"line": 4, "column": 38, "offset": 68, "length": 1},
      "status": "Killed",
      "phase": "test",
      "durationMs": 2000,
      "evidence": "1 failed of 1 executed tests; stdout: /example/kof-mut/.agent/tmp/run-example/0-test.stdout; stderr: /example/kof-mut/.agent/tmp/run-example/0-test.stderr; process group cleanup confirmed"
    }
  ],
  "discardedCandidates": [],
  "limitations": [],
  "startedAt": "2026-10-22T12:00:00Z",
  "durationMs": 5000
}
```

## Campos superiores

Todos os campos abaixo são obrigatórios e não nulos. Objetos JSON não são ordenados. Arrays conservam os significados descritos abaixo. Campos obrigatórios ausentes ou tipos incompatíveis invalidam o relatório; a versão 1 não promete semântica para extensões do schema.

| Campo | Tipo JSON | Significado |
| --- | --- | --- |
| `schemaVersion` | inteiro | `1` |
| `toolVersion` | string | VERSION do KofMut, atualmente `0.1.0` |
| `kofVersion` | string | Versão do frontend/runtime suportado, `0.6.4` |
| `runId` | string | UUID solicitado ou gerado |
| `status` | string | Estado geral da tabela de estados abaixo |
| `scope` | array de strings | Caminhos de produção normalizados, deduplicados e ordenados, relativos ao projeto; pode estar vazio |
| `baseline` | objeto | Estado da baseline e ambos os objetos de fase |
| `counts` | objeto | Oito contagens inteiras não negativas abaixo |
| `mutants` | array de objetos | Registros de avaliação não descartados; vazio quando não há |
| `discardedCandidates` | array de objetos | Candidatos rejeitados; vazio quando não há |
| `limitations` | array de strings | Formas não suportadas, erros e outros motivos explícitos que impedem conclusão; vazio quando não há |
| `startedAt` | string | Instante ISO 8601 UTC na entrada de `run` da aplicação, com `Z` |
| `durationMs` | inteiro não negativo | Milissegundos monotônicos decorridos da entrada de `run` até a construção do relatório, incluindo avaliação/limpeza |

A duração geral exclui inicialização do lançador e publicação final. Não é uma soma das durações dos candidatos, especialmente com avaliações paralelas. JSON v1 não acrescenta score, percentual de aprovação, ID do projeto, objeto de logs ou campo `maxParallelMutants`.

## Baseline e evidência de fase

`baseline` sempre tem os campos obrigatórios `status` (string), `check` (objeto) e `test` (objeto). Os valores de `status` são `passed`, `failed` ou `error`. `passed` exige aprovação válida do check seguida por testes concluídos com casos executados e zero falhas. `failed` registra check/teste que não estabeleceu esse pré-requisito, incluindo timeout ou evidência inválida; `error` também é o valor inicial quando a baseline não pôde ser avaliada. O `status` geral e a evidência de fase determinam o resultado; o estado da baseline sozinho não é código de saída.

Tanto `check` quanto `test` contêm **todos os seis campos**, incluindo os nulls inaplicáveis:

| Campo | Tipo JSON | Significado e regras de null |
| --- | --- | --- |
| `exitCode` | inteiro ou null | Exit do comando filho, incluindo exit de encerramento; null quando nenhum comando executou |
| `durationMs` | inteiro não negativo ou null | Milissegundos decorridos na fase; null quando não iniciada |
| `summary` | string ou null | Resumo de evidência, diagnósticos e referências a logs locais; null quando não iniciada |
| `filesChecked` | inteiro ou null | Contador de check `1..2147483647` quando JSON de check válido/coerente é decodificado; null para testes, evidência de check inválida, timeout ou fase não iniciada |
| `executedTests` | inteiro não negativo ou null | Casos observados na evidência de teste interpretada; null para check, timeout, fases não iniciadas ou interpretação que não produziu contagens |
| `failedTests` | inteiro não negativo ou null | Casos com falha nessa evidência interpretada; mesmas regras de null de `executedTests` |

Uma fase que nunca começou tem todos os seis valores null. Não interprete null como zero nem aceite contadores de testes não nulos como prova de protocolo válido: saída interpretada inconsistente pode manter contagens observadas e informar evidência inválida. `filesChecked` conta arquivos de entrada, não fontes importadas. Exits de comandos são distintos do exit do processo KofMut. Baseline reprovada/inválida impede avaliação dos mutantes; orçamento esgotado na baseline produz `incomplete` geral.

## Mutantes e candidatos descartados

Cada item de `mutants` tem os campos obrigatórios e não nulos:

| Campo | Tipo JSON | Significado |
| --- | --- | --- |
| `id` | string | Identidade única na execução, estável na agregação dos resultados; forma atual `file:offset:replacement`; trate como opaca |
| `file` | string | Caminho de produção relativo ao projeto |
| `operator` | string | `boundary`, `equality`, `logical`, `boolean` ou `arithmetic` |
| `original` | string | Texto do token original |
| `replacement` | string | Texto do token substituto |
| `location` | objeto | Quatro campos inteiros definidos abaixo, relativos ao fonte original |
| `status` | string | Estado do mutante da próxima tabela |
| `phase` | string | `parse`, `check` ou `test`: contexto registrado da avaliação ou próxima fase não iniciada |
| `durationMs` | inteiro não negativo | Tempo decorrido do candidato até seu resultado registrado, incluindo preparação e fases anteriores; zero para `Pending` |
| `evidence` | string | Resultado/motivo textual, diagnósticos e referências a logs quando disponíveis |

Cada item de `discardedCandidates` tem os mesmos campos e tipos `id`, `file`, `operator`, `original`, `replacement`, `location`, `durationMs` e `evidence`. Seu `phase` obrigatório é apenas `parse` ou `check`, e ele **não tem campo `status`**. Está fora de `mutants` e de suas contagens. Rejeição de token/parse ou check coerente pode descartar candidato; evidência inválida não. O [guia de operadores](operators.pt_BR.md#candidato-descartado) define essas regras.

Dentro de cada array, os resultados seguem a ordem original de seleção mesmo quando os processos terminam fora de ordem. IDs e índices de logs não são renumerados após descartes. Após a seleção dos candidatos, cada avaliação é contabilizada uma vez em um dos arrays, incluindo erros de cancelamento/limpeza. Resultados concluídos permanecem; candidatos não iniciados no erro usam `Pending/parse`, duração zero e motivo da interrupção em `evidence`. O resultado geral permanece `error/2` quando publicável.

## Estados dos mutantes

| `status` | Significado |
| --- | --- |
| `Killed` | Check aprovado e testes concluídos com evidência reconhecida de falha |
| `Survived` | Check aprovado e testes concluídos sem falhas |
| `CompileError` | Valor histórico de compatibilidade; novas rejeições coerentes do compilador vão para `discardedCandidates` |
| `Timeout` | Check ou teste interrompido em seu prazo, com evidência da fase/limpeza |
| `TestError` | Evidência inválida/insuficiente, falha de runner, falha inesperada de tarefa ou erro de limpeza |
| `Pending` | Avaliação ou próxima fase não começou porque o orçamento terminou ou a execução parou por erro; duração zero; `evidence` registra ausência de início ou interrupção |

Um mutante pode ser `Pending/check` ou `Pending/test` após trabalho anterior; duração zero é a representação de pendência, não uma afirmação de ausência de trabalho anterior. `Pending/parse` identifica candidato não iniciado. Não existe estado `NoCoverage`. Um sobrevivente não implica automaticamente equivalência, falta de cobertura ou teste fraco.

## Contagens

Todos os oito campos são inteiros não negativos obrigatórios. `candidates` conta registros de mutantes mantidos, não o total original antes dos descartes. `executed` é contagem de contabilização, não quantidade de comandos de teste concluídos.

| Campo | Regra exata |
| --- | --- |
| `candidates` | `mutants.length` |
| `executed` | `candidates - pending` |
| `killed` | Quantidade de registros `Killed` |
| `survived` | Quantidade de registros `Survived` |
| `compileError` | Quantidade de registros históricos `CompileError`; zero em novas execuções |
| `timeout` | Quantidade de registros `Timeout` |
| `testError` | Quantidade de registros `TestError` |
| `pending` | Quantidade de registros `Pending` |

Reconcilie `executed = killed + survived + compileError + timeout + testError` e `candidates = executed + pending`. Para obter o total selecionado após seleção, some `discardedCandidates.length` a `candidates`. Descartes não são detecções. Descartes esperados permitem `complete` quando restam mutantes aplicáveis; todos descartados, sem outra limitação, resulta em `no_mutants/3`.

## Localizações e evidência

`location` sempre contém inteiros não nulos `line` e `column` começando em 1, `offset` começando em 0 e `length` positivo. `offset` e `length` indexam Strings da JVM em **unidades de código UTF-16**, não bytes UTF-8 nem pontos de código Unicode. Colunas seguem o lexer oficial, também avançando em unidades UTF-16. O token original é o trecho de fonte `[offset, offset + length)` antes da substituição. Não indexe buffers UTF-8 com esses valores.

No fonte CRLF testado `Bool less(Int x) { var text = "😀" return x < 2 }\r\n`, `<` tem `offset: 44`, `line: 1`, `column: 45`, `length: 1`. Seu offset em bytes UTF-8 é 46 porque o emoji ocupa duas unidades UTF-16 e quatro bytes UTF-8. Essas unidades também importam quando o comprimento da substituição muda.

`summary`/`evidence` são strings, não JSON aninhado de comandos nem protocolos de máquina estáveis para extração de logs. Podem incluir códigos/mensagens de diagnóstico Kof, caminhos `stdout:`, `stderr:`, `log:` e confirmação/falha de limpeza. Não traduza nem descarte diagnósticos ao guardar evidência. Leia os [logs locais](cli.pt_BR.md#relatórios-e-logs) para detalhes; consumidores portáteis devem usar estados e campos estruturados em vez de inferir aprovação pelo resumo textual.

## Estado geral e exit do processo

| `status` geral | Exit | Interpretação |
| --- | --- | --- |
| `complete` | `0` | Pelo menos um mutante aplicável, todos `Killed`, nenhuma limitação |
| `complete` | `1` | Avaliação concluída com pelo menos um `Survived`; validação de qualidade reprovada |
| `baseline_failed` | `2` | Check/teste da baseline não forneceu evidência válida de aprovação |
| `error` | `2` | Erro de input, frontend, ferramenta, tarefa ou limpeza, quando a publicação JSON é possível |
| `incomplete` | `3` | Orçamento esgotado, mutante inconclusivo ou escopo não suportado/outra limitação |
| `no_scope` | `3` | Escopo explícito vazio; sem comandos da baseline ou aprovação de qualidade |
| `no_mutants` | `3` | Sem mutantes aplicáveis, incluindo todos os candidatos descartados; sem aprovação de qualidade |

`Timeout`, `TestError`, `Pending` e limitações impedem `complete`. Descartes esperados sozinhos não. Uma baseline pode passar e a execução geral ser inconclusiva ou terminar em erro. Contagens podem ser zero quando a validação da baseline ou dos inputs interrompeu a avaliação.

Fora desse mapeamento JSON, versão/ajuda retornam 0 sem avaliação; erros de entrada/publicação podem retornar 2 sem JSON; SIGINT/SIGTERM durante comando ativo retornam 130/143 sem relatório prometido. Exija concordância entre JSON final atual e exit do processo. `complete` estabelece conclusão da execução; sobreviventes, análise de equivalência e [desempenho histórico](../README.pt_BR.md#validação-e-próximos-marcos) permanecem questões separadas.
