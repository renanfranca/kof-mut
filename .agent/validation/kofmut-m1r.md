# KofMut M1R: bootstrap Kof sem Python

## Estado e proveniência

M1R concluído em 2026-10-16, somente no checkout local. Branch reutilizada: `kofmut-frontend`; commit base observado: `adec628b08d1a221801295463ae642856ce502ee`. As alterações deste marco estão sem commit. Não houve criação de branch, worktree, subagente, commit, remote ou publicação nesta execução.

O [manifesto M1R](kofmut-m1r.sha256) identifica os arquivos entregues da árvore de trabalho. Este relatório e o próprio manifesto são excluídos para evitar autorreferência. O [relatório M1](kofmut-v0.1.0.md) e seu [manifesto histórico](kofmut-m1.sha256) foram preservados; descrevem a implementação anterior com Python e não são um manifesto da árvore atual.

| Item | Evidência observada |
| --- | --- |
| Modelo autorizado | GPT 6.1 Sol, esforço xhigh |
| Distribuição executada | Kof/compiler/runtime/stdlib 0.6.4, Linux x86_64 |
| Instalação fixada | `/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64` |
| JDK embutido | Eclipse Adoptium 25.0.4.1; `embeddedJdk: true` |
| SHA-256 de `lib/kof.jar` | `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62` |
| Fontes Kof consultadas | `/home/renanfranca/projects/kof`, HEAD `53efd25fdb8dfec1fbbd989c1f482b2ee38c3ce8`, VERSION 0.6.5 |
| Compatibilidade anunciada | Exclusivamente Kof 0.6.4 na JVM/Linux |

As fontes locais orientaram as decisões; as provas executaram na distribuição 0.6.4. Foram consultados documentação e testes de interoperabilidade, bytes, coleções, JSON e processos, além de `CmdRun`, `CmdBuild`, `KofShell` e o runtime JVM. Nenhuma alteração foi feita em Kof, SiFuture ou skills globais.

## Implementação entregue

`scripts/launch.py` foi removido. `scripts/bootstrap/Launch.kf` consulta e decodifica `info --json`, valida as quatro versões e a distribuição Linux com JDK embutido, localiza jar/Java, calcula o cache, copia bytes, compila e prepara o argv Java. Usa stdlib Kof para JSON, processos e cópia por bytes; JDK para SHA-256 do jar, caminho canônico, bloqueio e publicação atômica.

`scripts/launch` fixa o executável Kof por caminho real antes do bootstrap, cria uma entrega por invocação e chama `kof run --target jvm` somente com argumentos internos. A entrega contém o marcador `kofmut-launch-v1` e seis campos do comando Java, em UTF-8 terminados por NUL. A ponte valida marcador, quantidade, executável e classe `Default.Main`, remove a entrega e executa a JVM por `exec`, acrescentando os argumentos originais por `"$@"`. Os argumentos da aplicação nunca passam pelo parser de opções de `kof run`. `bin/kof-mut` e `scripts/check` compartilham essa ponte.

O cache usa `build/cache/kof-bootstrap-v1/`, separado das entradas do antigo lançador. A chave inclui modo, executável resolvido, informações da instalação, jar, manifesto, VERSION, lançadores e fontes ordenados. Os bytes de cada fonte são capturados em `SourceSnapshot`; a chave usa SHA-256 de sua representação JSON de inteiros, e a compilação recebe os mesmos bytes. Um bloqueio cobre a consulta e a compilação. A publicação usa `ATOMIC_MOVE` de diretório no mesmo filesystem, após exit 0 e verificação de `classes/Default/Main.class`. Não há alternativa silenciosa à publicação atômica.

O frontend e suas nove provas não foram alterados. A seleção continua limitada ao M1. O Kof jar e o JDK não foram copiados para o fonte entregue.

## TDD e revisão estrutural

O primeiro teste novo executou o lançador com PATH sem Python e falhou com `exec: python3: not found`. Após a substituição, passou. Um teste adicional de falha na preparação da entrega encontrou exit 1 de `mktemp`; a correção passou a retornar 2 com `kof-mut: cannot create launch handoff`.

Os demais testes comprovam contratos já exigidos do lançador e suas guardas, sem criar falhas artificiais. Cada incremento executou a suíte relevante inteira por `./scripts/check`. Logs locais permanecem em `.agent/tmp/`, fora da entrega versionada.

A revisão por `refactor-design` classificou como risco de desenho a leitura dos fontes em momentos diferentes para chave e cópia. O uso de `SourceSnapshot` eliminou a segunda leitura. Uma prova em 0.6.4 confirmou o record com `Int[]`, JSON e cópia byte a byte conferida por `cmp`; a suíte completa continuou verde. A sobrecarga JDK `Files.copy` havia produzido falha de geração de bytecode; a implementação usa `File.readBytes()`/`writeBytes()` do Kof.

## Aceitação observada

Comando no checkout principal:

```bash
PATH=/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64/bin:$PATH ./scripts/check
```

Resultado: **exit 0; 11 testes nomeados do CLI e nove provas do frontend aprovados**. A suíte nomeada do CLI levou 64,157 s na execução final do checkout. Esse tempo reúne muitos lançamentos independentes; não representa uma única inicialização ou execução de mutação.

