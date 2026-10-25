[English](llm-guide.md) | [Português](llm-guide.pt_BR.md) | [KofMut](../README.pt_BR.md)

# Guia operacional para LLMs

Use este guia ao avaliar os testes de um projeto com o KofMut. É independente de fornecedor, modelo, IDE e framework e acompanha o pacote instalado. Para o primeiro exemplo executável, use o [projeto mínimo completo](usage.pt_BR.md). [Conceitos](operators.pt_BR.md) define o ciclo da avaliação; [CLI](cli.pt_BR.md) e [JSON v1](report-format.pt_BR.md) são as referências canônicas de comandos e evidências.

## 1. Inspecionar antes de configurar

Leia as instruções do projeto, configuração de build, estrutura de produção e testes e scripts existentes. Identifique os comandos reais que verificam e testam o escopo de produção solicitado. Confira se o check produz evidência oficial de `kof check --json` e os testes produzem suítes nomeadas suportadas de `kof test` com casos executados. Não invente comando de teste nem infira sucesso somente pelo exit 0.

Estabeleça explicitamente o escopo solicitado, incluindo arquivos novos/não rastreados relevantes e alterações de trabalhos anteriores quando solicitadas. O KofMut não seleciona pelo Git nem por linhas alteradas. Se uma decisão importante de escopo ou comando não puder ser estabelecida pelo projeto, peça esclarecimento antes de alegar sua avaliação. Registre o Kof escolhido (`kof info --json`) e o KofMut (`kof-mut --version`); chamadas informativas não são avaliações.

## 2. Preparar configuração e inputs

