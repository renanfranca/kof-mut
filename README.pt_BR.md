[English](README.md) | [Português](README.pt_BR.md)

# KofMut

O KofMut avalia testes Kof alterando um token de produção por vez em cópias descartáveis e executando os comandos de check e teste do projeto. Os arquivos originais de produção e testes são preservados. Seleção, mutação, execução e relatório são escritos em Kof e usam lexer e parser oficiais em Linux/JVM.

**Versão `0.1.0`.** Execute por fonte ou instale localmente para uso diário. Comece pelo [tutorial de uso para pessoas](docs/usage.pt_BR.md) ou pelo [guia operacional para LLMs](docs/llm-guide.pt_BR.md). Ambos funcionam com o pacote instalado.

| Quero… | Leitura |
| --- | --- |
| Concluir a primeira avaliação e usar meu projeto | [Uso: projeto mínimo completo](docs/usage.pt_BR.md) |
| Instalar, atualizar, selecionar outro Kof, reparar ou desinstalar | [Procedimentos de instalação](docs/installation.pt_BR.md) |
| Usar uma LLM ou automatizar decisões baseadas em evidências | [Guia para LLMs](docs/llm-guide.pt_BR.md) |
| Entender o ciclo da avaliação e as alterações suportadas | [Conceitos e operadores](docs/operators.pt_BR.md) |
| Consultar comandos, configuração, caminhos, limites ou recuperação | [Referência CLI](docs/cli.pt_BR.md) |
| Descobrir e validar resultados e exits do processo | [Referência JSON v1](docs/report-format.pt_BR.md) |

## Requisitos

- Linux, Bash 4.4 ou posterior e a distribuição Linux oficial do **Kof** no `PATH`, incluindo `lib/kof.jar` e seu JDK embutido.
- GNU coreutils (`dirname`, `readlink`, `mktemp`, `mkfifo`, `mkdir`, `rmdir`, `rm`, `cat`, `sort`, `sha256sum`, `b2sum`, `date`, `timeout`, `cp`), GNU findutils (`find`) e GNU diffutils (`cmp`).
- `setsid` e `flock` de util-linux, o comando externo `kill` e procfs em `/proc`. O lançador oficial do Kof também usa `sed` e `head`; a validação usa `ps`, `cp`, `ln`, `env` e `which`.
- Checkout gravável para compilação e execução por fonte (`build/cache/` e `.agent/tmp/`), prefixo de instalação gravável e espaço temporário para cópias descartáveis dos projetos. Avaliações instaladas gravam logs no estado e dispensam o checkout.

Python não é necessário para o KofMut nem para sua suíte de validação. Os comandos do projeto podem ter suas próprias dependências. Cada instalação selecionada no PATH precisa passar pela preparação de compatibilidade antes da avaliação. O KofMut não baixa nem atualiza o Kof. Se necessário, selecione uma instalação existente:

```bash
export PATH="/path/to/selected-kof/bin:$PATH"
kof info --json
```

## Instalação para uso diário

Em um checkout gravável do fonte, com o Kof selecionado no PATH:

```bash
./install.sh
export PATH="$HOME/.local/bin:$PATH"
kof-mut --version
kof-mut --help
```

O prefixo padrão é `$HOME/.local`, sem `sudo` nem edição dos perfis do shell. A aplicação inclui estes guias públicos e fontes de runtime; avaliações dispensam o checkout. Leia [instalação](docs/installation.pt_BR.md) para prefixos personalizados, localização dos documentos, atualizações, preparação de compatibilidade e recuperação.

## Executar a partir do fonte

Na raiz do checkout:

```bash
./bin/kof-mut --version
./bin/kof-mut --help
```

Use `./bin/kof-mut` no lugar de `kof-mut` instalado. Versão e ajuda retornam 0 sem avaliar a qualidade dos testes. A execução por fonte exige checkout gravável. Veja [lançador e cache](docs/cli.pt_BR.md#lançador-e-cache) para detalhes da preparação.

## Executar uma avaliação

Crie os cinco arquivos do [tutorial de projeto mínimo](docs/usage.pt_BR.md#criar-todos-os-arquivos-do-projeto), utilizável sem fixtures do checkout. Depois avalie esse projeto configurado:

```bash
kof-mut run --project "my-project" --files "my-project/scope.json"
```

`my-project` representa o diretório do seu projeto, não um exemplo distribuído. O tutorial fornece a criação executável, captura stdout/stderr/exit e confere a preservação dos originais. O resultado esperado é baseline aprovada, um `Killed`, `complete/0`. Os [quatro exemplos do checkout](docs/usage.pt_BR.md#exemplos-adicionais-do-checkout) também demonstram sobrevivência, descarte e equivalência com exits `0/1/3/1`.

## Operadores e evidência

Uma mutação é uma alteração deliberada em um único token de produção. Leia [conceitos e seleção](docs/operators.pt_BR.md) para o ciclo ordenado, cinco famílias de operadores, catorze direções de substituição e limitações. Cópias isolam arquivos do projeto; serviços externos e caminhos absolutos usados pelos comandos podem continuar compartilhados. O paralelismo é opcional, de um a quatro mutantes após uma baseline única.

Uma alteração `Survived` exige análise; sozinha não comprova equivalência nem ausência de cobertura. Um candidato descartado não é detecção por testes. Não há instrumentação de cobertura, estado `NoCoverage`, diagnóstico automático de equivalência, supressão ou percentual de aprovação. [Possíveis equivalentes](docs/operators.pt_BR.md#possíveis-equivalentes) explica a investigação dos sobreviventes.

## Relatório JSON v1 e saídas

Uma execução reservada anuncia `reportPath=<string JSON>`. Decodifique o valor com parser JSON, aguarde o término e leia somente aquele relatório final exato. O anúncio é uma reserva; a publicação pode falhar. Nunca use um relatório anterior ou o mais recente como substituto.

A [referência JSON](docs/report-format.pt_BR.md) concentra todos os campos, estados, contagens e exits. `complete/0` significa que todos os mutantes aplicáveis no escopo foram detectados; `complete/1` significa conclusão com sobreviventes e reprova a validação de qualidade. Erros usam 2; inconclusão, ausência de escopo e de mutantes aplicáveis usam 3. Evidência atual ausente ou contraditória não aprova testes. O [guia para LLMs](docs/llm-guide.pt_BR.md) transforma essas regras em procedimento operacional.

## Validação e próximos marcos

No checkout do fonte, `./scripts/check` executa contratos do lançador, testes do ciclo de mutação, jornadas de instalação e asserções do frontend contra o Kof instalado selecionado. Para seu projeto avaliado, use os comandos reais configurados e inspecione seu próprio relatório atual. [Uso](docs/usage.pt_BR.md#interpretar-e-dar-continuidade) cobre a continuidade; [CLI](docs/cli.pt_BR.md#timeouts-e-cancelamento) cobre limites e cancelamento.

Sintaxe não suportada, evidência inválida, timeouts e falhas de limpeza permanecem limitações explícitas ou resultados inconclusivos/erros. A aprovação de compatibilidade se aplica aos conteúdos verificados, sem lista literal de versões nem garantia universal de latência. A integração de sensores permanece futura.

## Licença

O KofMut usa **GPL-3.0-only**. Veja [LICENSE](LICENSE) e [NOTICE](NOTICE). O jar do Kof e o JDK embutido permanecem na instalação do usuário e não são incluídos neste checkout de fonte.
