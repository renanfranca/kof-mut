# Declarações `enum` sem limitação

Data: 2026-11-07 (UTC). Branch `enum-declarations` a partir de `main` `77dfa58` (igual a `origin/main`), checkout limpo no início. Kof 0.7.0 primeiro no PATH; Kof 0.6.4 como alternativa. Evidência local em `.agent/tmp/enum/` (não versionada).

## Problema

Uma execução do KofMut sobre toda a produção do SiFuture (`kof-sifuture/.agent/validation/sensor-debt-payoff.md`, seção "KofMut sobre toda a produção", commit `e6703db`) gerou 8 limitações `Unsupported AST node: dev.kof.compiler.EnumDeclarationNode`. Qualquer limitação torna a execução `incomplete` com exit 3 (`src/main/kof/kofmut/Run.kf:116`), então um arquivo com `enum` nunca chegava a `complete`.

## Mudança

`src/main/kof/kofmut/Frontend.kf` passa a tratar `EnumDeclarationNode` por tipo, sem sítio de mutação e sem limitação. Nós desconhecidos continuam caindo em `Unsupported AST node`.

Fontes conferidas antes da mudança:

- Gramática: `kof/docs/language-reference/classes.md:133-145`, um `enum` contém apenas identificadores.
- Forma do nó nos jars instalados (o checkout do Kof, `22a111f56`, não é a tag 0.7.0): `javap` em `kof-0.7.0` e `kof-0.6.4` mostrou `EnumDeclarationNode(SourcePosition, String name, List<String> modifiers, List<String> constants, List<AnnotationNode> annotations)` nas duas versões, sem campo de expressão.
- Anotações: o KofMut não lê `annotations()` em nenhuma declaração, e valores de anotação são literais ou referências a enum (`AnnotationParser.parseAnnotationValue`). Decisão confirmada pelo usuário em 07/11: `enum` anotado recebe o mesmo tratamento das classes anotadas, sem limitação e sem sítio.

## Resultados por critério

| Critério | Verificação | Observado |
| --- | --- | --- |
| K1 enum puro sem limitação (frontend) | `enumDeclarations` em `src/test/kof/kofmut/FrontendContracts.kf`, por `scanSource`; `./scripts/launch contracts` | RED antes da mudança: falha na asserção `limitations.size == 0` (linha 146). Depois: `PASS frontend: enum declarations are traversed without mutation points` |
| K1 enum puro sem limitação (comando público) | teste "enum declarations complete without limitations or extra mutants" em `Run.kf`, tags `enum` e `check-run-a`: cópia de `fixtures/detected` com `enum Phase { A, B }` depois da classe, `./bin/kof-mut run` | RED com o `Frontend.kf` original (`kof test Run.kf --tag check-run-a`, 437 s): só esse teste falhou, imprimindo `src/math/Calc.kf: Unsupported AST node: dev.kof.compiler.EnumDeclarationNode`; 24 outros passaram. Depois: PASS no check completo |
| K1 enum anotado | mesmo teste de frontend, `@Name("fase")\nenum Phase { A }` | 0 erros, 0 limitações, 0 sítios. A anotação foi confirmada válida antes com `kof check` e `kof run` num arquivo fora do projeto, em 0.7.0 e 0.6.4 |
| K2 sem mutantes extras e IDs preservados | frontend: `Bool less(...) { return a < b } enum Phase { A, B }` compara o sítio inteiro; fluxo: id do mutante | sítio único `<` para `<=`, offset 35, linha 1, coluna 36, comprimento 1 (iguais aos de `binaryTokenLocation`); no fluxo, 1 candidato com id `src/math/Calc.kf:68:-`, o mesmo offset do fixture sem enum (calculado sobre o texto do fixture) |
| K3 nó não suportado continua limitação | testes existentes, sem alteração: `unsupportedForms` (`FrontendContracts.kf:132`) e "unsupported production forms and absent applicable operators stay inconclusive" (`Run.kf:425`) | os dois PASS nos dois checks completos (no final, linhas 16 e 33 de `.agent/tmp/enum/check-070-final.out`) |
| K4 check completo | `PATH=<0.7.0>/bin:$PATH LC_ALL=C.UTF-8 KOF_MUT_COMPATIBILITY_OTHER=<0.6.4>/bin ./scripts/check` | ver "Check final" abaixo |
| K4 enum no 0.6.4 | o check não roda frontend nem fluxo no 0.6.4 (`KOF_MUT_COMPATIBILITY_OTHER` só é lido em `Install.kf`); com `PATH=<0.6.4>/bin:$PATH LC_ALL=C.UTF-8`: `./scripts/launch contracts` e `kof test src/test/kof/kofmut/Run.kf --tag enum` | `kof 0.6.4`; contratos exit 0 com o PASS de enum e de `unsupportedForms`; teste de fluxo `1 passed, 0 failed` (21 s) |
| K5 SiFuture real | `./install.sh`, depois a receita do `check` em `kof-sifuture` `e6703db`: `kof-mut run --project . --files <scope> --config kof-mut.json --report-dir <fora do repositório> --run-id <uuid>` | ver tabela abaixo |
| K6 documentação | `docs/operators.md:59` e `docs/operators.pt_BR.md:59` | acrescentado que declarações `enum`, que contêm apenas nomes de constantes, são percorridas sem candidatos nem limitações (frase corrigida na revisão de 07/11, que antes generalizava para outras declarações); `record` continua como exemplo de sintaxe não percorrida. `README*.md` e `docs/llm-guide*.md` falam de sintaxe não suportada de forma genérica e não precisaram de ajuste |

