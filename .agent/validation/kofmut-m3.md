# Validação M3: relatórios por execução, concorrência e aceitação externa

Registro iniciado em 2026-10-17. Base testada: `37b72ca21309f0250497e3b45be77f6d2961c314`, branch `kofmut-frontend`, mais as alterações locais identificadas no manifesto M3. Nenhum commit foi criado. Premissas autorizadas: GPT 6.1 Sol/xhigh, Kof 0.6.4, Linux/JVM. Não houve subagentes, worktrees, remotes, publicações, atualização do Kof ou ativação de sensores.

A instalação usada é `/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64`; seu bin precede o PATH em todas as provas. Jar esperado: SHA-256 `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62`. Fontes locais Kof consultadas na revisão `53efd25fdb8dfec1fbbd989c1f482b2ee38c3ce8`: training README, interop, automation, classes, exceptions, CLI, testes e anti-patterns; implementações `StatementLowererTry`, `CatchTypeCheck`, `CmdCheck` e testes de interoperabilidade/exceções. Nenhuma mudança no Kof. O comportamento foi comprovado na distribuição 0.6.4, sem inferir compatibilidade do checkout de pesquisa.

## Resultado

M3 concluído localmente: sete cenários focados passaram; ./scripts/check retornou 0 no checkout e na cópia limpa com espaços e PATH sem Python, com 21 contratos do lançador, 29 testes do ciclo e 15 grupos frontend. As quatro fixtures retornaram 0/1/3/1. As sete medições externas foram executadas. Background concluiu; Meteor permaneceu incomplete dentro do teto externo. Essa limitação medida impede declarar prontidão geral para os sensores. M4 conserva os guias ampliados e os sensores permanecem sem ativação.

## Contrato entregue

`run --project PATH --files JSON [--config JSON] [--report-dir DIRECTORY] [--run-id UUID]`. `--report` foi removido com exit 2 antes de efeitos. Projeto, escopo e raiz são relativos ao cwd; configuração relativa pertence ao projeto. A raiz padrão é `<project>/.kof-mut/reports`. O destino exclusivo é `<raiz>/<SHA-256 do caminho absoluto canônico>/<UUID>-<sufixo>/report.json`, anunciado uma vez por `reportPath=<string JSON absoluta>` antes dos comandos. O consumidor valida o arquivo anunciado por sua própria invocação, runId, schema, escopo, contagens e exit. Escrita temporária e publicação atômica no mesmo filesystem, sem resultado compartilhado de última execução.

Preservados JSON v1, exits 0/1/2/3 e `discardedCandidates` do M2. `counts.compileError` vale zero nas novas execuções. INT/TERM ativos retornam 130/143 e não exigem relatório parcial. Um lock JVM protege início/registro/cancelamento, preparação de sandboxes e publicação; o hook é removido ao finalizar normalmente. Recursos e limpeza pertencem a uma única execução. Grupos que se desanexam deliberadamente continuam fora da garantia; nenhum container ou cgroup foi exigido.

## Evidência por critério e força das asserções

