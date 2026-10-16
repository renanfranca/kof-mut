[English](README.md) | [Português](README.pt_BR.md)

# KofMut

KofMut é uma ferramenta de teste de mutação em desenvolvimento para Kof. A lógica de seleção, transformação, execução de processos e relatório pertence ao código Kof, com execução inicial na JVM em Linux.

**Estado de desenvolvimento: marcos M1 e M1R implementados.** Estão disponíveis o lançador de fonte em Kof, a leitura de arquivos e a integração com o frontend oficial. Execuções de mutação, configuração do projeto, sandboxes e relatório JSON versão 1 estão pendentes. O valor `0.1.0` identifica este fonte em desenvolvimento; não significa que o produto planejado esteja concluído.

## Requisitos

- Linux com Bash 4.4 ou posterior e utilitários GNU usuais (`dirname`, `readlink`, `mktemp` e `rm`).
- Distribuição Linux oficial do **Kof 0.6.4** no `PATH`, incluindo `lib/kof.jar` e seu JDK embutido.
- Permissão de escrita no checkout para o diretório local `build/cache/`.

Kof 0.6.5 e outras versões são rejeitados até que seus contratos de frontend sejam verificados. O lançador descobre a instalação por `kof info --json`; ele não baixa nem atualiza Kof.

Se outra versão estiver selecionada na máquina, coloque a instalação suportada primeiro no `PATH`:

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

O comando de versão imprime `KofMut 0.1.0`, lendo `VERSION`. Versão e ajuda retornam código 0. Comandos não suportados, incluindo `run` nesta etapa, retornam 2. Um comando de versão ou ajuda não representa avaliação de qualidade.

O bootstrap Kof em `scripts/bootstrap/Launch.kf` valida a ferramenta, gerencia o cache de compilação e prepara o comando da JVM. Ele usa as APIs Kof de JSON e processos, além de APIs JDK para hashes, bloqueios de arquivo e publicação atômica de diretório. A pequena ponte Bash fixa o executável Kof, recebe um comando identificado por `kofmut-launch-v1` com campos separados por NUL e usa `exec` para iniciar `Default.Main` com os argumentos originais da aplicação, diretório de trabalho e ambiente. Python não é necessário.

O bootstrap executa por `kof run` a cada chamada. A aplicação e os contratos do frontend compilam com `kof build --target jvm --classpath` e usam `build/cache/kof-bootstrap-v1/`. As chaves do cache incluem modo, caminhos resolvidos e informações da ferramenta, conteúdo do jar do compilador, lançadores, manifesto, versão e conteúdo dos fontes. Um bloqueio serializa a compilação, e o build completo é publicado atomicamente após o compilador terminar com sucesso. Builds com falha ou interrompidos não podem virar entradas utilizáveis do cache. Remover `build/cache/` força a recompilação; entradas do antigo lançador Python são ignoradas.

## O que M1 comprova

As verificações de comportamento exercitam o lexer e o parser reais do Kof 0.6.4. Elas verificam leitura de arquivo, associação exata de uma expressão `<` ao token do lexer, percurso de funções, métodos, construtores, inicializadores de campos e lambdas, operadores repetidos e aninhados, e exclusão de símbolos em strings, comentários e parâmetros genéricos. As localizações usam linha e coluna começando em 1 e **offsets de String UTF-16 da JVM**, em vez de offsets de bytes UTF-8.

Diagnósticos do lexer e do parser impedem a geração de candidatos. Formas da AST não suportadas são informadas explicitamente. Este marco comprova a seleção de `<` para `<=`; os demais operadores e o percurso completo estão pendentes no M2. Ele ainda não compila nem executa mutantes e não avalia a qualidade dos testes.

`./scripts/check` executa testes Kof nomeados do CLI por `kof test`, depois compila e executa um programa Kof de contrato com `assert` e o frontend oficial no classpath. O `kof test` instalado não aceita `--classpath`, portanto a prova do frontend usa o estilo documentado de programa completo com asserções. Ela não introduz um framework de testes. Os projetos avaliados pelo futuro mutador usarão seus comandos configurados de `kof check --json` e `kof test`.

As verificações do lançador usam cópias descartáveis dos fontes e utilitários Linux usuais: GNU coreutils, `which`, `ps` e `setsid`. Elas cobrem PATH sem Python, preservação de argumentos, invalidação do cache, rejeição da ferramenta, compilação concorrente e recuperação após builds com falha ou interrompidos. O encerramento de grupos de processos nessas verificações comprova a recuperação do bootstrap; os limites de processos das futuras execuções de mutação continuam no M3.

## Próximos marcos

M2 adiciona o ciclo de mutação, cópias explícitas dos inputs e todas as famílias de operadores planejadas. M3 adiciona limites de processo, encerramento de descendentes, relatórios e aceitação externa. M4 conclui os guias do CLI, operadores e relatório em inglês e português. Veja [o plano de execução](EXECPLAN.md), [a validação do lançador M1R](.agent/validation/kofmut-m1r.md) e [a evidência histórica do M1](.agent/validation/kofmut-v0.1.0.md).

## Licença

KofMut usa **GPL-3.0-only**. Veja [LICENSE](LICENSE) e [NOTICE](NOTICE). O jar do Kof e seu JDK embutido permanecem na instalação do usuário e não são incluídos neste checkout de fonte.