### K5: SiFuture

Imagem instalada: `0e89fbb3989e76d853f39d54f200a95341db0e49e9398e6ed3f5e5bf1f45d980` (anterior: `b5401898d74f18086fa29ed8f59f55f3e51a84a1608a5b4a23278f6282735d79`). `kofVersion` 0.7.0 e baseline `passed` nas três.

| Escopo | runId | Exit | Status | Candidatos | Mortos | Sobreviventes | `limitations` |
| --- | --- | ---: | --- | ---: | ---: | ---: | --- |
| `game/MenuEntrance.kf` | `dfba7b1a-a154-4b8e-bee7-df26508a6192` | 0 | `complete` | 7 | 7 | 0 | `[]` |
| `game/State.kf` | `ccb615eb-4e1e-4184-893e-9b0ed7772716` | 3 | `no_mutants` | 0 | 0 | 0 | `[]` |
| `game/Item.kf` + `game/Background.kf` | `4c64660b-052f-446e-af90-21d1f5c1f64f` | 1 | `complete` | 40 | 28 | 12 | `[]` |

O exit 3 de `State.kf` é o esperado para um arquivo só com enums (`docs/report-format.md:207`). Os 12 sobreviventes são de `Item.kf`, como no R0; agora a execução é `complete` com exit 1 em vez de `incomplete` com exit 3. O checkout do SiFuture ficou sem alterações.

### Check final

Mesmo comando do K4, rodado duas vezes, com exit 0 nas duas e as nove filas (`version`, `contracts`, `cli-a`, `cli-b`, `run-a`, `run-b`, `install-a`, `install-b`, `install-c`) com exit 0:

| Execução | Árvore | Duração | Observações |
| --- | --- | ---: | --- |
| 1 | mudança e testes, antes da tag `enum`, da documentação e deste registro | 865 s | `.agent/tmp/check-be70a040-d7aa-49b3-82c8-bb62775649a2` |
| 2 (final) | árvore entregue | 759 s | `.agent/tmp/check-3c377e45-61ce-44cf-b36c-8acaabf68cba` |

O teste novo de fluxo rodou na fila `run-a` (`PASS enum declarations complete without limitations or extra mutants`), e a cobertura das filas por arquivo passou.

## Observações e lacunas

- Rodar `kof check` num arquivo dentro de `.agent/tmp/` do KofMut falhou com `COMP001 Error reading source file: /agent`, em 0.7.0 e 0.6.4; o mesmo arquivo fora do projeto passou. Diagnosticado na revisão de 07/11 (C4, abaixo); não afeta a mudança.
- K2 não tem RED próprio: com o frontend original, o caso já falha antes, pela limitação. O que distingue uma implementação que inventasse sítios é a comparação de todos os campos do sítio e do id.
- Nenhuma lacuna aberta nos critérios K1 a K6.

## Revisão de 07/11

A revisão do commit `ffa8f14` aprovou o código e os critérios K1 a K6, mas pediu as correções C1 a C5. `src/main/kof/kofmut/Frontend.kf` não mudou, então a K5 continua valendo para a imagem `0e89fbb3…f45d980`. Início: checkout limpo, `HEAD` = `origin/enum-declarations` = `ffa8f14`, `kof version` = `kof 0.7.0`, 0.6.4 instalado. Evidência local em `.agent/tmp/enum/` (arquivos `c2-*`, `c3-*`, `c4-*`, `review-*`, `kof-comp001-issue.md`).