| Critério e expectativa normativa | Verificação observável | O que a prova distingue |
| --- | --- | --- |
| CLI e descoberta: contrato M3.1, padrão/customizado, JSON absoluto, UUID e aliases canônicos | `each invocation reserves...`: cwd/raiz, hash confrontado com sha256sum, espaços/Unicode/aspas/quebra de linha, três caminhos independentes com mesmo UUID, bytes anteriores preservados; rejeição legada sem saída/efeitos | Detecta arquivo fixo, hash só pelo basename, identidade não canônica, JSON não decodificável e substituição de relatórios anteriores. A raiz não depende de Git. |
| Concorrência: M3.2 e EXECPLAN exigem sobreposição real | `INT and TERM...`: duas barreiras com pais/descendentes ativos, mesmo projeto e UUID, reservas distintas; interrompe uma e libera outra depois; não presume ordem de conclusão | Detecta limpeza global, interferência entre grupos, ausência de hook e reaproveitamento da reserva. A execução seguinte também precisa concluir. |
| Preservação: M2 e M3.1 protegem inputs canônicos | Provas M2 migradas de `report`, `preservation`, `links`, `locations` e `isolation`; novo snapshot com inputs ponto e relatórios antigos nos dois namespaces, runner recusa qualquer relatório na sandbox, inventários de fontes/testes comparados | Detecta exclusão apenas do arquivo atual, recursão de relatórios, perda de bytes/permissões e efeitos antes de validação. Destino interno com configuração inválida não cria diretórios; externo seguro recebe erro atual. |
| Orçamento: monotônico desde run, incluindo preparação/baseline | `the global budget...`: 1500 ms em baseline check/test e variant check/test, PIDs e cwd observados, sequência exata dos comandos; 1 ms consumido em preparação sem iniciar baseline; cenário M2 após descarte com restante Pending | Detecta reinício do relógio por comando, início posterior ao limite, fases erradas, contagem incorreta e Pending com duração não zero. Limites de tempo toleram somente limpeza e overhead limitado. |
| Interrupção: 130/143, limpeza própria e recuperação | Sinais enviados ao PID anunciado pelo ProcessBuilder somente após prontidão de pai e filho; `ps` ignora zombies, sandbox deve desaparecer, segunda execução deve continuar ativa | Verifica trabalho real, não somente a existência de um hook. A coordenação da janela iniciar/registrar é adicionalmente auditada na seção estrutural. |
| Publicação e recuperação: erro 2 sem JSON final, anteriores preservados | Remove a reserva vazia após anúncio e substitui o diretório por arquivo; libera comando ativo; exige 2, ausência de JSON/complete, sandbox limpa, relatório anterior idêntico e nova execução bem sucedida | Produz FileSystemException real, sem simular retorno de escrita. Detectou IOException escapando do antigo catch String e produzindo exit 1. |
| Evidência válida: contratos M2 continuam normativos | Casos de baseline vermelha/import quebrado, zero casos, runner indisponível, check/test inválido ou contraditório, contadores originais fora da faixa, descartes seguidos de Killed e todos descartados | Não aceita qualquer exit não zero como Killed ou rejeição autorizada; confere campos, fase, IDs, logs e reconciliação das contagens. Os 29 casos passaram no checkout e na cópia limpa. |
| Equivalência: EXECPLAN exige resultado sem diferença inventada | `clamping negatives...`, fixture real com -7/0/7; baseline de três casos, um boundary < para <=, localização 5:15, um Survived, complete/1, sem descartes/limitações | Detecta supressão automática e falsa morte. Os testes especificam o contrato observável em cada classe de entrada. |
| Aceitação externa: 85 s internos/90 s externos, sem reduzir escopo/testes | Baseline real, erro importado detectado em cópia, três amostras quentes Background/Meteor e uma Background com cache vazio; revisão e inventários do original | Não confunde filesChecked de entrada com imports/casos; mede invocação completa, incluindo launcher, e expõe Pending/timeout como limitação. Sete amostras medidas abaixo. |
| Documentação: mesmos identificadores EN/PT e sensores | READMEs, EXECPLAN vigente, plano dos sensores, guia inicial e plano externo original reconciliados; auditoria de flags/campos, exemplos executados | Distingue contrato vigente de registros históricos datados. M4 e ativação de sensores não são apresentados como entregues. |

As expectativas foram conferidas com o plano M3 do usuário, EXECPLAN e correções M2. O objetivo não é produzir verde a qualquer custo: incomplete e sobreviventes equivalentes são resultados honestos. Uma suíte verde isoladamente não comprova desempenho ou adequação dos sensores.

## TDD e provas de interoperabilidade

Logs locais em `.agent/tmp/m3/`, excluídos do Git. `reports-red.log` registra ausência do novo contrato; `reports-green.log` passou. `snapshot-red.log` falhou com inputs ponto: Java normalize produzia caminho vazio; agora ele é representado como ponto e `snapshot-green.log` passou (14380 ms). `cancel-red.log` falhou com command parent remains active; `cancel-green-3.log` passou com INT/TERM e recuperação. Tentativas intermediárias documentam limitações de Kof e um erro de edição corrigido, sem ocultá-las. `publication-red.log` contém o exit errado e FileSystemException real; `robustness-green.log` passou após tratar Exception na fronteira (30673 ms). `robustness-complete.log`: seis cenários, 28359 ms. `equivalent-red.log` falhou antes da fixture; `equivalent-green.log`: sete cenários, 31889 ms.

A prova JVM do hook exigiu cast explícito para Runnable e runtime Kof inicializado antes do registro; o programa real já usa o runtime durante parsing/construção da execução. `hook-probe.log` registrou ready e o arquivo de prova recebeu hook ran; `hook-removal.log` registrou true e o callback removido não foi executado. SHA-256 usa StandardCharsets.UTF_8/MessageDigest/HexFormat: a chamada encadeada String.getBytes gerou VerifyError em 0.6.4 e foi substituída antes das provas verdes. Sem modificar Kof ou introduzir Java no motor.

## Revisão estrutural

Aplicada a skill refactor-design após suíte completa e checkpoint CLI verdes. Escopo: Inputs, Sandbox, Evidence, Run e RunResources; sem Java/Spring ou alteração de arquitetura pública. A revisão não justificou outra refatoração de produção.

