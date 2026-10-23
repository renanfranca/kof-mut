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

Execute o instalador em um checkout gravável com a distribuição compatível Kof 0.6.4 selecionada no PATH:

```bash
./install.sh
./install.sh --prefix "$HOME/tools/kofmut"
./install.sh --help
```

Escolha a instalação padrão ou o exemplo de prefixo personalizado. O prefixo padrão é `$HOME/.local`; um `--prefix PATH` relativo é resolvido a partir do cwd do chamador. Não há `sudo`, downloads nem atualização do Kof. Argumentos vazios ou repetidos, flags desconhecidas, caminhos sobrepostos a este checkout e prefixos contendo o separador de classpath JVM `:` retornam 2 antes de alterar uma instalação existente. Comandos alheios existentes, links simbólicos em diretórios gerenciados e metadados de propriedade inválidos são recusados. Perfis de shell são preservados. Se `bin` não estiver no PATH, o instalador informa o local do executável; no prefixo padrão use `export PATH="$HOME/.local/bin:$PATH"`.

| Caminho relativo ao prefixo | Conteúdo |
| --- | --- |
| `bin/kof-mut` | Comando público gerenciado |
| `share/kof-mut/current` | Referência atômica à versão ativa |
| `share/kof-mut/releases/<id>` | Classes compiladas e runtime gerado, VERSION, documentação pública, LICENSE, NOTICE e metadados da imagem |
| `state/kof-mut/owner.json` | Inventário de propriedade das versões publicadas |
| `state/kof-mut/manage.lock`, `state/kof-mut/usage.lock` | Arquivos persistentes de coordenação |
| `state/kof-mut/logs/run-<runId>-<unique-suffix>` | Logs das avaliações instaladas |

O conjunto instalado não contém fontes de desenvolvimento, testes, metadados Git, cache do repositório, evidências históricas, jar do Kof nem JDK. Links de validação histórica no README copiado se referem a arquivos disponíveis no checkout. A execução precisa apenas desta instalação e de sua dependência Kof externa fixada. O diretório da aplicação pode ficar sem permissão de escrita; os logs precisam de estado gravável e os relatórios seguem `--report-dir`. Destinos de logs sobrepostos a inputs configurados, fontes, testes, manifesto, configuração ou escopo são recusados antes dos comandos. Isso inclui a primeira chamada instalada.

A instalação registra Kof 0.6.4 e a versão do runtime JVM, caminhos canônicos de Kof/Java/jar e identificações SHA-256 do executável, Java, jar, módulos JDK e arquivo de versão JDK. As chamadas instaladas validam essas dependências e a imagem; dependências ausentes ou alteradas e imagens inválidas retornam 2 sem compilação automática nem retorno ao fonte. Mantenha essa instalação do Kof disponível. Outro `kof` ou `java` no PATH não altera a dependência do mutador. Os comandos do projeto avaliado mantêm PATH, ambiente, argv e seleção de destino herdados.

Reinstale em um checkout atualizado com o mesmo prefixo para atualizar. Fontes, instalador, documentação e dependências fixadas determinam a identidade da imagem. Uma imagem compatível e íntegra, inclusive uma criada por reparo, é reutilizada. A preparação ocorre no filesystem de destino e executa provas reais de versão/ajuda antes da ativação atômica. Instaladores serializam a publicação. Preparação falha ou interrompida mantém a imagem ativa anterior utilizável; INT/TERM encerram o grupo de processos do próprio instalador. Cada chamada resolve sua versão concreta no início, e imagens anteriores permanecem disponíveis enquanto chamadas antigas terminam. O filesystem precisa suportar bloqueios de arquivo e movimentos atômicos. Os caminhos Kof selecionados permanecem fixados até a reinstalação. Para realocar a aplicação, instale em um prefixo novo; recibos existentes continuam indicando o prefixo original.

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

A captura dos inputs preserva bytes, caminhos relativos e permissões de scripts antes da baseline. Links internos dos inputs são materializados somente quando seus destinos também pertencem aos inputs; destinos externos e ciclos são recusados. `.git`, `.agent/tmp`, `build/cache/kof-launch-v2`, o padrão `.kof-mut/reports` e a raiz customizada escolhida de relatórios dentro do projeto são excluídos, inclusive com `inputs: ["."]`. Relatórios anteriores não entram nos snapshots seguintes.

Escolha uma raiz de relatórios fora das raízes de produção/testes e dos inputs explícitos. Ela não pode ser a raiz do projeto nem sobrepor fontes, testes, manifesto, configuração ou escopo protegidos, incluindo aliases canônicos por links. Com `inputs: ["."]`, um namespace interno seguro de relatórios é excluído da cópia. Se a configuração não puder ser validada, somente um destino externo seguro pode receber relatório de erro; um destino interno retorna 2 com explicação no terminal e sem criar diretórios de relatórios ou executar comandos do projeto.

## Avaliação e isolamento

Um check e um teste completos da baseline precedem a seleção de candidatos. Baseline reprovada ou inválida impede comandos de mutantes. Cada candidato parte de uma cópia independente do mesmo snapshot de inputs; alterações em fontes ou efeitos de comandos anteriores dentro da cópia não entram na variante seguinte. Testes são copiados e nunca sofrem mutação. Sandboxes são removidas antes da publicação final.

As cópias isolam arquivos, não recursos externos. Comandos herdam credenciais e ambiente como qualquer chamada local. Bancos de dados, portas fixas e caminhos fora da sandbox continuam compartilhados quando os comandos do projeto os usam. Use `maxParallelMutants: 1` para essas dependências.