| Comportamento do CLI | Resultado observado |
| --- | --- |
| Versão lida de VERSION | Exit 0 e `KofMut 0.1.0` |
| Versão incompatível após cache existente | Fixture 9.9.9 rejeitada com exit 2 e mensagem das quatro versões exigidas |
| PATH sem Python | Lançamento real aprovado com lista restrita de executáveis |
| Argumentos, cwd, ambiente e saída | Vazio, espaços, Unicode, nova linha, metacaracteres, `--target` e `--deps` preservados; cwd externo ao checkout, ambiente exato e exit 23 da fixture |
| Falha de preparação | TMPDIR inexistente retorna 2 e diagnóstico explícito |
| Reutilização e invalidação | Duas chamadas iguais produzem um build; VERSION e fonte alterados geram um build adicional cada |
| JSON inválido com cache existente | Exit 2, stdout vazio e nenhuma compilação adicional |
| Troca do link após descoberta | Link aponta à ferramenta substituta, mas a compilação usa o executável original fixado |
| Erro depois de classes emitidas | Exit 2 sem executar a aplicação; nova tentativa compila novamente e retorna 0 |
| Concorrência com cache frio | Duas chamadas simultâneas retornam a versão correta; log registra exatamente um build |
| Interrupção após classes emitidas | Teste confirma Main.class, encerra o grupo por TERM e comprova nova compilação e lançamento bem-sucedido |

As nove provas do frontend continuam cobrindo token exato, percurso de campos/construtores/métodos/lambdas, arquivo real, operadores repetidos/aninhados, comentários/strings/genéricos, Unicode/CRLF/UTF-16, erros lexicais e sintáticos, AST não suportada e arquivo ausente.

### Cópia limpa sem Python

Uma cópia foi preparada com `tar`, excluindo `.git`, `build/` e `.agent/tmp/`, num caminho contendo espaços. Antes do primeiro comando, foram confirmadas as ausências desses diretórios e de `scripts/launch.py`.

Preparação e execução usaram PATH restrito aos links `bash`, `dirname`, `readlink`, `sed`, `head`, `mktemp`, `rm`, `env` e `kof` 0.6.4. `command -v python` e `command -v python3` não encontraram executáveis. Os auxiliares dos testes usam caminhos Linux absolutos; nenhum passo depende de Python.

`./scripts/check` retornou **0**, com os mesmos **11 + 9** comportamentos aprovados. A suíte nomeada levou 63,866 s. A cópia não depende de Git, do checkout de fontes do Kof ou de arquivos privados.

### Inicialização e comandos públicos

Após a validação, o diretório `build/` foi preservado fora da cópia, deixando o cache vazio. Duas chamadas consecutivas de `--version`, medidas por `/usr/bin/time`, produziram:

| Condição | Tempo observado | Saída |
| --- | --- | --- |
| Cache frio | 4,46 s | Exit 0, `KofMut 0.1.0`, stderr vazio |
| Cache quente | 2,64 s | Exit 0, `KofMut 0.1.0`, stderr vazio |

São duas amostras locais. O bootstrap compila a cada chamada; somente a aplicação usa o cache. O orçamento futuro de 90 segundos não foi alterado nem declarado comprovado.

`--help` retornou 0 e a ajuda do produto. `run` continua retornando 2, pois M2 está pendente. O PATH padrão com Kof 0.6.5 retornou 2 e `requires Kof/compiler/runtime/stdlib 0.6.4`, sem stdout de versão.

### Auditoria final

`git diff --check` retornou 0. Os arquivos novos também passaram por `git diff --no-index --check`, sem diagnósticos de whitespace. `bash -n` dos dois pontos de entrada, ponte e fixtures retornou 0. `sha256sum --check .agent/validation/kofmut-m1r.sha256` retornou 0 para todos os arquivos listados.

A comparação com HEAD confirmou ausência de alterações em `src/main/kof/`, VERSION, `kof.toml`, nas nove provas do frontend e nos dois artefatos históricos do M1. Não há arquivo `.py` entre os fontes atuais. Os links documentados do M1R apontam ao relatório e manifesto desta entrega.

## Limites e continuidade

M1R conclui a substituição do lançador. Baseline, execução de mutantes, operadores restantes, relatórios JSON, orçamento global e cancelamento de descendentes de projetos avaliados permanecem em M2/M3. O encerramento do grupo no teste de bootstrap não comprova o futuro controle de processos do mutador. Nenhum sensor foi ativado.

O cache exige filesystem com bloqueio de arquivos e movimento atômico de diretórios; falhas são explícitas. Uma interrupção abrupta pode deixar diretórios temporários sem uso. Remover `build/cache/` descarta builds e força a recompilação. O manifesto e o relatório do M1 permanecem históricos, sem substituição de suas evidências.

Continuar pelo **M2** do [EXECPLAN](../../EXECPLAN.md). A documentação EN/PT descreve o bootstrap atual e os mesmos limites; novas ações Git ou publicação continuam dependendo de instrução explícita.