- Ausência de ação: MutationRun e RunResources têm vida de uma invocação; não há estado estático ou reutilização entre execuções. O contexto de recursos tem responsabilidade própria, não foi criado só para testes.
- Ausência de ação: o lock cobre start e registro, cancelamento, preparação/remoção e publicação. As esperas dos comandos ficam fora dele; o hook consegue encerrar um comando bloqueado. A prova com pausa demonstra a janela que um hook ingênuo deixaria aberta.
- Ausência de ação: active e hasActive representam o processo atual e a posse ainda ativa. A representação local respeita a limitação observada de atribuição de null em 0.6.4; somente start/release a atualizam, sob o mesmo lock. A referência anterior é limitada a um processo e à vida da invocação.
- Ausência de ação: o caminho canônico validado é conservado em RunOptions; snapshot imutável é a fonte das variantes. A reserva pertence à execução e a limpeza precede publicação. Não se introduziram helpers de produção exclusivos das provas.

## Prova da janela de início e registro

O instrumento local `transition-proof.py` trabalha em duas cópias descartáveis do KofMut e num projeto sintético. Insere uma pausa de 3000 ms imediatamente depois de ProcessBuilder.start e antes do registro do processo. O runner confirma prontidão de pai e descendente dentro dessa janela; TERM é enviado ao PID do KofMut.

| Cópia | Exit | Pai ativo depois | Descendente ativo depois | Sandbox presente depois |
| --- | --- | --- | --- | --- |
| Coordenação original com lock | 143 | não | não | não |
| Coordenação removida somente na cópia | 143 | sim | sim | não |

`transition/results.json` e `transition.log` registram os resultados. O instrumento mata explicitamente os processos remanescentes da cópia incorreta e remove seus temporários. A primeira tentativa instrumental perdeu a permissão executável do runner por usar copyfile; foi corrigida para copy2 e preservada em transition-instrument-error.log. Isso não alterou a implementação nem seus testes. A prova distingue o lock funcional de um hook que só limpa processos já registrados; a suíte regular permanece pelo CLI, sem seam de teste em produção.

## Aceitação externa

SiFuture em `/home/renanfranca/projects/kof-sifuture`, revisão `82111142c85f98b970ccd65fbf044e492d017729`, árvore limpa na inspeção. Somente fontes, manifesto e wrapper necessários são copiados para temporários do sistema; fontes externas não entram neste repositório. Adaptador temporário reutiliza prepared_sources e executa `kof check Main.kf --target jvm --json`, preservando stdout e exit. Testes usam o wrapper canônico `python3 scripts/kof_project.py test --target jvm`, sem reduzir casos ou destinos configurados.

A prova prévia retornou check=0 (1.910 s) e testes=0 (2.579 s), com 114 PASS e `0 failed of 114 tests`. `filesChecked` é 1 para o ponto de entrada. Um erro sintético m3UndefinedImportedValue em Background.kf foi detectado pelo check, exit 1 e diagnóstico correspondente. As cópias medidas são recriadas intactas. Inventários SHA-256/permissões do original antes/depois são comparados. Logs em `.agent/tmp/m3/external/` e instrumento local `external-acceptance.py`.

## Medições externas observadas

Uma chamada de --version aqueceu o lançador. Três amostras alternadas por escopo usaram seu cache quente; a quarta amostra pequena usou cópia descartável do KofMut sem build/cache. Nenhuma suíte de validação executou simultaneamente às medições. O limite externo usa relógio monotônico desde antes de Popen, com prazo de 90 segundos; o orçamento interno é 85000 ms desde run, com 10000 ms por comando. Fontes/escopo/testes/orçamento não foram reduzidos para obter conclusão.

Cada baseline teve check válido, filesChecked=1, 114 casos executados e zero falhas. Em todas as amostras: uma descoberta, JSON válido/coerente, compileError=0, nenhum limite externo atingido e zero descartes. K/S/T/TE/P significam Killed/Survived/Timeout/TestError/Pending; baseline é check/test em ms; candidatos/executados não incluem descartes.

