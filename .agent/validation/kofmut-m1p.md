# KofMut M1P: inicialização com imagem Kof conjunta

## Estado e proveniência

M1P concluído em 2026-10-16, com os comportamentos e a meta de desempenho aprovados. Base observada: `760414212b10cbf2fb39b7233e04c688e6d09104`; branch `kofmut-frontend`; árvore inicialmente limpa, um commit à frente de origin. Sem novos commits, worktrees, subagentes, remotes ou publicações. Modelo autorizado: GPT 6.1 Sol, esforço xhigh.

Distribuição executada: Kof/compiler/runtime/stdlib 0.6.4 Linux x86_64, JDK Eclipse Adoptium 25.0.4.1 embutido, em `/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64`. SHA-256 de `lib/kof.jar`: `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62`. Fontes locais consultadas em `/home/renanfranca/projects/kof`, revisão `53efd25fdb8dfec1fbbd989c1f482b2ee38c3ce8`: documentação de interoperabilidade, arquivos, JSON, processos e CLI; implementação de info, geração de JSON/crypto e testes JVM. O PATH padrão aponta para 0.6.5 e não foi alterado globalmente. Nenhuma mudança foi feita no Kof.

As evidências e os manifestos históricos M1 e M1R permanecem preservados. O [manifesto M1P](kofmut-m1p.sha256) identifica a árvore entregue. Este relatório e o próprio manifesto são excluídos, seguindo a convenção dos marcos anteriores.

## Caminho público e cache

A ponte Bash fixa o executável Kof antes da consulta `info --json`. Com cache quente, verifica os conteúdos e faz `exec` diretamente na imagem compilada. A entrada Kof `kofmut.launch.RuntimeEntry`, a aplicação e seu runtime JSON específico são compilados juntos. A entrada valida instalação fresca, caminhos e identidade, remove o contexto e chama `Default.Main.main` com `Class[]` e `Object[]` explícitos, na mesma JVM. Versão, ajuda e outros comandos percorrem a mesma entrada.

O namespace `build/cache/kof-launch-v2/` separa `locations/` de `images/`. A chave preliminar SHA-256 inclui modo, raiz, caminho e conteúdo do Kof fixado, JSON bruto fresco incluindo a nova linha final, lançadores, VERSION, kof.toml e fontes pertinentes. Os campos de caminhos e hashes seguem ordem determinística e terminam por NUL. A chave final SHA-256 incorpora caminho e BLAKE2b de 512 bits do jar inteiro, calculado pelo GNU `b2sum`. Fontes do projeto avaliado não participam da identidade.

O descritor `kofmut-location-v1` tem três campos NUL: marcador, Java e jar. Substitui a entrega `kofmut-launch-v1` do M1R. Bash não interpreta JSON nem usa `eval`. A JVM recebe cinco argumentos internos: raiz, Kof fixado, modo, contexto e imagem; depois, o argv original. Argumentos da aplicação não passam pelo parser do `kof run`.

Kof valida a instalação, confere os hashes e compila os bytes capturados dos fontes. O jar é conferido antes e depois da compilação. Bloqueio e nova consulta ao cache serializam a compilação da imagem. A publicação é atômica e exige exit 0, as duas entradas JVM e hashes das classes emitidas. Descritores inconsistentes e imagens incompletas ou danificadas acionam preparação automática. Falhas retornam 2 sem alternativa antiga.

O usuário confirmou manter o executável oficial e documentar sua sondagem. O script Kof 0.6.4 executa `java -version` antes de `info --json`: são duas JVMs de trabalho mais essa sondagem, ou três execuções Java contando todas. O trace de execuções confirmou sondagem, info e aplicação, sem `kof run` ou `kof build` no caminho quente. A medição do comando completo inclui todos esses custos.

## TDD e contratos

Comando no checkout principal:

```bash
PATH=/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64/bin:$PATH ./scripts/check
```

Resultado final após as correções: **exit 0, 21 testes nomeados do CLI e nove provas do frontend**, executando `./scripts/check` em nova cópia limpa com espaços e PATH sem Python (`.agent/tmp/m1p-final-clean.log`). O CLI levou 236,531 s; reúne muitos builds e lançamentos e não mede uma inicialização nem a futura integração. O checkpoint público de versão e ajuda no checkout principal também passou, com stderr vazio. Kof 0.6.5 foi rejeitado com 2 e stdout vazio.

