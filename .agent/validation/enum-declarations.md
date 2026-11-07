# Declarações `enum` sem limitação

Data: 2026-11-07 (UTC). Branch `enum-declarations` a partir de `main` `77dfa58` (igual a `origin/main`), checkout limpo no início. Kof 0.7.0 primeiro no PATH; Kof 0.6.4 como alternativa. Evidência local em `.agent/tmp/enum/` (não versionada).

## Problema

Uma execução do KofMut sobre toda a produção do SiFuture (`kof-sifuture/.agent/validation/sensor-debt-payoff.md`, seção "KofMut sobre toda a produção", commit `e6703db`) gerou 8 limitações `Unsupported AST node: dev.kof.compiler.EnumDeclarationNode`. Qualquer limitação torna a execução `incomplete` com exit 3 (`src/main/kof/kofmut/Run.kf:116`), então um arquivo com `enum` nunca chegava a `complete`.

## Mudança

`src/main/kof/kofmut/Frontend.kf` passa a tratar `EnumDeclarationNode` por tipo, sem sítio de mutação e sem limitação. Nós desconhecidos continuam caindo em `Unsupported AST node`.

Fontes conferidas antes da mudança:

- Gramática: `kof/docs/language-reference/classes.md:133-145`, um `enum` contém apenas identificadores.
- Forma do nó nos jars instalados (o checkout do Kof, `22a111f56`, não é a tag 0.7.0): `javap` em `kof-0.7.0` e `kof-0.6.4` mostrou `EnumDeclarationNode(SourcePosition, String name, List<String> modifiers, List<String> constants, List<AnnotationNode> annotations)` nas duas versões, sem expressões.
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
| K6 documentação | `docs/operators.md:59` e `docs/operators.pt_BR.md:59` | acrescentado que declarações sem expressões, como listas de constantes de `enum`, são percorridas sem candidatos nem limitações; `record` continua como exemplo de sintaxe não percorrida. `README*.md` e `docs/llm-guide*.md` falam de sintaxe não suportada de forma genérica e não precisaram de ajuste |

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

- Rodar `kof check` num arquivo dentro de `.agent/tmp/` do KofMut falhou com `COMP001 Error reading source file: /agent`, em 0.7.0 e 0.6.4; o mesmo arquivo fora do projeto passou. Não investigado; não afeta a mudança.
- K2 não tem RED próprio: com o frontend original, o caso já falha antes, pela limitação. O que distingue uma implementação que inventasse sítios é a comparação de todos os campos do sítio e do id.
- Nenhuma lacuna aberta nos critérios K1 a K6.
