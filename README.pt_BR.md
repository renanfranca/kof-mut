[English](README.md) | [Português](README.pt_BR.md)

# KofMut

KofMut é uma ferramenta de teste de mutação em desenvolvimento para Kof. A lógica de seleção, transformação, execução de processos e relatório pertence ao código Kof, com execução inicial na JVM em Linux.

**Estado de desenvolvimento: marcos M1, M1R e M1P implementados.** Estão disponíveis o lançador de fonte em Kof, a leitura de arquivos e a integração com o frontend oficial. Execuções de mutação, configuração do projeto, sandboxes e relatório JSON versão 1 estão pendentes. O valor `0.1.0` identifica este fonte em desenvolvimento; não significa que o produto planejado esteja concluído.

## Requisitos

- Linux com Bash 4.4 ou posterior e GNU coreutils (`dirname`, `readlink`, `mktemp`, `rm`, `cat`, `sort`, `sha256sum` e `b2sum`), GNU findutils (`find`) e `cmp` do GNU diffutils.
- Distribuição Linux oficial do **Kof 0.6.4** no `PATH`, incluindo `lib/kof.jar` e seu JDK embutido.
- Permissão de escrita no checkout para o diretório local `build/cache/`.

Kof 0.6.5 e outras versões são rejeitados até que seus contratos de frontend sejam verificados. O lançador oficial do Kof também exige `sed` e `head`. O lançador descobre a instalação por `kof info --json`; ele não baixa nem atualiza Kof.

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

A ponte Bash fixa o executável Kof por caminho real e obtém `info --json` fresco em cada chamada. Com cache quente, calcula os hashes dos inputs do lançador e do jar instalado inteiro, depois usa `exec` para iniciar `kofmut.launch.RuntimeEntry` compilado. Essa entrada Kof valida a evidência fresca da instalação, os caminhos e a identidade da imagem, remove seu contexto temporário, configura as propriedades da aplicação e chama `Default.Main.main` na mesma JVM. Versão, ajuda e demais comandos usam esse caminho. Argumentos, diretório de trabalho, ambiente, códigos de saída e sinais chegam diretamente à aplicação. Python não é necessário. O script oficial Kof 0.6.4 inicia também uma sondagem curta `java -version` antes da consulta da instalação: são duas JVMs de trabalho mais essa sondagem, e as medições de inicialização incluem as três execuções Java.

`scripts/bootstrap/Launch.kf` executa por `kof run` somente quando é necessário preparar o cache. Ele valida a instalação, confere os hashes dos inputs capturados, compila os bytes capturados dos fontes com `kof build --target jvm --classpath` e publica a imagem completa atomicamente sob bloqueio de arquivo. As duas entradas JVM e o runtime JSON gerado especificamente para a aplicação são compilados juntos. A imagem publicada inclui hashes SHA-256 das classes geradas; o lançador confere esses hashes antes da execução. Uma nova consulta ao cache sob bloqueio impede compilação duplicada. Falhas de validação e compilação retornam 2 sem executar uma imagem antiga como alternativa.

O cache usa `build/cache/kof-launch-v2/locations/` para descritores da instalação e `build/cache/kof-launch-v2/images/` para programas compilados. A identidade preliminar SHA-256 inclui modo, raiz do checkout, caminho e conteúdo do Kof fixado, JSON bruto fresco, lançadores, VERSION, manifesto e conteúdos dos fontes pertinentes, em ordem determinística com campos terminados por NUL. A identidade final SHA-256 inclui também o hash BLAKE2b de 512 bits do jar instalado inteiro, calculado pelo GNU `b2sum`. Os timestamps não determinam a validade. Alterações em um futuro projeto avaliado não recompilam o KofMut.