| Comportamento | Evidência observada |
| --- | --- |
| Onze contratos anteriores do CLI | Todos preservados, incluindo fixação do executável após troca do link no PATH |
| Cache quente sem compilação | Versão, ajuda e fixture de argumentos funcionam com `run` e `build` recusados |
| Argumentos e contexto do chamador | Vazio, espaços, Unicode, nova linha, metacaracteres, `--target`, `--deps`, cwd externo, ambiente e exit 23 preservados |
| Conteúdos dos inputs | Fonte, entrada runtime, bootstrap, ponte, ponto público, check, VERSION, manifesto e Kof fixado invalidam mesmo com timestamps preservados |
| Independência do projeto avaliado | Mudança de fontes fora do diretório do KofMut não provoca compilação |
| Instalação e jar | Mesmo wrapper fixado com outra instalação gera nova imagem; atualização válida do jar descartável, com timestamp preservado, também invalida |
| Descritor inconsistente ou truncado | Java divergente e campo sem NUL final acionam preparação; reparação conserva a imagem completa e não recompila |
| Falha do hash do jar | Retorna 2, não executa imagem anterior e permite reutilização após recuperar o utilitário |
| Imagem danificada ou incompleta | Danos na identidade, Main, RuntimeEntry e runtime gerado, além de entrada ausente, provocam recompilação antes da aplicação |
| Concorrência | Duas chamadas frias concluem com uma única compilação de imagem |
| Falha e interrupção | Classes emitidas antes de erro ou TERM não são publicadas; nova chamada compila e funciona |
| Ciclo de vida e sinal | Aplicação observa a JVM RuntimeEntry, nenhum filho e contexto já removido; TERM ao PID observado encerra com 143 |
| Validação na entrada compilada | JSON alterado depois da seleção do cache é rejeitado com 2, stdout vazio e contexto removido, mesmo com compilação recusada |
| Frontend | As nove provas anteriores passam sem alteração de seus fontes |

Os ciclos registraram falhas antes das correções: cache quente ainda executava bootstrap; descritor corrigido em disco ainda era retido em Bash; presença das classes não detectava dano; `process.exit(2)` dentro do catch impedia a limpeza em finally. A correção de limpeza adia a saída até depois da remoção do contexto. A fixture de jar inicial foi rejeitada pela própria JVM após adição bruta de bytes; foi corrigida para uma atualização válida com `jar` do JDK embutido. Essa falha da fixture não foi contada como prova de invalidação de jar válido.

Os testes exercitam o CLI e o ciclo de vida do cache, sem testes de helpers internos ou organização por arquivo de produção. Logs e cópias sintéticas permanecem em `.agent/tmp/`, excluído da entrega.

## Cópia limpa e revisão estrutural

A validação final excluiu `.git`, build, caches e logs pessoais antes de começar, num caminho contendo espaços. O PATH continha somente bash, dirname, readlink, sed, head, mktemp, rm, find, sort, sha256sum, b2sum, cat, cmp, env e Kof 0.6.4. `python` e `python3` estavam ausentes. `./scripts/check` retornou 0 com **21 + 9** comportamentos, incluindo as duas correções finais. O produto e a suíte não dependem de Python.

A revisão `refactor-design` começou após suíte, checkpoint público e primeira medição verdes, com as rubricas geral e JVM. Escopo: ponte, preparador, entrada runtime e contratos cruzados. Foram classificados e tratados:

| Classificação | Evidência, decisão e proteção |
| --- | --- |
| Oportunidade de manutenção | O trace confirmou duas conferências completas de imagem consecutivas sem mudança de estado. A conferência posterior foi movida para o ramo de preparação. Os testes de cache e o checkpoint público preservam identidade, hashes, recuperação e erro 2. O trace final confirma uma conferência por chamada quente. |
| Defeito | Descritor sem NUL final era aceito. A revisão voltou ao TDD autorizado: o teste público falhou; o leitor passou a exigir todos os campos terminados por NUL. Rejeição, reparação e reutilização da imagem passaram. |
| Defeito | Falha de hash dentro da função Bash escapava com outro código. O teste público falhou; herdar ERR com `set -Eeuo pipefail` preservou o contrato 2. Falha, bloqueio da aplicação e retentativa passaram. |
| Sem ação | Estado por invocação e fases explícitas do protocolo não exigem objetos adicionais. `Class[]` e `Object[]` são fronteira JVM aprovada. ByteBuffer permanece restrito à captura e escrita dos mesmos bytes, sem mutação compartilhada. |

A revisão foi retomada com comportamentos completos, suíte e caminho público verdes; nenhuma mudança adicional se justificou. Não foram criados testes de helpers ou novas abstrações. Heurística específica do repositório: Main, RuntimeEntry e runtime JSON devem ser publicados e validados na mesma imagem; a documentação e as provas preservam esse contrato. Nenhuma skill foi alterada.

A primeira tentativa verde do teste de truncamento encontrou uma limitação da distribuição 0.6.4 ao comparar dois retornos `String?` de File.readText: uma prova isolada retornou falso com `==` para textos iguais e verdadeiro com `.equals`. A asserção usa comparação explícita de conteúdo. Isso não foi tratado como falha de reparação e não houve alteração no Kof.

`git diff --check`, inspeção de whitespace dos arquivos novos e `bash -n` passaram. O manifesto foi conferido com `sha256sum --check`. Frontend, suas nove provas e evidências históricas M1/M1R permanecem preservados. O trace final confirma `java -version`, `info --json` e a aplicação, sem run/build no caminho quente. A comparação de desempenho foi repetida após as correções.

