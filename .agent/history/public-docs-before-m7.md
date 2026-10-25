# Public documentation history before M7

Historical record copied from base `3b959ae` on 2026-10-25. These observations do not define current usage. Existing validation files are preserved. Links below resolve from this archive.

## README.md

### Validation and next milestones

[M6 acceptance evidence](../validation/kofmut-m6.md) records the real installation matrix, migration, compatibility, preservation and performance measurements. Automatic approval is specific to verified contents; it does not declare unrestricted support for future versions.

`./scripts/check` runs the launcher contracts, Kof mutation cycle tests, installation journeys and frontend assertions against the installed jar. See [M5 corrections evidence](../validation/kofmut-m5-corrections.md) for current installer acceptance and [historical M5 installation evidence](../validation/kofmut-m5.md) for the original installation, update, recovery and uninstall validation. See [M4 acceptance evidence](../validation/kofmut-m4.md) and the [execution plan](../../EXECPLAN.md) for the reviewed source delivery and remaining work.

Historical M3F evaluated `Background.kf` + `Meteor.kf` on SiFuture revision `82111142c85f98b970ccd65fbf044e492d017729` with `commandTimeoutMs: 10000`, `budgetMs: 0` and `maxParallelMutants: 4`, without an external deadline. The full invocation took **96.456 seconds**: `complete/1`, 42 evaluated candidates, 29 `Killed`, 13 `Survived`, no discards or inconclusive results, and 114 baseline cases. This is a historical observation of complete execution; quality failed because survivors remained. It does not diagnose equivalence or coverage or promise latency. The historical 90 second performance target remains **deferred and unmet**; sensors and their S1–S3 acceptance remain pending.

The [M3P/M3F historical report](../validation/kofmut-m3p.md#preservation-incident-during-the-first-focused-run) also records lost historical standalone JSON/stdout copies and reused observation files whose original bytes were not recovered. Surviving independent evidence and performance records are distinguished there. See [per candidate observations](../validation/kofmut-m3f-candidates.tsv), [M3](../validation/kofmut-m3.md), [M2](../validation/kofmut-m2.md), [M1R](../validation/kofmut-m1r.md) and [M1P](../validation/kofmut-m1p.md) for dated results and their limits.


### docs/cli.md

The [M6O validation](../validation/kofmut-m6o.md) records paired empty-scope and complete-round measurements, process counts, actual versions and limitations. Fewer internal JVMs do not promise the same reduction in total test time.

The [M6R validation](../validation/kofmut-m6r.md) records the symbolic link regression, recovery checks and startup cost diagnosis. The repair adds preservation checks; it makes no speedup promise.

[M6 evidence](../validation/kofmut-m6.md) records actually verified versions and initial/warm costs. This milestone sets no numeric performance regression threshold. [M1P measurements](../validation/kofmut-m1p.md) are historical; the [earlier 90 second target](#validation-and-next-milestones) remains deferred and unmet. Sensors remain future work.

## README.pt_BR.md

### Validação e próximos marcos

A [validação M6](../validation/kofmut-m6.md) registra a matriz de instalações reais, migração, compatibilidade, preservação e medições de desempenho. A aprovação automática é específica dos conteúdos verificados; não declara suporte irrestrito a versões futuras.

`./scripts/check` executa contratos do lançador, testes Kof do ciclo de mutação, jornadas de instalação e asserções do frontend contra o jar instalado. Veja [evidência das correções M5](../validation/kofmut-m5-corrections.md) para a aceitação atual do instalador e [evidência histórica de instalação M5](../validation/kofmut-m5.md) para a validação original de instalação, atualização, recuperação e desinstalação. Veja [evidência de aceitação M4](../validation/kofmut-m4.md) e [plano de execução](../../EXECPLAN.md) para a entrega revisada do fonte e as pendências.

O M3F histórico avaliou `Background.kf` + `Meteor.kf` no SiFuture revisão `82111142c85f98b970ccd65fbf044e492d017729` com `commandTimeoutMs: 10000`, `budgetMs: 0` e `maxParallelMutants: 4`, sem prazo externo. A chamada completa levou **96.456 segundos**: `complete/1`, 42 candidatos avaliados, 29 `Killed`, 13 `Survived`, nenhum descarte ou resultado inconclusivo e 114 casos na baseline. É uma observação histórica de execução completa; a qualidade foi reprovada pelos sobreviventes. Não diagnostica equivalência ou cobertura nem promete latência. A meta histórica de desempenho de 90 segundos permanece **adiada e não atingida**; sensores e sua aceitação S1–S3 continuam pendentes.

O [relatório histórico M3P/M3F](../validation/kofmut-m3p.md#preservation-incident-during-the-first-focused-run) também registra a perda de cópias históricas avulsas JSON/stdout e a reutilização de arquivos de observação cujos bytes originais não foram recuperados. O relatório distingue as evidências independentes remanescentes e os registros de desempenho. Veja [observações por candidato](../validation/kofmut-m3f-candidates.tsv), [M3](../validation/kofmut-m3.md), [M2](../validation/kofmut-m2.md), [M1R](../validation/kofmut-m1r.md) e [M1P](../validation/kofmut-m1p.md) para resultados datados e seus limites.


### docs/cli.pt_BR.md

A [validação M6O](../validation/kofmut-m6o.md) registra medições pareadas com escopo vazio e rodadas completas, contagens de processos, versões reais e limitações. Menos JVMs internas não garantem a mesma redução no tempo total dos testes.

A [validação M6R](../validation/kofmut-m6r.md) registra a regressão com links simbólicos, as provas de recuperação e o diagnóstico do custo de inicialização. A correção acrescenta verificações de preservação; não promete aceleração.

A [validação M6](../validation/kofmut-m6.md) registra versões efetivamente verificadas e custos iniciais e com cache. Não há limite numérico de regressão de desempenho nesta etapa. As [medições M1P](../validation/kofmut-m1p.md) são históricas; a [meta anterior de 90 segundos](#validação-e-próximos-marcos) continua adiada e não atingida. Sensores permanecem futuros.
