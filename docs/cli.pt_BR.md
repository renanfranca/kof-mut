[English](cli.md) | [Português](cli.pt_BR.md) | [KofMut](../README.pt_BR.md)

# Guia do CLI

Comece pelos [requisitos e quatro exemplos executáveis](../README.pt_BR.md#requisitos). Este guia é a referência de chamadas, configuração do projeto, isolamento e recuperação. Para o vocabulário dos resultados, leia [operadores](operators.pt_BR.md); para integração, use [JSON v1](report-format.pt_BR.md).

## Comandos e caminhos

No checkout do KofMut:

```bash
./bin/kof-mut --version
./bin/kof-mut --help
./bin/kof-mut run --project "my project" --files "my project/scope.json" \
  --config kof-mut.json --report-dir "mutation reports" \
  --run-id d7df680d-2304-43a3-9741-4b0ebd61686e
```

O último comando ilustra caminhos para seu projeto configurado. As [fixtures](../README.pt_BR.md#executar-uma-avaliação) prontas para executar retornam 0, 1, 3 e 1 para `detected`, `survived`, `invalid` e `equivalent`, respectivamente. Capture o exit de cada chamada mesmo quando diferente de zero; com `set -e`, coloque `run` numa condicional para inspecionar o resultado.

| Comando ou opção | Contrato |
| --- | --- |
| `--version` | Imprime `KofMut <VERSION>` e retorna 0; o fonte atual é `0.1.0` |
| Sem argumentos, `--help` ou `-h` | Imprime o uso e retorna 0; não é uma avaliação |
| `run` | Avalia escopo explícito de produção usando os comandos configurados do projeto |
| `--project PATH` | Obrigatório; raiz do projeto, resolvida canonicamente a partir do cwd do chamador |
| `--files JSON` | Obrigatório; arquivo JSON de escopo, resolvido a partir do cwd do chamador |
| `--config JSON` | Opcional; padrão `kof-mut.json`, relativo ao projeto salvo caminho absoluto |
| `--report-dir DIRECTORY` | Opcional; padrão `<project>/.kof-mut/reports`, nos demais casos relativo ao cwd do chamador |
| `--run-id UUID` | Opcional; string UUID na forma hexadecimal `8-4-4-4-12`; gerado quando omitido |

As flags recebem argumentos separados. Comandos ou flags desconhecidos, flags repetidas, valores ausentes ou vazios e inputs inválidos retornam 2. `run --help` não é um comando suportado. Coloque caminhos com espaços entre aspas. Os caminhos do escopo são relativos ao projeto, independentemente do cwd do chamador. O arquivo selecionado inteiro é avaliado, não apenas linhas alteradas; o KofMut não usa Git para escolher arquivos.

## Instalação local e gerenciamento

Execute o instalador em um checkout gravável com sua distribuição Linux/JVM do Kof selecionada no PATH:

```bash
./install.sh
./install.sh --prefix "$HOME/tools/kofmut"
./install.sh --help
```

Escolha a instalação padrão ou o exemplo de prefixo personalizado. O prefixo padrão é `$HOME/.local`; um `--prefix PATH` relativo é resolvido a partir do cwd do chamador. Não há `sudo`, downloads nem atualização do Kof. Argumentos vazios ou repetidos, flags desconhecidas, caminhos sobrepostos a este checkout e prefixos contendo o separador de classpath JVM `:` retornam 2 antes de alterar uma instalação existente. Comandos alheios existentes, links simbólicos em diretórios gerenciados e metadados de propriedade inválidos são recusados. Perfis de shell são preservados. Se `bin` não estiver no PATH, o instalador informa o local do executável; no prefixo padrão use `export PATH="$HOME/.local/bin:$PATH"`.

Quando `--prefix` é omitido, HOME deve estar presente, não vazio e ser absoluto antes da construção do caminho padrão. HOME ausente, vazio ou relativo retorna 2 com `HOME must be a non-empty absolute path when --prefix is omitted`, sem instalar no cwd nem em um local alternativo. Um `--prefix PATH` explícito usa esse caminho independentemente de HOME, inclusive caminhos relativos ao cwd. `./install.sh --help` retorna 0 mesmo com HOME inválido e não instala nada.

| Caminho relativo ao prefixo | Conteúdo |
| --- | --- |
| `bin/kof-mut` | Comando público gerenciado |
| `share/kof-mut/current` | Referência atômica à versão ativa |
| `share/kof-mut/releases/<id>` | Classes compiladas, runtime gerado, fontes de execução, bootstrap, VERSION, documentação pública, LICENSE, NOTICE e metadados da imagem |
| `state/kof-mut/compatibility/` | Imagens e aprovações geradas, bootstrap, locks e evidências de preparação |
| `state/kof-mut/owner.json` | Inventário de propriedade das versões publicadas |
| `state/kof-mut/manage.lock`, `state/kof-mut/usage.lock` | Arquivos persistentes de coordenação |
| `state/kof-mut/logs/run-<runId>-<unique-suffix>` | Logs das avaliações instaladas |

O conjunto instalado inclui `src/main/kof/` e os scripts necessários à recompilação, sem testes de desenvolvimento, metadados Git, cache do checkout, histórico, jar do Kof nem JDK. As verificações operacionais de compatibilidade fazem parte das fontes de execução. Links históricos no README copiado apontam para arquivos do checkout. O pacote pode ficar somente para leitura; a preparação usa `state/kof-mut/compatibility/`, as avaliações gravam logs no estado e os relatórios seguem `--report-dir`. Antes da primeira escrita no estado, uma verificação prévia recusa sobreposição com os inputs avaliados.

O recibo interno atual tem `schemaVersion: 2`: `buildDependency` registra versão e caminhos/conteúdos do Kof/Java usados na construção do pacote; `runtimeSources` lista caminhos relativos e hashes SHA-256 das fontes e scripts necessários à recompilação; `files` inventaria o pacote. `buildDependency` é proveniência da construção, não uma dependência que precise permanecer instalada. Recibos antigos com `schemaVersion: 1`, `dependency` e `files` continuam reconhecidos para propriedade, atualização e desinstalação; não são reescritos. Faça uma atualização inicial com `./install.sh` no mesmo prefixo para habilitar a adoção automática de Kof. Depois disso, selecionar outro Kof compatível no PATH dispensa checkout, reinstalação do KofMut e instalação antiga do Kof. `prefix`, `id`, `inputs` e `files` mantêm seus significados. `runtimeSources` e `files` são arrays de objetos `{ "path": "caminho/relativo", "hash": "<SHA-256>" }`. `buildDependency` mantém a forma anterior de `dependency`: `version`, `javaVersion`, `kof`, `java`, `jar` e `contents`; `contents` contém objetos `{path, hash}` com caminhos absolutos das dependências de construção.

Reinstale em um checkout atualizado com o mesmo prefixo para atualizar. Fontes, instalador, documentação e a dependência de construção determinam a identidade do pacote. Uma imagem compatível e íntegra, inclusive uma criada por reparo, é reutilizada. Mudanças estáveis somente na documentação ou em `install.sh` reutilizam as classes compiladas da aplicação e produzem o pacote correspondente. A preparação ocorre no filesystem de destino e executa provas reais de versão/ajuda antes da ativação atômica. Instaladores serializam a publicação. Preparação falha ou interrompida mantém a imagem ativa anterior utilizável; INT/TERM encerram os filhos do instalador e retornam 130/143, inclusive no início da criação do filho. Cada chamada resolve sua versão concreta no início, e imagens anteriores permanecem disponíveis enquanto chamadas antigas terminam. O filesystem precisa suportar bloqueios de arquivo e movimentos atômicos. Cada avaliação fixa os caminhos concretos do Kof selecionado no início; avaliações futuras podem adotar outro Kof. Para realocar a aplicação, instale em um prefixo novo; recibos existentes continuam indicando o prefixo original.

O instalador captura os caminhos participantes e hashes de conteúdo antes de preparar a aplicação. VERSION, lançador, licença, avisos e documentação copiados devem corresponder a esses inputs e à compilação selecionada. Após as provas da imagem, confere novamente o conjunto completo de arquivos participantes e seus conteúdos antes de publicar, registrar propriedade ou ativar. Mudanças detectadas retornam 2 com `checkout changed during installation; retry`, preservando a versão ativa anterior e o recibo de propriedade. Isso inclui fontes ou documentos adicionados/removidos e bytes alterados com timestamps intactos. Estabilize o checkout e tente novamente. Após a conferência final, nenhum componente do checkout é lido novamente para compor a imagem preparada.

Para reparar arquivos danificados da aplicação, execute `./install.sh` novamente com o mesmo prefixo e Kof compatível. O reparo publica uma imagem completa e mantém a versão danificada; arquivos alterados são preservados na desinstalação. A reinstalação pode usar outro identificador quando um diretório alheio ocupar o caminho de uma imagem. Arquivos de coordenação ausentes, recibos de propriedade corrompidos ou comandos alheios não autorizam reparo por sobrescrita: mantenha esses arquivos para inspeção e instale em outro prefixo. Encerramento abrupto pode deixar diretórios de preparação não ativados ou não registrados; eles nunca são usados como imagem ativa nem apagados apenas por seus nomes.

```bash
kof-mut uninstall
```

Somente a entrada instalada oferece `uninstall`; a execução pelo fonte mantém os comandos originais. Ajuda, `-h` e ausência de argumentos descrevem o gerenciamento instalado. A desinstalação obtém acesso exclusivo e retorna 2 sem remoção se houver uma chamada instalada ou gerenciamento da instalação ativo. Atualizações são permitidas durante avaliações. Desinstalação bem-sucedida retorna 0 e remove somente entradas com propriedade comprovada e arquivos intactos listados nos inventários das imagens. Preserva projetos, configurações, relatórios, logs, Kof, arquivos e diretórios desconhecidos e arquivos alterados da aplicação. O diretório de estado e os arquivos de coordenação permanecem para impedir que operações concorrentes obtenham inodes de bloqueio diferentes. Gerenciamento interrompido ou inválido não deve ser tratado como desinstalação concluída.

## Migrar de `--report`

A antiga opção `--report FILE` foi removida. Retorna 2 com `--report was removed; use --report-dir DIRECTORY` antes de criar diretórios de relatório ou executar comandos do projeto.

Use `--report-dir DIRECTORY` como raiz de relatórios e decodifique a string JSON `reportPath=` da própria chamada. Não a substitua por `DIRECTORY/report.json` fixo: cada execução reserva seu subdiretório. Um nome de arquivo antes passado a `--report` não é uma raiz de relatórios para reutilizar sem revisão. Veja [descoberta e publicação](report-format.pt_BR.md#descobrir-o-relatório-atual).

## Configurar um projeto

O formato de `fixtures/detected/kof-mut.json` é um ponto de partida concreto, com o limite opcional de paralelismo mostrado explicitamente:

```json
{
  "schemaVersion": 1,
  "sourceRoots": ["src"],
  "testRoots": ["tests"],
  "inputs": ["kof.toml", "src", "tests"],
  "checkCommand": ["kof", "check", "src/math/Calc.kf", "--json"],
  "testCommand": ["kof", "test", "tests"],
  "commandTimeoutMs": 10000,
  "budgetMs": 90000,
  "maxParallelMutants": 1
}
```

Adapte caminhos e comandos ao seu projeto. Não há padrões implícitos para campos obrigatórios da configuração.

| Campo | Tipo e significado |
| --- | --- |
| `schemaVersion` | Inteiro JSON original `1`, obrigatório |
| `sourceRoots` | Array não vazio obrigatório de caminhos relativos de diretórios de produção |
| `testRoots` | Array não vazio obrigatório de caminhos relativos de diretórios de testes; arquivos sob eles não podem ser selecionados |
| `inputs` | Array não vazio obrigatório de caminhos relativos de arquivos/diretórios a copiar, incluindo tudo de que os comandos precisam |
| `checkCommand` | Array não vazio obrigatório de strings, executável seguido por argumentos separados; deve emitir o protocolo oficial de `kof check --json` |
| `testCommand` | Array não vazio obrigatório de strings; deve emitir o protocolo suportado de suítes nomeadas de `kof test` |
| `commandTimeoutMs` | Inteiro JSON original obrigatório, `1..9223372036854775807`; timeout de cada comando |
| `budgetMs` | Inteiro JSON original obrigatório, `0..9223372036854775807`; zero remove o orçamento global de mutação |
| `maxParallelMutants` | Inteiro JSON original opcional `1..4`; omitido ou JSON `null` significa `1` |

Os números devem conservar forma inteira antes da decodificação tipada. Decimais (incluindo `0.0` e `1.0`), exponenciais como `1e0`, strings, booleanos, inteiros com overflow e tipos incompatíveis são inválidos. `budgetMs` ausente/null, orçamentos negativos e `commandTimeoutMs` ausente/null/não positivo retornam 2 antes de comandos do projeto ou alterações nos inputs. A exceção opcional de null vale apenas para `maxParallelMutants`. Configuração e relatório permanecem `schemaVersion: 1`.

Os comandos executam como argv com cwd na sandbox, ambiente herdado e stdin fechado. O KofMut não insere destino nem reúne argumentos num comando de shell. Declare em `inputs` cada script e dependência necessários na cópia, incluindo fontes e imports novos ainda não rastreados. Os comandos devem fazer check e testar o escopo selecionado. A JVM é o runtime do KofMut; o projeto avaliado usa o destino escolhido por seus próprios comandos.

Exit 0 sozinho é evidência insuficiente. O check da baseline exige JSON válido/coerente, `success: true`, zero erros e exit 0; os testes da baseline exigem suítes concluídas, casos executados e zero falhas. Contadores de check devem ser inteiros originais: `filesChecked` em `1..2147483647` e `errorCount` em `0..2147483647`; `filesChecked` conta arquivos de entrada, não imports. Rejeição coerente tem `success: false`, exit 1 e contagem positiva de erros correspondente aos diagnósticos ERROR. Wrappers devem preservar esses protocolos. Zero testes, SKIP sem casos executados, resumos ausentes, truncamento e saída contraditória nunca aprovam a baseline nem detectam mutantes. Veja [campos e estados da baseline](report-format.pt_BR.md#baseline-e-evidência-de-fase).

## Selecionar escopo e inputs

Um arquivo de escopo como `fixtures/detected/scope.json` contém:

```json
["src/math/Calc.kf"]
```

Entradas não têm globs. Caminhos são normalizados, deduplicados e ordenados. Cada entrada deve existir, terminar em `.kf`, estar sob `sourceRoots`, fora de `testRoots` e incluída em `inputs`. Caminhos absolutos, escapes do projeto, links simbólicos selecionados ou em componentes dos caminhos selecionados são recusados antes dos comandos do projeto. Array vazio produz `no_scope/3` sem comandos de baseline ou aprovação de qualidade.

A captura dos inputs preserva bytes, caminhos relativos e permissões de scripts antes da baseline. Links internos dos inputs são materializados somente quando seus destinos também pertencem aos inputs; destinos externos e ciclos são recusados. `.git`, `.agent/tmp`, `build/cache/kof-launch-v2`, `build/cache/compatibility`, o padrão `.kof-mut/reports` e a raiz customizada escolhida de relatórios dentro do projeto são excluídos, inclusive com `inputs: ["."]`. Relatórios anteriores não entram nos snapshots seguintes.

Escolha uma raiz de relatórios fora das raízes de produção/testes e dos inputs explícitos. Ela não pode ser a raiz do projeto nem sobrepor fontes, testes, manifesto, configuração ou escopo protegidos, incluindo aliases canônicos por links. Com `inputs: ["."]`, um namespace interno seguro de relatórios é excluído da cópia. Se a configuração não puder ser validada, somente um destino externo seguro pode receber relatório de erro; um destino interno retorna 2 com explicação no terminal e sem criar diretórios de relatórios ou executar comandos do projeto.

## Avaliação e isolamento

Um check e um teste completos da baseline precedem a seleção de candidatos. Baseline reprovada ou inválida impede comandos de mutantes. Cada candidato parte de uma cópia independente do mesmo snapshot de inputs; alterações em fontes ou efeitos de comandos anteriores dentro da cópia não entram na variante seguinte. Testes são copiados e nunca sofrem mutação. Sandboxes são removidas antes da publicação final.

As cópias isolam arquivos, não recursos externos. Comandos herdam credenciais e ambiente como qualquer chamada local. Bancos de dados, portas fixas e caminhos fora da sandbox continuam compartilhados quando os comandos do projeto os usam. Use `maxParallelMutants: 1` para essas dependências.

Com limites `2`, `3` ou `4`, a baseline ainda executa uma vez. Cada vaga livre recebe imediatamente o próximo candidato. Mutantes e descartes finais preservam a ordem de seleção dentro de cada array; a ordem de início/conclusão de comandos pode variar. A avaliação paralela consome mais CPU e memória. O limite efetivo aparece como `maxParallelMutants=N` na saída humana; JSON v1 não tem campo de limite paralelo.

## Timeouts e cancelamento

Para `budgetMs > 0`, o orçamento global monotônico começa na entrada de `run` e inclui captura dos inputs, baseline e trabalho dos mutantes. Não inclui a inicialização do lançador antes da entrada da aplicação. Cada comando recebe o menor valor entre `commandTimeoutMs` e o orçamento global restante. Ao esgotar, a admissão fecha e grupos ativos são interrompidos; nenhum comando posterior começa. Fases interrompidas tornam-se `Timeout`; trabalho cuja próxima fase não começou torna-se `Pending` com duração zero.

Para `budgetMs: 0`, não há orçamento global. Cada comando da baseline/dos mutantes ainda tem timeout individual positivo. Timeout de comando com limpeza confirmada permite continuar os candidatos restantes; essa execução é inconclusiva. Zero não significa tempo infinito de comando nem aprovação de qualidade.

Cada comando começa com `setsid` em seu próprio grupo de processos. A limpeza sinaliza os grupos pertencentes à execução e confere membros ativos em `/proc`; zumbis não são ativos. O cancelamento sinaliza todos os grupos antes de esperar com prazo compartilhado de dois segundos, recolhe tarefas e então remove sandboxes. Falha inesperada de tarefa ou limpeza fecha admissão e produz `error/2` quando publicável. Estados concluídos, IDs e evidências são mantidos, e candidatos não iniciados tornam-se `Pending/parse` com o motivo do erro. Falha de limpeza permanece explícita; não é encerramento confirmado.

SIGINT/SIGTERM durante comando ativo retornam 130/143 e limpam os grupos/sandbox daquela chamada, preservando chamadas simultâneas. Interrupção externa não promete relatório parcial. Comandos que deliberadamente abandonem seu grupo não têm garantia de cancelamento nesta versão.

## Relatórios e logs

A [referência do relatório](report-format.pt_BR.md#descobrir-o-relatório-atual) define reserva exclusiva, identidade canônica do projeto, `reportPath` atual, publicação atômica e validação. Falha de publicação retorna 2 sem relatório final utilizável. Nunca recorra a relatório anterior como alternativa.

No modo por fonte, logs separados de stdout/stderr dos comandos ficam em `.agent/tmp/run-<runId>-<unique-suffix>/` no checkout do KofMut. O modo instalado usa `<prefix>/state/kof-mut/logs/run-<runId>-<unique-suffix>/` e recusa sobreposição com inputs do projeto antes de gravar. São referenciados no `summary` da baseline e no `evidence` de mutantes/descartes. Rejeição no parse pode acrescentar `<index>-parse.log`; logs de comandos usam prefixos `baseline-check`, `baseline-test`, `<index>-check` e `<index>-test` com `.stdout`/`.stderr`. Os índices mantêm as posições originais de seleção após descartes. Esses caminhos são evidências locais, não um arquivo de logs portátil embutido. Preserve logs referenciados ao mover relatórios para revisão.

## Lançador e cache

Cada chamada resolve o caminho real de `kof` no PATH e consulta `kof info --json`. O bootstrap exige uma distribuição Linux com JDK embutido e versões declaradas coerentes, sem baixar ou atualizar dependências. Ajuda, `-h`, ausência de argumentos e `--version` não preparam compatibilidade nem compilam o motor. Quando necessário, o lançador compila somente um bootstrap mínimo. Chamadas com bootstrap válido usam Java diretamente, sem compilação indireta por `kof run`.

Antes da primeira avaliação com uma combinação nova, o KofMut captura os conteúdos do executável, jar, Java, componentes do JDK e fontes/verificações do KofMut. Recompila uma candidata, verifica contratos do lexer/parser oficial, posições e operadores, e avalia projetos sintéticos com mutantes detectados e sobreviventes. A verificação exige relatórios e evidências coerentes de compilação e testes. Confere novamente os conteúdos antes de publicar atomicamente a aprovação. Versão declarada, caminho e timestamps não bastam. O relatório público permanece `schemaVersion: 1`; `kofVersion` identifica o frontend efetivamente usado.

A preparação mostra apenas em stderr:

```text
kof-mut: Kof <version> detected; preparing application...
kof-mut: checking compatibility...
kof-mut: ready; starting evaluation.
```

Uma chamada que reutiliza aprovação válida não repete essas mensagens, compilação ou verificações comportamentais. O protocolo de stdout e `reportPath` permanece igual. Os comandos configurados mantêm argumentos, cwd e ambiente; um executável configurado literalmente como `kof` usa o caminho concreto selecionado naquela chamada. Scripts e executáveis explicitamente configurados mantêm sua própria resolução de dependências. A seleção do frontend de uma avaliação em andamento não muda quando um link no PATH é atualizado. Mantenha essa instalação concreta disponível e intacta até o término das chamadas que a utilizam.

Há 90 segundos totais para preparar, incluindo espera por outra preparação, até 10 segundos por comando e dois segundos compartilhados para encerrar processos. Essa etapa precede `budgetMs`, que continua governando somente o ciclo de mutação. Falha, protocolo inválido ou mudança de componentes descarta a candidata e retorna 2 antes dos comandos do projeto, com versão, etapa, causa e caminho de evidências. INT/TERM retornam 130/143 e impedem aprovação tardia. Corrija a causa e tente novamente; não é necessária limpeza manual e não há retorno automático para Kof anterior. Sintaxe desconhecida no projeto avaliado continua sendo limitação explícita e resultado incompleto/3.

No checkout, `build/cache/kof-launch-v2/` contém o bootstrap e `build/cache/compatibility/` contém `images/`, referências `approved/` e `locks/`. Evidências de preparação ficam em `.agent/tmp/m6/<UUID>/`. Na instalação, todos os componentes gerados ficam em `state/kof-mut/compatibility/`, com evidências em `logs/<UUID>/`. O pacote instalado permanece intacto. As identidades usam conteúdo SHA-256; o cache mínimo também usa BLAKE2b do jar completo. Uma aprovação inclui os hashes das classes geradas. Imagens selecionadas mantêm caminhos únicos; reconstruções publicam outra referência sem mover classes de avaliações em andamento.

Cache gerado danificado é reconstruído automaticamente. Fontes ou arquivos do pacote instalado danificados exigem reparar a instalação com `./install.sh --prefix PATH`; não são aceitos como novas fontes. Atualização e desinstalação preservam relatórios, logs e arquivos desconhecidos ou alterados. Para remover manualmente caches gerados, espere todas as chamadas terminarem e remova apenas imagens, referências e bootstrap, preservando logs. O filesystem precisa suportar locks e movimentos atômicos. Chamadas instaladas mantêm um lease flock compartilhado durante a passagem entre bootstrap e aplicação; os locks JVM também protegem execuções antigas. A desinstalação precisa obter ambos os leases exclusivos.

A [validação M6](../.agent/validation/kofmut-m6.md) registra versões efetivamente verificadas e custos iniciais e com cache. Não há limite numérico de regressão de desempenho nesta etapa. As [medições M1P](../.agent/validation/kofmut-m1p.md) são históricas; a [meta anterior de 90 segundos](../README.pt_BR.md#validação-e-próximos-marcos) continua adiada e não atingida. Sensores permanecem futuros.
