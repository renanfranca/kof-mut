# KofMut 0.1.0: evidência do marco M1

Data: 2026-10-16. Estado: **M1 concluído; produto completo e publicação pendentes**.

## Identidade da árvore e do ambiente

O checkout foi criado localmente na branch `kofmut-frontend`, sem commits, remote ou publicação. Não há SHA de commit do KofMut para declarar. O [manifesto SHA-256](kofmut-m1.sha256) identifica os arquivos revisados de fonte, testes, lançador, instruções e documentação; este relatório e o próprio manifesto ficam fora dele para evitar autorreferência.

Modelo confirmado pelo usuário: GPT 6.1 Sol com esforço xhigh. Essa escolha substitui Luna/high do planejamento. Não houve subagentes, worktrees, execução do piloto antigo ou alteração do SiFuture.

As provas usaram a distribuição instalada Kof/compiler/runtime/stdlib **0.6.4**, Linux x86_64, JDK embutido Eclipse Adoptium 25.0.4.1. Instalação local: `/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64`.

SHA-256 de `lib/kof.jar`: `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62`.

As fontes Kof consultadas estavam em `53efd25fdb8dfec1fbbd989c1f482b2ee38c3ce8`. Documentação, implementação e testes locais orientaram as decisões; a compatibilidade foi comprovada pelo jar instalado. O `kof` do PATH mudou externamente para 0.6.5 durante o trabalho. As verificações finais colocaram explicitamente a instalação 0.6.4 primeiro no PATH. O código do produto não contém esse caminho pessoal.

## Comandos e resultados observados

```bash
export PATH="/home/renanfranca/.local/share/kof/kof-0.6.4-linux-x86_64/bin:$PATH"
./bin/kof-mut --version
./bin/kof-mut --help
./scripts/check
```

| Verificação | Resultado |
| --- | --- |
| `--version` | Exit 0, `KofMut 0.1.0`, valor de VERSION |
| `--help` | Exit 0, comandos disponíveis e aviso de que mutação ainda não está disponível |
| `./scripts/check` | Exit 0, dois testes Kof nomeados do CLI e nove provas do frontend |
| Classe emitida | `Default.Main`, inspecionada com `javap`; build e execução com classpath explícito |
| Versão incompatível | Fixture de ferramenta 9.9.9 rejeitada antes do cache; PATH real com 0.6.5 também retornou 2 |
| Cópia limpa | `scripts/check` retornou 0 sem `.git`, `build/` ou `.agent/tmp/`, em diretório com espaços |
| Cwd externo | Lançador de versão funcionou a partir do diretório pai da cópia |
| Cache com VERSION alterado | Novo lançamento mostrou `0.1.0-probe` na cópia descartável |
| Cache com fonte alterado | Novo lançamento mostrou a alteração do fonte na cópia descartável |
| Executável trocado entre info e build | Prova em cópia descartável: a forma anterior sem resolução do link retornou 2; a forma atual compilou com a instalação descoberta e retornou 0 |
| Higiene do patch | `git diff --check` e verificação de whitespace dos arquivos novos; nenhum conteúdo foi staged |
| Documentação | Links dos READMEs conferidos e blocos de comandos EN/PT iguais |

Logs completos locais, excluídos de Git: `.agent/tmp/m1-final-check.log`, `.agent/tmp/m1-clean-copy.log`, `.agent/tmp/m1-executable-pin.log` e `.agent/tmp/m1-documentation-audit.log`. Os testes intermediários também ficam nessa área. As cópias de portabilidade foram removidas após as provas.

## Auditoria dos comportamentos

| Prova | Expectativa e erro plausível que ela distingue |
| --- | --- |
| Token binário exato | `<` no offset 35, linha 1, coluna 36, comprimento 1; impede usar a posição posterior de `BinaryExpr` como operador |
| Campos, construtores, métodos e lambdas | Quatro candidatos nos offsets 29, 65, 106 e 154; detecta omissão de qualquer um desses contextos |
| Leitura de arquivo | Fixture sintética real lida pela API Kof, com a localização esperada; não depende apenas de strings em memória |
| Operadores repetidos e aninhados | Dois tokens nos offsets 45 e 56; detecta associação de ambas as expressões ao primeiro símbolo |
| Strings, comentários e genéricos | Um único candidato de código no offset 71, linha 2, coluna 11; rejeita seleção por símbolos no texto bruto |
| Unicode e CRLF | Offset UTF-16 44, coluna 45, token recuperado por substring; o byte UTF-8 correspondente é 46. Outro caso põe CRLF antes do operador e verifica offset 46, linha 2, coluna 27, contra byte UTF-8 48 |
| Diagnósticos do frontend | String sem fechamento produz LEX002 e função sem fechamento produz diagnóstico PARSE; ambos retornam zero candidatos |
| Forma não percorrida | `IfStmt` válido produz limitação identificando o tipo da AST, com zero erros de sintaxe; não se torna escopo aprovado |
| Arquivo ausente | Erro explícito e nenhum candidato; evita descarte silencioso |
| Versão pelo CLI | Saída corresponde ao arquivo VERSION, por meio do lançador real |
| Ferramenta incompatível | Exit 2 e mensagem de versão exigida, mesmo após haver cache de build suportado |

O desenvolvimento começou com falha de comportamento no lançador ausente; a API de frontend teve falha de compilação seguida por falha de asserção sem candidatos; a API de leitura de arquivo também foi adicionada após falha de compilação. As verificações complementares exercitam os guardas e o frontend reais. Não houve simulação dos objetos do lexer ou parser.

## Limites e próxima etapa

M1 comprova acesso e percurso do frontend, com seleção inicial de `<` para `<=`. As outras famílias e o percurso completo pertencem a M2. Construções como `IfStmt` são deliberadamente reportadas como não suportadas nesta etapa.

`run`, configuração/escopo públicos, baseline, sandboxes, execução dos mutantes e o contrato JSON versão 1 continuam pendentes. Limites globais, encerramento de descendentes, concorrência de avaliações e a medição no SiFuture pertencem a M3. Não há evidência de conclusão dentro do orçamento de 90 segundos e não se deve ativar o sensor a partir deste marco.

O lançador depende de Bash e Python 3.9 ou posterior, só com biblioteca padrão. A análise está em Kof; o jar e o JDK da instalação não são redistribuídos. O `kof test` 0.6.4 não oferece classpath externo: por isso as nove provas de frontend usam um programa Kof com `assert`, compilado com a opção oficial de build. Não foi criado um framework de testes nem um runner para projetos avaliados.

Continuar pelo **M2** do [EXECPLAN](../../EXECPLAN.md), começando por uma função aritmética cujo teste detecte a troca e por uma fixture propositalmente insuficiente que sobreviva. A documentação completa, a aceitação externa e qualquer publicação permanecem pendentes. Descartar `build/` é suficiente para recompilar o cache; os fontes e testes do projeto avaliado não foram usados nem alterados neste marco.