Crie/adapte a [configuração e o array explícito de escopo](cli.pt_BR.md#configurar-um-projeto). Inclua produção, testes, imports, manifestos e scripts necessários em `inputs`; caminhos selecionados devem cumprir as [restrições de escopo](cli.pt_BR.md#selecionar-escopo-e-inputs). Preserve produção e testes. Nunca enfraqueça nem altere testes para obter resultado favorável.

Defina timeout individual positivo e orçamento global explícito. `budgetMs: 0` remove o orçamento global de mutação preservando timeouts individuais. Selecione paralelismo de 1 a 4 conforme recursos e dependências externas. Cópias de arquivos não isolam bancos, portas ou caminhos externos. Escolha raiz para relatórios fora dos inputs protegidos; estado da preparação e logs também não podem sobrepor inputs. Use o [guia de instalação](installation.pt_BR.md) quando preparação ou gerenciamento falhar.

## 3. Executar com identidade independente

Use UUID novo gerado pelo chamador como `--run-id`, embora a ferramenta possa gerar um. Registre argv exato, diretório de trabalho, configuração/escopo e identidade dos inputs relevantes com stdout, stderr e exit do processo. Capture exits diferentes de zero em vez de deixar o tratamento de erros do shell ocultar os resultados. Não mude o projeto durante captura/avaliação nem insinue que os resultados se aplicam a bytes editados depois.

Este é um exemplo completo de chamada após criar os cinco arquivos de [uso](usage.pt_BR.md#criar-todos-os-arquivos-do-projeto), que mantém `demo` definido. Defina `KOFMUT_BIN` como caminho absoluto do comando instalado ou de `bin/kof-mut` do checkout, conforme o tutorial:

```bash
run_id="$(cat /proc/sys/kernel/random/uuid)"
run_dir="$(mktemp -d "$demo/run-$run_id-XXXXXX")"
printf '%q ' "$KOFMUT_BIN" run --project "$demo" --files "$demo/scope.json" \
  --report-dir "$demo/reports" --run-id "$run_id" > "$run_dir/command"
printf '\n' >> "$run_dir/command"
if "$KOFMUT_BIN" run --project "$demo" --files "$demo/scope.json" \
  --report-dir "$demo/reports" --run-id "$run_id" \
  > "$run_dir/stdout" 2> "$run_dir/stderr"; then
  run_exit=0
else
  run_exit=$?
fi
printf '%s\n' "$run_exit" > "$run_dir/exit"
cat "$run_dir/stdout" "$run_dir/stderr" "$run_dir/exit"
(cd "$demo" && sha256sum --check originals.sha256)
```

Esperado para esse projeto sintético intacto: exit 0, baseline aprovada com um caso executado, um `Killed` aritmético, `complete`, nenhum descarte/limitação e originais preservados. O diretório exclusivo `run_dir` preserva comando/stdout/stderr/exit desta chamada sem substituir arquivos anteriores. Mensagens de preparação podem anteceder a avaliação em stderr; não há duração fixa implícita. A execução deve ser consumida pelas próximas etapas, mesmo quando stdout parecer indicar sucesso.

## 4. Descobrir e validar o relatório desta chamada

Após o término do processo, exija exatamente uma linha em stdout iniciada por `reportPath=`. Interprete o restante como string JSON usando parser JSON, incluindo escapes. Exija caminho absoluto e leia o JSON UTF-8 final somente nesse local. Uma reserva não é publicação bem-sucedida. ID da execução sozinho é insuficiente porque até o mesmo UUID pode reservar diretórios diferentes.

Aplique o [contrato JSON v1 completo](report-format.pt_BR.md#descobrir-o-relatório-atual):

1. Valide campos obrigatórios, tipos JSON, regras de null e `schemaVersion == 1`. Preserve `toolVersion`, `kofVersion`, `startedAt` efetivos e caminhos das evidências locais.
2. Compare `runId` com seu UUID e `scope` com os caminhos de produção solicitados normalizados, deduplicados e ordenados. Um relatório de erro com escopo vazio não evidencia avaliação do escopo solicitado. Mantenha o caminho reservado pelo processo como parte da identidade.
3. Confira evidência da baseline e seus casos executados; null significa indisponível, não zero. Falha de input/baseline pode interromper antes da seleção.
4. Valide IDs e localizações, operadores, fases e estados permitidos nos dois arrays. Reconcilie contagens por estado com `mutants`, `candidates == mutants.length`, `executed == candidates - pending` e as [equações completas das contagens](report-format.pt_BR.md#contagens). Descartes ficam fora dessas contagens; adicione o tamanho do array somente para descrever o total selecionado após a seleção.
5. Confira limitações e estado geral contra baseline, estados e exit do processo usando as [regras exatas de resultado](report-format.pt_BR.md#estado-geral-e-exit-do-processo). Relatório `complete` não pode conter estados inconclusivos nem limitações.

Trate `summary` e `evidence` como texto diagnóstico com referências locais de logs, não como protocolo estável de máquina. Leia logs referenciados quando necessário e preserve esses logs junto ao relatório. Localizações usam unidades UTF-16 da JVM em vez de posições de bytes UTF-8.

## 5. Recusar evidência indisponível ou contraditória

Se a descoberta estiver ausente/duplicada/malformada, o arquivo final anunciado estiver ausente, o JSON for inválido, a identidade/escopo estiver errado, as contagens não reconciliarem ou o exit contradisser o relatório, informe **evidência atual indisponível**. Preserve o observado e investigue. Nunca escolha o relatório mais recente, procure sucesso em outro diretório nem substitua por relatório anterior, inclusive com o mesmo UUID.

Erro de lançador/input/publicação pode retornar 2 sem JSON. SIGINT/SIGTERM podem retornar 130/143 sem relatório final garantido. Não transforme nenhum desses casos em aprovação da qualidade dos testes. Após corrigir, faça nova chamada com identidade nova e consuma somente seu relatório.

## 6. Separar conclusão de qualidade

Use esta tabela de decisão após validar estrutura e identidade. As definições exatas permanecem nas [tabelas de estados JSON](report-format.pt_BR.md#estado-geral-e-exit-do-processo).

| Resultado geral observado | Decisão / próxima ação |
| --- | --- |
| `complete`, exit 0 | Avaliação concluída e todos os mutantes aplicáveis foram `Killed`. Descreva somente o escopo avaliado e as alterações suportadas; não alegue correção abrangente. |
| `complete`, exit 1 | Avaliação concluída com sobreviventes; qualidade reprovada. Analise sobreviventes e proponha teste que diferencie comportamentos somente quando houver requisito observável. |
| `baseline_failed`, exit 2 | Não há pré-requisito válido aprovado. Diagnostique evidência do check/teste original; não avalie qualidade por mutação. |
| `error`, exit 2 | Erro de input/frontend/ferramenta/tarefa/limpeza. Preserve diagnósticos e corrija a causa antes de reavaliar. Detecções parciais não aprovam o escopo. |
| `incomplete`, exit 3 | Orçamento, estados inconclusivos, sintaxe não suportada ou outra limitação impede conclusão. Informe escopo/trabalho não concluído e causa; escolha próxima ação justificada. |
| `no_scope`, exit 3 | Nenhum escopo de produção selecionado. Informe a ausência; não aprove testes nem alegue avaliação completa de mutação. |
| `no_mutants`, exit 3 | Nenhum mutante aplicável, inclusive todos descartados. Informe o motivo; não aprove testes. |
| Relatório atual ausente/inválido/contraditório; qualquer exit | Evidência indisponível. Preserve stdout/stderr/exit e investigue; não substitua por outro relatório. |

| Evidência do candidato | Decisão |
| --- | --- |
| `Killed` | Falha reconhecida de teste após check aprovado; conta como detecção. Não pode superar erro/inconclusão geral. |
| `Survived` | Testes passaram com essa alteração. Inspecione comportamento, expressão e testes; sobrevivência sozinha não comprova equivalência nem ausência de cobertura. |
| `Timeout` | Prazo interrompeu check/teste; inconclusivo. Reveja fase, limpeza e limites adequados. |
| `TestError` | Falha de evidência/runner/tarefa/limpeza; inconclusivo ou erro geral. Diagnostique logs. |
| `Pending` | Trabalho/próxima fase não começou. Informe motivo e trabalho restante; não conte como detecção. |
| `CompileError` | Valor histórico de compatibilidade. Não conte como detecção; novas rejeições coerentes são descartes. |
| Entrada de `discardedCandidates` | Rejeitada antes da avaliação por testes, não é detecção nem parte das contagens de mutantes. Explique diagnósticos; todos descartados resulta em `no_mutants/3` somente se não houver outra causa de erro ou inconclusão. Uma limitação de sintaxe não suportada mantém `incomplete/3`. Descartes não aprovam a qualidade dos testes. |

Para sobreviventes, determine se a alteração pode mudar comportamento observável exigido. Distinga uma lacuna plausível nos testes de um possível equivalente e de informação insuficiente. O [exemplo equivalente](operators.pt_BR.md#possíveis-equivalentes) mostra por que um teste que diferencie comportamentos pode ser impossível. Não existe instrumentação de cobertura, classificação automática de equivalência, supressão nem pontuação.

## 7. Apresentar resultado curto e fundamentado

Informe escopo e identidade dos inputs, versões efetivas da ferramenta/Kof, resultado da baseline, estado geral e exit, contagens relevantes (incluindo descartes e trabalho inconclusivo), caminho do relatório atual, limitações e próxima etapa justificada. Informe conclusão e qualidade separadamente. Se não houver relatório utilizável, diga isso e preserve os locais das evidências da chamada que falhou.

Para o exemplo mínimo, um resultado poderia ser: “Avaliei `src/math/Calc.kf` nos hashes registrados com KofMut `<toolVersion>` e Kof `<kofVersion>`. Baseline aprovada (1 caso). `complete/0`: 1 Killed, 0 Survived, 0 descartados e nenhum estado inconclusivo ou limitação. Relatório atual: `<decoded reportPath>`. Originais preservados. Isso estabelece a detecção da alteração aritmética selecionada; a próxima etapa é avaliar o escopo real solicitado.” Substitua os campos pela chamada atual, nunca pelo exemplo nem por execução anterior.