| Critério | Planejado | Observado |
| --- | --- | --- |
| C1 documentação | trocar a frase que generalizava "declarações sem expressões" por uma frase só sobre `enum` em `docs/operators.md:59`, `docs/operators.pt_BR.md:59` e na linha K6 acima | feito; `grep -rn "without expressions\|sem expressões" docs .agent/validation/enum-declarations.md` sai vazio (exit 1); `grep -n record docs/operators*.md` ainda mostra `record` como sintaxe não percorrida na linha 59 dos dois arquivos; a entrada de `.agent/README.md` já falava só de `enum` |
| C2 `enum` dentro de classe | acrescentar `class Holder { Bool less(...) { return a < b } enum Phase { A, B } }` a `enumDeclarations`, com prova por variante | **não feito; premissa falsa.** Pré-condição falhou: `kof check` e `kof run` rejeitam o `enum` aninhado no parser, com `PARSE016 Unexpected token in class body`, em 0.7.0, 0.6.4, 0.7.1 e 0.7.2 (`c2-nested-parse.out`). No checkout do Kof `78a90a0c3`, `ClassMemberParser.java:139-146` só reconhece `class`/`interface`/`record`/`entity` aninhados, para emitir `SEM042 nested type declaration is not supported`; `enum` nem entra nessa condição e cai em `PARSE016` (`:153`). A chamada a `parseTypeDeclaration` lida no planejamento é recuperação de erro. `grammar.md:94-96` diverge do parser (o número `35-36` do plano veio de uma leitura relativa). Descartada pelo usuário em 09/11: o KofMut nunca recebe `enum` aninhado como código válido; o frontend vê erro de parse, já coberto por `frontendErrors` |
| C3 limitação exata no FAIL | `assert(..., "..." + report.limitations)` | a forma planejada não compila: `PARSE087 assert message must be a string literal (statements.md §9)`. Substituída por `if (report.limitations.size != 0) { throw "enum must not produce limitations: " + report.limitations }`; antes, num teste descartável, a concatenação renderizou a lista como `[a, b]` na linha `FAIL` em 0.7.0 e 0.6.4. RED com o ramo `EnumDeclarationNode` removido (`c3-red-variant.patch`): `FAIL enum declarations complete without limitations or extra mutants: enum must not produce limitations: [src/math/Calc.kf: Unsupported AST node: dev.kof.compiler.EnumDeclarationNode]` em 0.7.0 (39 s) e 0.6.4. Variante revertida (`git diff src/main` vazio). GREEN: `1 passed, 0 failed` em 0.7.0 (15 s) e 0.6.4 (14 s) |
| C4 `COMP001 /agent` | reprodução mínima fora do KofMut e localização da causa | reproduzido e localizado; ver abaixo |
| C5 check completo | check com 0.7.0 e alternativa 0.6.4; contratos no 0.6.4 | ver "Check da revisão" abaixo |

### C4: `COMP001 /agent`

Reprodução mínima fora do KofMut, igual em 0.7.0 e 0.6.4 (`c4-no-toml.out`, `c4-with-toml.out`, `c4-strace-070.out`):

- Falha só com as três condições juntas: um `kof.toml` num diretório ancestral, a fonte num diretório cujo nome começa com ponto (`.agent/tmp/`, `.hidden/`) e um tipo declarado no arquivo (`enum Phase { A }` mais `main`). Mensagem: `Error reading source file: /agent` ou `/hidden`.
- Controles que passam: o mesmo arquivo em `agent/tmp/` e em `x.y/`; um arquivo só com `main() { println("x") }` em `.agent/tmp/` ou `.hidden/`; qualquer caso sem `kof.toml` no ancestral.
- `strace` no 0.7.0: `mkdir("/agent/tmp") = -1 ENOENT` e `mkdir("/agent") = -1 EACCES`. É uma falha de **escrita** na raiz do sistema de arquivos, e não de leitura.

Causa localizada no checkout `78a90a0c3` (não é a tag; `javap` confirma que `ModuleRoots.derivedPackageOf(Path, Path)` existe nos jars 0.7.0 e 0.6.4):

1. `ModuleRoots.derivedPackageOf` (`ModuleRoots.java:35-46`) troca só o separador por ponto, então `.agent/tmp` vira o pacote `.agent.tmp`.
2. O nome interno da classe emitida começa com `/` (`/agent/tmp/Phase`), e `JvmBackend.emitClass` (`JvmBackend.java:161-162`) faz `outputDir.resolve(nome + ".class")`, que devolve o caminho absoluto `/agent/tmp/Phase.class`; `Files.createDirectories` falha.
3. `CompilerPipeline.compileSources` (`CompilerPipeline.java:73-75`) trata todo `IOException` como "Error reading source file".

