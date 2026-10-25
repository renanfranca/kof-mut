[English](usage.md) | [Português](usage.pt_BR.md) | [KofMut](../README.pt_BR.md)

# Primeira avaliação e uso diário

Este tutorial cria um projeto sintético completo em diretório descartável. Funciona com o KofMut instalado e dispensa fixtures e checkout. Para o vocabulário e o ciclo ordenado da avaliação, leia [conceitos](operators.pt_BR.md); opções e configuração exatas pertencem à [referência CLI](cli.pt_BR.md).

## Escolher o comando

Atenda aos [requisitos](../README.pt_BR.md#requisitos) e selecione o Kof oficial no `PATH`. Para a aplicação instalada, defina:

```bash
KOFMUT_BIN="$(command -v kof-mut)"
kof info --json
"$KOFMUT_BIN" --version
```

Para executar por fonte, defina `KOFMUT_BIN` com o caminho absoluto de `bin/kof-mut` no checkout, por exemplo `KOFMUT_BIN="/absolute/path/to/kof-mut/bin/kof-mut"`. Somente instalação, comandos por fonte e os exemplos adicionais de fixtures abaixo exigem checkout. [Instale o KofMut](installation.pt_BR.md) se o comando estiver indisponível.

## Criar todos os arquivos do projeto

Execute em Bash a partir de qualquer diretório de trabalho gravável. Os cinco arquivos abaixo são baseados em `fixtures/detected` do checkout; não é necessário copiar a fixture. `kof.toml` permite que o teste resolva `src.math.Calc`. A configuração do KofMut declara os dois comandos, todos os inputs copiados e os diretórios de produção e testes. `scope.json` seleciona exatamente um arquivo de produção.

```bash
demo="$(mktemp -d)"
mkdir -p "$demo/src/math" "$demo/tests"
cat > "$demo/kof.toml" <<'EOF'
[sources]
app = "."
test = "tests"
EOF
cat > "$demo/src/math/Calc.kf" <<'EOF'
package src.math

class Calc {
    Int sum(Int a, Int b) { return a + b }
}
EOF
cat > "$demo/tests/Suite.kf" <<'EOF'
import src.math.Calc

test "sum contract" {
    assert(new Calc().sum(2, 3) == 5)
}
EOF
cat > "$demo/kof-mut.json" <<'EOF'
{
  "schemaVersion": 1,
  "sourceRoots": ["src"],
  "testRoots": ["tests"],
  "inputs": ["kof.toml", "src", "tests"],
  "checkCommand": ["kof", "check", "src/math/Calc.kf", "--json"],
  "testCommand": ["kof", "test", "tests"],
  "commandTimeoutMs": 10000,
  "budgetMs": 90000
}
EOF
cat > "$demo/scope.json" <<'EOF'
["src/math/Calc.kf"]
EOF
(cd "$demo" && sha256sum kof.toml kof-mut.json scope.json src/math/Calc.kf tests/Suite.kf > originals.sha256)
```

Mantenha o diretório criado na variável `demo` para as próximas etapas. O arquivo de checksums permite confirmar que a avaliação preservou os cinco arquivos originais.

## Verificar o projeto intacto

```bash
(cd "$demo" && kof check src/math/Calc.kf --json && kof test tests)
```

Os dois comandos devem retornar 0. O check deve fornecer aprovação JSON válida e os testes devem executar um caso aprovado. Corrija falhas do original antes de avaliar os testes com o KofMut. A ferramenta executará sua própria baseline em uma cópia mesmo após essa verificação manual.

## Avaliar e guardar evidências

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

A condicional preserva o exit diferente de zero mesmo em shell com `set -e`. Guarde comando, stdout, stderr e exit juntos no diretório exclusivo indicado por `run_dir`; repetir o exemplo cria outro diretório e preserva as evidências anteriores. A preparação inicial de compatibilidade pode imprimir progresso em stderr; tem prazo separado e não tem duração esperada fixa. Veja [preparação e recuperação](installation.pt_BR.md#preparar-o-kof-selecionado).

Espere exit `0`, todas as verificações de checksum `OK` e uma linha de descoberta em stdout `reportPath=<string JSON>`. Decodifique o texto após `reportPath=` com um parser JSON, aguarde o processo terminar e abra somente aquele arquivo final exato. Não remova apenas as aspas, não escolha o arquivo mais recente nem reutilize outra execução. O anúncio sozinho não é relatório. Siga o [contrato completo de descoberta e validação](report-format.pt_BR.md#descobrir-o-relatório-atual).

O relatório atual deve conter `schemaVersion: 1`, seu `runId`, `scope: ["src/math/Calc.kf"]`, a `kofVersion` efetiva, baseline `passed` com um teste executado, `status: "complete"`, um `Killed`, nenhum sobrevivente, nenhum candidato descartado e nenhuma limitação. A expressão alterada é `a - b`; o teste original detecta a mudança do resultado. Isso valida a mutação selecionada no exemplo, não todos os comportamentos possíveis nem todos os testes de outro projeto.

## Aplicar ao seu projeto

1. Identifique os comandos reais de check e teste e confira se a evidência segue os [protocolos suportados](cli.pt_BR.md#configurar-um-projeto). Exit 0 sozinho é insuficiente.
2. Declare em `inputs` os arquivos, imports, scripts e manifestos necessários. Selecione caminhos explícitos de produção em um array JSON; inclua fontes novos ou não rastreados quando solicitados. A seleção não consulta o Git e avalia arquivos selecionados inteiros. Veja [escopo e inputs](cli.pt_BR.md#selecionar-escopo-e-inputs).
3. Mantenha os testes fora do escopo de produção selecionado. A ferramenta copia os testes sem mutação. Cópias de arquivos não isolam bancos externos, portas fixas ou caminhos absolutos usados pelos comandos.
4. Escolha raiz segura para relatórios, ID de execução novo e limites adequados. [Timeouts e cancelamento](cli.pt_BR.md#timeouts-e-cancelamento) explica o limite positivo por comando, `budgetMs` global (zero desativa somente esse orçamento global), INT/TERM e resultados inconclusivos. Limites paralelos de 1 a 4 se aplicam após a baseline única; use 1 para recursos externos compartilhados.
5. Capture cada chamada como acima e valide seu próprio relatório final contra a [referência JSON](report-format.pt_BR.md). Preserve relatórios e logs locais referenciados juntos para revisão.

## Interpretar e dar continuidade

`complete/0` significa que todas as mutações aplicáveis no escopo avaliado foram detectadas. `complete/1` é avaliação concluída com sobreviventes e reprova a validação de qualidade. Inspecione a expressão original, substituição, localização, testes relevantes e comportamento esperado de cada sobrevivente. Adicione teste significativo somente quando distinguir um requisito observável; depois execute os checks reais do projeto e uma nova avaliação. Sobrevivência sozinha não comprova equivalência nem ausência de cobertura. Veja [possíveis equivalentes](operators.pt_BR.md#possíveis-equivalentes).

Descartes nunca contam como detecções. `no_scope/3` e `no_mutants/3` não aprovam testes. Timeouts, trabalho pendente, evidência inválida, sintaxe não suportada e erros da ferramenta permanecem explícitos; informe esses casos pelas [regras de estados e exits](report-format.pt_BR.md#estado-geral-e-exit-do-processo). Evidência atual ausente ou contraditória não estabelece resultado. O [guia para LLMs](llm-guide.pt_BR.md) oferece um procedimento de decisão baseado em evidências também útil para automação.

## Exemplos adicionais do checkout

Estes comandos exigem a raiz do checkout do fonte; seus projetos não acompanham o pacote instalado. Execute cada um separadamente e guarde cada exit, inclusive valores diferentes de zero:

```bash
./bin/kof-mut run --project fixtures/detected \
  --files fixtures/detected/scope.json --report-dir .agent/tmp/reports
./bin/kof-mut run --project fixtures/survived \
  --files fixtures/survived/scope.json --report-dir .agent/tmp/reports
./bin/kof-mut run --project fixtures/invalid \
  --files fixtures/invalid/scope.json --report-dir .agent/tmp/reports
./bin/kof-mut run --project fixtures/equivalent \
  --files fixtures/equivalent/scope.json --report-dir .agent/tmp/reports
```

Exits esperados: `0/1/3/1`: uma alteração aritmética detectada; um sobrevivente aritmético; um descarte coerente do check (`ARITH001`) com `no_mutants` e nenhuma detecção; um sobrevivente equivalente de limite. Os quatro têm baseline aprovada. Cada comando anuncia seu próprio relatório. O projeto completo acima é o equivalente instalado do primeiro exemplo.