## Desempenho

Ambiente local: Linux `6.18.54.1-microsoft-standard-WSL2`, x86_64; Bash 5.1.16, GNU coreutils 8.32, findutils 4.8.0, diffutils 3.8 e Python 3.10.12 para a referência. O produto não depende de Python. Tempos absolutos não são garantidos em outras máquinas.

Referência: `scripts/launch.py` e `bin/kof-mut` do commit `adec628b08d1a221801295463ae642856ce502ee`, com o mesmo Kof 0.6.4 e fontes de aplicação idênticos, conferidos por bytes e hashes. Comando público `--version`. Uma chamada de aquecimento por lançador, depois três blocos de 11 pares, alternando qual lançador executa primeiro. Relógio monotônico `time.perf_counter_ns`, medindo desde a criação do processo até sua conclusão, com captura de stdout/stderr nas duas variantes. O driver de medição fica em `.agent/tmp/m1p-benchmark.py` e usa Python somente para a comparação externa.

Resultado final: Kof **0.712937 s**, Python **0.673821 s**, diferença **5.81%**. O limite observado é **0.741204 s**; razão **1.058051 ≤ 1,10**. Critério aprovado.

| Lançador | N | Mediana (s) | Mínimo (s) | Q1 (s) | Q3 (s) | Máximo (s) | Média (s) | Desvio padrão (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Python | 33 | 0.673821451 | 0.654308921 | 0.667537226 | 0.676573795 | 0.688398086 | 0.672832667 | 0.008060906 |
| Kof | 33 | 0.712937439 | 0.685307968 | 0.704080036 | 0.719638273 | 0.740841611 | 0.711143521 | 0.013304636 |

Q1 e Q3 são os elementos 9 e 25 dos 33 tempos ordenados; desvio padrão populacional.

| Bloco | Mediana Python (s) | Mediana Kof (s) |
| --- | ---: | ---: |
| 1 | 0.680852735 | 0.713856667 |
| 2 | 0.670917335 | 0.712098969 |
| 3 | 0.672823215 | 0.713394617 |

As 66 chamadas quentes retornaram 0, stdout exatamente `KofMut 0.1.0` seguido de nova linha, stderr vazio. O executável controlado recusava `kof run` e `kof build`; o log de cada variante permaneceu com somente o build do aquecimento. Portanto foram **zero compilações durante a medição quente**.

Dados completos: [66 tempos e saídas](kofmut-m1p-performance.tsv), [resumo, dispersão, blocos, caches vazios e hashes dos fontes](kofmut-m1p-performance.json). No TSV, stdout e stderr são strings JSON dentro de campos TSV com escape CSV; o JSON registra os hashes dos mesmos fontes usados pelas duas variantes. Logs individuais de stdout/stderr e os caches descartáveis permanecem em `.agent/tmp/m1p-performance-nqdouzzx/`.

| Inicialização com namespace de cache vazio | Tempo (s) |
| --- | ---: |
| 1 | 5.053044044 |
| 2 | 5.152825790 |
| 3 | 5.165226537 |

Cada inicialização fria começou sem `build/cache/kof-launch-v2/`, compilou uma imagem e retornou a versão com stderr vazio. Não foram esvaziados os caches do sistema operacional. Esse é o custo de preparação inicial da ferramenta; a meta acordada vale para cache quente.

A primeira medição, antes da refatoração e das correções finais de protocolo/erro, também passou: Python 0,674121158 s, Kof 0,717686530 s, razão 1,064625433. Caches vazios: 5,300886370/5,226363935/5,219159647 s. Evidências locais preservadas em `.agent/tmp/m1p-performance-ptho6ubr/`. A tabela principal e os artefatos publicados acima correspondem à árvore final.

## Requisitos, recuperação e limites

Bash 4.4+, GNU coreutils (`dirname`, `readlink`, `mktemp`, `rm`, `cat`, `sort`, `sha256sum`, `b2sum`), GNU findutils (`find`) e GNU diffutils (`cmp`). O lançador oficial do Kof também usa `sed` e `head`. Os testes usam coreutils, `which`, `ps` e `setsid` por caminhos Linux explícitos; a fixture de jar usa o `jar` do JDK embutido. O driver externo de desempenho usa Python somente para medir também a referência Python; não faz parte do produto nem da suíte sem Python.

O cache requer bloqueio de arquivo e movimento atômico de diretórios. Uma interrupção abrupta pode deixar staging sem uso. Para recuperar e forçar nova preparação, remover `build/cache/kof-launch-v2/` na raiz do checkout; isso descarta apenas o novo namespace. Caches Python e M1R não são usados como alternativa.

M2 continua pendente. O orçamento de integração de 90 segundos ainda não foi comprovado; este trabalho mede inicialização, não execução de mutantes. Não há nova compatibilidade de Kof nem redistribuição de jar/JDK. Licença: GPL-3.0-only.
