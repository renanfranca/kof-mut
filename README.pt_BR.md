[English](README.md) | [Português](README.pt_BR.md)

# KofMut

O KofMut avalia testes Kof alterando um token de produção por vez em cópias descartáveis e executando os comandos de check e teste do projeto. Seleção, transformação, execução e relatório são escritos em Kof e executam em Linux/JVM com o frontend oficial do Kof.

**Fonte em desenvolvimento, versão `0.1.0`.** O ciclo de mutação, os relatórios independentes, o cancelamento, a recuperação e a avaliação opcional de até quatro mutantes estão implementados. Esta entrega oferece fonte e guias públicos; não inclui instalador binário. A integração dos sensores é trabalho futuro.

## Requisitos

- Linux, Bash 4.4 ou posterior e a distribuição Linux oficial **Kof 0.6.4** no `PATH`, incluindo `lib/kof.jar` e seu JDK embutido.
- GNU coreutils (`dirname`, `readlink`, `mktemp`, `mkdir`, `rmdir`, `rm`, `cat`, `sort`, `sha256sum`, `b2sum`), GNU findutils (`find`) e GNU diffutils (`cmp`).
- `setsid` de util-linux, o comando externo `kill` e procfs em `/proc`. O lançador oficial do Kof também usa `sed` e `head`; a validação usa `ps`, `cp`, `ln`, `env` e `which`.
- Checkout gravável para `build/cache/` e `.agent/tmp/`, além de espaço temporário para cópias descartáveis dos projetos.

Python não é necessário para o KofMut nem para sua suíte de validação. Os comandos do projeto podem ter suas próprias dependências. Outras versões do Kof são recusadas até a verificação dos contratos do frontend. Se necessário, selecione sua instalação compatível existente:

```bash
export PATH="/path/to/kof-0.6.4-linux-x86_64/bin:$PATH"
kof info --json
```

## Executar a partir do fonte

Na raiz do checkout:

```bash
./bin/kof-mut --version
./bin/kof-mut --help
./scripts/check
```

A versão imprime `KofMut 0.1.0`; versão e ajuda retornam 0. A primeira chamada prepara uma imagem compilada local. As seguintes validam e reutilizam essa imagem. Caminhos do checkout com espaços funcionam; coloque argumentos de caminho entre aspas. Veja [CLI e recuperação do cache](docs/cli.pt_BR.md#lançador-e-cache) para preparação, dependências e recuperação.

## Executar uma avaliação

Estes exemplos sintéticos estão prontos para executar na raiz do checkout com Kof 0.6.4 no `PATH`:

```bash
./bin/kof-mut run --project fixtures/detected \
  --files fixtures/detected/scope.json --report-dir .agent/tmp/reports
# exit 0: complete, um Killed

./bin/kof-mut run --project fixtures/survived \
  --files fixtures/survived/scope.json --report-dir .agent/tmp/reports
# exit 1: complete, um Survived

./bin/kof-mut run --project fixtures/invalid \
  --files fixtures/invalid/scope.json --report-dir .agent/tmp/reports
# exit 3: no_mutants, um candidato descartado com ARITH001, nenhum Killed

./bin/kof-mut run --project fixtures/equivalent \
  --files fixtures/equivalent/scope.json --report-dir .agent/tmp/reports
# exit 1: complete, uma mutação de limite equivalente sobrevive
```

Cada execução primeiro faz check e testa o snapshot intacto. Uma mutação `Killed` mudou um comportamento detectado pelos testes. Uma mutação `Survived` passou nesses testes e exige análise humana. Candidato rejeitado é descarte, nunca detecção pelos testes. `complete/1` significa avaliação concluída com sobreviventes e reprova a validação de qualidade. `no_mutants/3` não aprova a qualidade dos testes.

Para seu projeto, comece por [configuração e escopo no CLI](docs/cli.pt_BR.md#configurar-um-projeto). O guia explica `--project`, `--files`, `--config`, `--report-dir`, `--run-id`, cópias dos inputs, timeouts e `maxParallelMutants`. A flag removida `--report` retorna 2; siga as [instruções de migração](docs/cli.pt_BR.md#migrar-de---report).

## Operadores e evidência

Leia [o guia de operadores](docs/operators.pt_BR.md) para definições, as cinco famílias e catorze substituições, exclusões e sintaxe não suportada. O KofMut usa lexer e parser oficiais; preserva os arquivos de produção e os testes originais. Consome a evidência oficial de check/teste sem fornecer outro executor de testes.

Não há instrumentação de cobertura, estado `NoCoverage`, diagnóstico automático de equivalência, supressão ou percentual de aprovação. A fixture equivalente demonstra por que uma alteração sobrevivente pode preservar o comportamento. Veja [possíveis equivalentes](docs/operators.pt_BR.md#possíveis-equivalentes).

## Relatório JSON v1 e saídas

Cada execução reservada anuncia `reportPath=<string JSON>` para seu próprio destino de JSON final. Decodifique essa string com um parser JSON e aguarde o término da chamada. A reserva não comprova publicação; nunca procure o relatório mais recente nem reutilize um resultado anterior.

A [referência JSON v1](docs/report-format.pt_BR.md) concentra descoberta, todos os campos e nulls, regras de estados/contagens, localizações UTF-16 e relação com exits. Exit 0 significa conclusão com todos os mutantes aplicáveis detectados; 1, conclusão com sobreviventes; 2, erro ou baseline reprovada; 3, inconclusão, ausência de escopo ou de mutantes aplicáveis. Exit 0 de ajuda/versão não é avaliação de qualidade.

## Validação e próximos marcos

`./scripts/check` executa contratos do lançador, testes Kof do ciclo de mutação e asserções do frontend contra o jar instalado. Veja [evidência de aceitação M4](.agent/validation/kofmut-m4.md) e [plano de execução](EXECPLAN.md) para a entrega revisada do fonte e as pendências.

O M3F histórico avaliou `Background.kf` + `Meteor.kf` no SiFuture revisão `82111142c85f98b970ccd65fbf044e492d017729` com `commandTimeoutMs: 10000`, `budgetMs: 0` e `maxParallelMutants: 4`, sem prazo externo. A chamada completa levou **96.456 segundos**: `complete/1`, 42 candidatos avaliados, 29 `Killed`, 13 `Survived`, nenhum descarte ou resultado inconclusivo e 114 casos na baseline. É uma observação histórica de execução completa; a qualidade foi reprovada pelos sobreviventes. Não diagnostica equivalência ou cobertura nem promete latência. A meta histórica de desempenho de 90 segundos permanece **adiada e não atingida**; sensores e sua aceitação S1–S3 continuam pendentes.

O [relatório histórico M3P/M3F](.agent/validation/kofmut-m3p.md#preservation-incident-during-the-first-focused-run) também registra a perda de cópias históricas avulsas JSON/stdout e a reutilização de arquivos de observação cujos bytes originais não foram recuperados. O relatório distingue as evidências independentes remanescentes e os registros de desempenho. Veja [observações por candidato](.agent/validation/kofmut-m3f-candidates.tsv), [M3](.agent/validation/kofmut-m3.md), [M2](.agent/validation/kofmut-m2.md), [M1R](.agent/validation/kofmut-m1r.md) e [M1P](.agent/validation/kofmut-m1p.md) para resultados datados e seus limites.

## Licença

O KofMut usa **GPL-3.0-only**. Veja [LICENSE](LICENSE) e [NOTICE](NOTICE). O jar do Kof e o JDK embutido permanecem na instalação do usuário e não são incluídos neste checkout de fonte.