| Amostra | Externo s | durationMs | Baseline ms | Candidatos/executados | K/S/T/TE/P | Descartes | Status/exit |
| --- | --- | --- | --- | --- | --- | --- | --- |
| small-warm-1 | 10.082 | 9348 | 1919/2709 | 1/1 | 1/0/0/0/0 | 0 | complete/0 |
| representative-warm-1 | 85.776 | 85015 | 1939/2637 | 41/17 | 12/4/1/0/24 | 0 | incomplete/3 |
| small-warm-2 | 10.434 | 9682 | 2030/2770 | 1/1 | 1/0/0/0/0 | 0 | complete/0 |
| representative-warm-2 | 85.777 | 85014 | 2038/2755 | 41/17 | 12/4/1/0/24 | 0 | incomplete/3 |
| small-warm-3 | 10.383 | 9636 | 2032/2789 | 1/1 | 1/0/0/0/0 | 0 | complete/0 |
| representative-warm-3 | 85.773 | 85013 | 2143/2821 | 41/17 | 12/4/1/0/24 | 0 | incomplete/3 |
| small-cold-1 | 15.242 | 9637 | 2038/2755 | 1/1 | 1/0/0/0/0 | 0 | complete/0 |

Background concluiu nas três amostras quentes (mediana 10.383 s) e no cache vazio (15.242 s). Meteor esgotou o orçamento em todas as três amostras, entre 85.773–85.777 s externos, com fases/candidatos pendentes explícitos. Os tempos da baseline e dos candidatos apontam para o custo de repetir check e a suíte canônica por candidato; a baseline já consome cerca de cinco segundos. Essa atribuição do gargalo é uma inferência dos tempos observados, sem perfil separado do compilador. Esse resultado não sustenta prontidão geral para uso diário dos sensores no escopo representativo. Não houve aumento de orçamento, filtro de candidatos ou redução de testes. A implementação/ativação dos sensores permanece no plano próprio.

Os JSONs completos, tempos, logs e inventários ficam em `.agent/tmp/m3/external/`; cold-command-logs preserva os logs da cópia descartável do KofMut. O inventário original após todas as medições coincide com o anterior; fontes privadas não foram adicionadas ao repositório. A instalação usada foi Kof 0.6.4 com JDK 25.0.4.1; instrumento/wrapper externo usaram Python 3.10.12. A amostra fria mede apenas o escopo pequeno, sem generalizar seu custo para Meteor. Três amostras quentes não são promessa de latência em outros ambientes.

## Validação final e recuperação

Validação ampla, repetição limpa e medições externas concluídas. `./scripts/launch contracts` retornou 0 com 15 grupos frontend em contracts.log. As quatro invocações CLI documentadas retornaram detected=0/complete/Killed, survived=1/complete/Survived, invalid=3/no_mutants/um descarte e equivalent=1/complete/Survived; inventários das fixtures antes/depois coincidiram (manual/results.json). `git diff --check`, sintaxe Bash dos runners e links locais dos documentos passaram. check.log: CLI 242933 ms e ciclo 312145 ms; check-clean.log: CLI 277673 ms e ciclo 276335 ms, ambos com frontend aprovado. Os 48 arquivos de fontes, fixtures, scripts, VERSION e manifesto de build da cópia limpa ainda coincidem com o checkout por SHA-256. O manifesto [kofmut-m3.sha256](kofmut-m3.sha256) identifica a entrega local, incluindo arquivos novos e evidências anteriores. O [manifesto externo](kofmut-m3-external.sha256) registra os três documentos autorizados fora do checkout; ele é específico deste ambiente. A base Git isoladamente não contém M3: usar o manifesto da árvore local até eventual commit autorizado. Para recuperar um processo interrompido, iniciar outra invocação; ela reserva outro diretório. Não promover diretório reservado sem report.json como resultado. Preservar relatórios anteriores para auditoria. O cache do lançador conserva a recuperação documentada no M1P. SIGKILL, falha da JVM, filesystem indisponível e processos que abandonem o grupo não ganham garantias novas.


## Arquivos da entrega e fechamento

- Motor Kof: Inputs.kf (CLI/validação), Sandbox.kf (exclusões), Evidence.kf (execução), Run.kf (reserva/publicação) e novo RunResources.kf (posse/cancelamento); Main.kf atualiza a ajuda.
- Comportamento: Run.kf de testes, mutation-runner e novo m3-runner, fixtures/equivalent com três casos e explicação EN/PT. Nenhum teste do projeto avaliado é mutado.
- Documentação: READMEs EN/PT, EXECPLAN, este relatório e manifestos; plano externo dos sensores, guia inicial e plano externo original KofMut, identificados no manifesto externo. Registros M1/M1R/M1P/M2 preservados.

A repetição final `kof test src/test/kof/kofmut/Run.kf --tag m3` retornou 0 com sete cenários e 32382 ms em m3-final.log, após as medições. O código medido coincide por SHA-256 com os 14 inputs de motor/lançador registrados antes da medição. Nenhum teste adicional foi necessário para a reconciliação textual. O checkout original SiFuture continua limpo. M3 concluído com a limitação de desempenho acima; guias ampliados M4 e integração/ativação dos sensores continuam pendentes. Nenhum commit ou publicação.