O passo 2 é inferido da leitura e do `strace`; a conversão do pacote em nome interno não foi rastreada linha a linha. Rascunho de issue em `.agent/tmp/enum/kof-comp001-issue.md`, não publicado. Não afeta esta mudança. A cópia descartável do KofMut fica em `Files.createTempDirectory("kofmut-")` (`RunResources.kf:29`), sem ponto no nome; um projeto avaliado com fontes num diretório com ponto cairia no mesmo erro do Kof, e o KofMut o veria como falha de compilação. Isso não foi exercitado.

### Check da revisão

Comando: `PATH=<0.7.0>/bin:$PATH LC_ALL=C.UTF-8 KOF_MUT_COMPATIBILITY_OTHER=<0.6.4>/bin ./scripts/check`, sempre com a mesma árvore (C1 e C3 aplicadas). Outras sessões estavam usando a máquina nas duas primeiras execuções.

| Execução | Carga (média de 15 min no início) | Duração | Exit | Falhas | Observações |
| --- | ---: | ---: | ---: | --- | --- |
| 1 | cerca de 23 | 1342 s | 1 | 6 testes de tempo e processo, em `run-a`, `run-b`, `cli-a`, `install-b` e `install-c` (sinais INT/TERM, preparação com `preparationMs=32883`, orçamento acima de 90 s, sobrevivência da instalação, cleanup) | `.agent/tmp/check-d81e7c7c-b1f9-482f-b92b-c78a76ee3b16`, `review-check-070.out` |
| 2 | 23,1 | 1186 s | 1 | só `cleanup failure preserves a prior discard survivor and kills with original identities and permits recovery` (`Run.kf:1778`, `run-a`), que também falhou na execução 1 | `.agent/tmp/check-7ccf50cb-f4e4-46ea-9734-8d5f13502d4b`, `review-check-070-rerun.out` |
| 3 (final) | 15,5 (1 min: 1,18) | 805 s | 0 | nenhuma; as nove filas com exit 0 | `.agent/tmp/check-91635139-b23d-4804-b9eb-699e9b0c587a`, `review-check-070-quiet.out` |

Para separar regressão de sensibilidade à carga, o teste de `Run.kf:1778` rodou isolado com `kof test src/test/kof/kofmut/Run.kf --tag budget` (11 testes), na árvore da revisão e em `ffa8f14` (via `git stash`): passou nas duas, em 3m18s e 3m17s (`review-budget-tree.out`, `review-budget-head.out`). O teste tem limites de relógio (`waitFor(15000)`, `durationMs < 8000`, `waitFor(8500)`) e a revisão não toca nele nem em `src/main`. Conclusão: sensível à carga, não é regressão. É uma fragilidade preexistente, fora do escopo desta revisão.

Na execução 3: `PASS frontend: enum declarations are traversed without mutation points`, `PASS frontend: unsupported AST forms produce explicit limitations`, `PASS enum declarations complete without limitations or extra mutants` e `PASS unsupported production forms and absent applicable operators stay inconclusive`.

0.6.4 (`PATH=<0.6.4>/bin:$PATH LC_ALL=C.UTF-8 ./scripts/launch contracts`, `review-contracts-064.out`): `kof 0.6.4`, exit 0, com o PASS de `enumDeclarations` e de `unsupportedForms`. O teste de fluxo com a tag `enum` no 0.6.4 está na linha C3 (`1 passed, 0 failed`).

### Lacunas da revisão

- C2 descartada pelo usuário em 09/11 por premissa falsa: os parsers instalados rejeitam `enum` aninhado, então não há lacuna aberta.
- A forma da asserção da C3 diverge do plano (`throw` em vez de `assert` com mensagem dinâmica), por restrição da linguagem (`PARSE087`).
- O teste de `Run.kf:1778` é sensível à carga da máquina; não foi corrigido.

Dois rascunhos de issue do Kof, não publicados, em `.agent/tmp/enum/`: `kof-comp001-issue.md` (C4) e `kof-nested-type-grammar-issue.md` (C2: o EBNF de `class-member` em `grammar.md:94-96` permite tipo aninhado, mas o parser rejeita; `enum` aninhado dá `PARSE016`, e `class` aninhada dá `SEM042`, como `classes.md:255` documenta, seguido de erros em cascata). O caso de `class` aninhada rodou em `/tmp`, fora de diretórios com ponto, com o mesmo resultado em 0.7.0 e 0.6.4 (`nested-class-parse.out`); o de `enum` reaproveita `c2-nested-parse.out`.