Com limites `2`, `3` ou `4`, a baseline ainda executa uma vez. Cada vaga livre recebe imediatamente o próximo candidato. Mutantes e descartes finais preservam a ordem de seleção dentro de cada array; a ordem de início/conclusão de comandos pode variar. A avaliação paralela consome mais CPU e memória. O limite efetivo aparece como `maxParallelMutants=N` na saída humana; JSON v1 não tem campo de limite paralelo.

## Timeouts e cancelamento

Para `budgetMs > 0`, o orçamento global monotônico começa na entrada de `run` e inclui preparação, baseline e trabalho dos mutantes. Não inclui a inicialização do lançador antes da entrada da aplicação. Cada comando recebe o menor valor entre `commandTimeoutMs` e o orçamento global restante. Ao esgotar, a admissão fecha e grupos ativos são interrompidos; nenhum comando posterior começa. Fases interrompidas tornam-se `Timeout`; trabalho cuja próxima fase não começou torna-se `Pending` com duração zero.

Para `budgetMs: 0`, não há orçamento global. Cada comando da baseline/dos mutantes ainda tem timeout individual positivo. Timeout de comando com limpeza confirmada permite continuar os candidatos restantes; essa execução é inconclusiva. Zero não significa tempo infinito de comando nem aprovação de qualidade.

Cada comando começa com `setsid` em seu próprio grupo de processos. A limpeza sinaliza os grupos pertencentes à execução e confere membros ativos em `/proc`; zumbis não são ativos. O cancelamento sinaliza todos os grupos antes de esperar com prazo compartilhado de dois segundos, recolhe tarefas e então remove sandboxes. Falha inesperada de tarefa ou limpeza fecha admissão e produz `error/2` quando publicável. Estados concluídos, IDs e evidências são mantidos, e candidatos não iniciados tornam-se `Pending/parse` com o motivo do erro. Falha de limpeza permanece explícita; não é encerramento confirmado.

SIGINT/SIGTERM durante comando ativo retornam 130/143 e limpam os grupos/sandbox daquela chamada, preservando chamadas simultâneas. Interrupção externa não promete relatório parcial. Comandos que deliberadamente abandonem seu grupo não têm garantia de cancelamento nesta versão.

## Relatórios e logs

A [referência do relatório](report-format.pt_BR.md#descobrir-o-relatório-atual) define reserva exclusiva, identidade canônica do projeto, `reportPath` atual, publicação atômica e validação. Falha de publicação retorna 2 sem relatório final utilizável. Nunca recorra a relatório anterior como alternativa.

No modo por fonte, logs separados de stdout/stderr dos comandos ficam em `.agent/tmp/run-<runId>-<unique-suffix>/` no checkout do KofMut. O modo instalado usa `<prefix>/state/kof-mut/logs/run-<runId>-<unique-suffix>/` e recusa sobreposição com inputs do projeto antes de gravar. São referenciados no `summary` da baseline e no `evidence` de mutantes/descartes. Rejeição no parse pode acrescentar `<index>-parse.log`; logs de comandos usam prefixos `baseline-check`, `baseline-test`, `<index>-check` e `<index>-test` com `.stdout`/`.stderr`. Os índices mantêm as posições originais de seleção após descartes. Esses caminhos são evidências locais, não um arquivo de logs portátil embutido. Preserve logs referenciados ao mover relatórios para revisão.

## Lançador e cache

Na execução por fonte, a ponte Bash fixa o executável real do Kof e consulta `kof info --json` fresco em cada chamada. Localiza jar e Java embutido instalados sem downloads ou atualizações. Kof 0.6.4 é obrigatório tanto para versão e ajuda quanto para avaliação. A entrada Kof compilada `kofmut.launch.RuntimeEntry` valida a evidência fresca da instalação e inicia a aplicação na mesma JVM, preservando argv, cwd, ambiente, exit e sinais. Python não faz parte desse caminho.

Quando não há cache válido, `scripts/bootstrap/Launch.kf` executa por `kof run`, valida os inputs capturados e os compila com `kof build --target jvm --classpath`. Um lock e uma segunda conferência do cache serializam a preparação; apenas imagem completa e bem-sucedida é publicada por movimento atômico de diretório. Aplicação, entrada e runtime JSON gerado compilam juntos. Falha de preparação retorna 2 sem recorrer a imagem anterior.

`build/cache/kof-launch-v2/locations/` contém descritores da instalação; `images/` contém programas compilados. A identidade SHA-256 cobre modo, checkout, executável fixado/conteúdo, JSON fresco, lançadores, VERSION, manifesto e fontes pertinentes em campos determinísticos separados por NUL; a identidade final incorpora o hash BLAKE2b de 512 bits do jar inteiro obtido por GNU `b2sum`. Classes geradas têm checksums SHA-256. Timestamps não estabelecem validade. Alterações no projeto avaliado não recompilam o KofMut. O protocolo NUL interno é `kofmut-location-v1`; caches antigos de Python/`kof-bootstrap-v1` são ignorados.

Descritores ausentes/inconsistentes ou imagens incompletas acionam preparação. Para recuperar cache interrompido, execute na raiz do checkout após o fim das chamadas ativas:

```bash
rm -rf -- build/cache/kof-launch-v2
./bin/kof-mut --version
```

Isso descarta imagens compiladas e diretórios de preparação; a próxima chamada recompila. O filesystem do cache deve suportar locks e movimentos atômicos de diretório. O lançador oficial do Kof também consulta `java -version` antes da instalação: a inicialização com cache válido tem duas JVMs de trabalho e essa sondagem. Custos históricos de inicialização e condições pertencem à [evidência M1P](../.agent/validation/kofmut-m1p.md), sem promessa para o primeiro build ou projetos avaliados. Veja [estado da validação](../README.pt_BR.md#validação-e-próximos-marcos) para a meta de desempenho adiada e sensores futuros.