A entrega anterior `kofmut-launch-v1` foi substituída por `kofmut-location-v1`, cujos campos terminados por NUL carregam os caminhos validados de Java e jar. Bash lê esses campos sem interpretar JSON nem avaliar texto de comandos. Cada chamada passa cinco argumentos internos (raiz, Kof fixado, modo, diretório do contexto e diretório da imagem), seguidos dos argumentos originais da aplicação. Nenhum argumento da aplicação passa pelo parser de opções de `kof run`. Entradas dos caches Python e `kof-bootstrap-v1` são ignoradas.

Descritores ausentes ou inconsistentes e imagens incompletas acionam preparação automática. Para descartar o novo cache e recuperar após uma interrupção abrupta, execute `rm -rf -- build/cache/kof-launch-v2` na raiz do checkout. Isso também remove diretórios temporários sem uso e força preparação na próxima chamada. O filesystem do cache precisa oferecer bloqueios de arquivo e movimentos atômicos de diretórios. O custo de preparação inicial e a comparação de inicialização quente estão no [relatório de validação M1P](.agent/validation/kofmut-m1p.md); a meta de cache quente não se aplica ao primeiro build.

A inicialização quente cumpriu a meta M1P: mediana Kof **0.7129 s**, mediana Python **0.6738 s** (5.81% acima do Python, dentro de 10%), em 33 pares alternados sem compilação. Três chamadas com cache vazio levaram 5.05 s, 5.15 s, 5.17 s. Veja dispersão, resultados brutos e condições no [relatório M1P](.agent/validation/kofmut-m1p.md). O orçamento de integração de 90 segundos continua sem comprovação.

## O que M1 comprova

As verificações de comportamento exercitam o lexer e o parser reais do Kof 0.6.4. Elas verificam leitura de arquivo, associação exata de uma expressão `<` ao token do lexer, percurso de funções, métodos, construtores, inicializadores de campos e lambdas, operadores repetidos e aninhados, e exclusão de símbolos em strings, comentários e parâmetros genéricos. As localizações usam linha e coluna começando em 1 e **offsets de String UTF-16 da JVM**, em vez de offsets de bytes UTF-8.

Diagnósticos do lexer e do parser impedem a geração de candidatos. Formas da AST não suportadas são informadas explicitamente. Este marco comprova a seleção de `<` para `<=`; os demais operadores e o percurso completo estão pendentes no M2. Ele ainda não compila nem executa mutantes e não avalia a qualidade dos testes.

`./scripts/check` executa testes Kof nomeados do CLI por `kof test`, depois compila e executa um programa Kof de contrato com `assert` e o frontend oficial no classpath. O `kof test` instalado não aceita `--classpath`, portanto a prova do frontend usa o estilo documentado de programa completo com asserções. Ela não introduz um framework de testes. Os projetos avaliados pelo futuro mutador usarão seus comandos configurados de `kof check --json` e `kof test`.

As verificações do lançador usam cópias descartáveis dos fontes e utilitários Linux usuais: GNU coreutils, `which`, `ps` e `setsid`. Elas cobrem PATH sem Python, preservação de argumentos, invalidação do cache, rejeição da ferramenta, compilação concorrente e recuperação após builds com falha ou interrompidos. O encerramento de grupos de processos nessas verificações comprova a recuperação do bootstrap; os limites de processos das futuras execuções de mutação continuam no M3.

## Próximos marcos

M2 adiciona o ciclo de mutação, cópias explícitas dos inputs e todas as famílias de operadores planejadas. M3 adiciona limites de processo, encerramento de descendentes, relatórios e aceitação externa. M4 conclui os guias do CLI, operadores e relatório em inglês e português. Veja [o plano de execução](EXECPLAN.md), [a validação do lançador M1R](.agent/validation/kofmut-m1r.md) e [a evidência histórica do M1](.agent/validation/kofmut-v0.1.0.md).

## Licença

KofMut usa **GPL-3.0-only**. Veja [LICENSE](LICENSE) e [NOTICE](NOTICE). O jar do Kof e seu JDK embutido permanecem na instalação do usuário e não são incluídos neste checkout de fonte.
