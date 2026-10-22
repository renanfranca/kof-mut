[English](operators.md) | [Português](operators.pt_BR.md) | [KofMut](../README.pt_BR.md)

# Conceitos e seleção

## Mutação

Uma mutação é uma alteração deliberada em um token de produção, como substituir `+` por `-`. O KofMut aplica cada alteração a uma cópia descartável, preservando fontes e testes originais. As alterações não se acumulam entre cópias.

## Baseline

A baseline é uma execução de check e teste numa cópia intacta dos inputs capturados do projeto. Deve passar com evidência válida antes da avaliação de qualquer mutação. Um projeto com falhas não permite estabelecer se uma alteração injetada causou a falha. O KofMut chama os comandos oficiais configurados e interpreta suas evidências; não implementa outro executor de testes.

## Candidato

Um candidato é uma proposta de mutação selecionada da árvore sintática oficial do Kof e associada a exatamente um token do lexer. Por exemplo, a expressão de produção `a + b` propõe uma alteração única para `a - b`. A seleção determinística segue caminhos normalizados dos arquivos e offsets dos tokens.

## Candidato descartado

Um candidato descartado é uma proposta de alteração que falha na preservação dos tokens, na reanálise sintática ou num check coerente do compilador. Nunca conta como alteração detectada pelos testes. Em `fixtures/invalid`, `7 * 0` propõe `7 / 0`; o check oficial rejeita divisão por zero com `ARITH001`. Essa execução retorna `no_mutants/3`, com um item em `discardedCandidates`, nenhuma avaliação retida e nenhum `Killed`.

Somente evidência válida/coerente de rejeição permite descarte. Antes do check, o KofMut confirma o token original contra o snapshot, faz a substituição, compara os dois fluxos de tokens pelo lexer oficial e reanalisa com o parser oficial. Todos os demais tokens devem ser preservados, incluindo offsets ajustados ao comprimento da substituição. Rejeições do lexer/parser e alterações indevidas nos tokens são registradas com diagnósticos. Quando só a comparação de tokens falha, a mensagem é `Variant changes tokens other than the selected token`.

Rejeição válida do check exige exit 1, `success: false` e contagens positivas de erros correspondentes aos diagnósticos ERROR. Evidência inválida ou contraditória não autoriza descarte. Divergência do snapshot, exceções inesperadas e falhas de infraestrutura permanecem erros. IDs e índices dos logs mantêm as posições originais de seleção após descartes.

## Mutante

Um mutante é um registro de avaliação de uma alteração selecionada que não foi descartada. `Killed` exige check aprovado e testes concluídos com evidência reconhecida de falha. `Survived` exige check aprovado e testes concluídos sem falhas. Por exemplo, `fixtures/detected` testa o resultado aritmético alterado e produz um `Killed/complete/0`; `fixtures/survived` aceita ambos os resultados e produz um `Survived/complete/1`.

`Timeout`, `TestError` e `Pending` descrevem avaliação inconclusiva, não detecção pelos testes. `CompileError` é um estado histórico mantido no JSON v1; novas rejeições coerentes do compilador são descartes. Veja [estados e contagens](report-format.pt_BR.md#estados-dos-mutantes) para a semântica exata. `complete` descreve conclusão e pode incluir sobreviventes; não é aprovação de qualidade.

## Operador

Um operador é a regra que escolhe o token substituto. Os cinco identificadores de família abaixo são vocabulário canônico de CLI/JSON, nos dois idiomas. Cada seta é bidirecional: catorze direções de substituição ao todo.

| Identificador da família | Substituições | Forma selecionada |
| --- | --- | --- |
| `boundary` | `<` ↔ `<=`; `>` ↔ `>=` | Expressão binária de comparação |
| `equality` | `==` ↔ `!=` | Expressão binária de igualdade |
| `logical` | `&&` ↔ `||` | Expressão binária lógica |
| `boolean` | `true` ↔ `false` | Literal booleano |
| `arithmetic` | `+` ↔ `-`; `*` ↔ `/` | Expressão aritmética binária, excluindo concatenação conhecida |

Por exemplo, `x < 0` propõe `x <= 0`; não altera também `0`, remove a condição ou reescreve a função. Cada variante parte independentemente do snapshot intacto dos inputs. Esta versão não tem flag de seleção de operadores nem sistema de plugins.

## Percurso e exclusões

O percurso cobre funções, métodos, construtores, inicializadores de campos, lambdas, condicionais, laços, switch, try/catch/finally, declarações, chamadas, atribuições, acesso a arrays, retornos, throws e asserções. Percorrer uma expressão não significa que todos os tokens dentro dela tenham uma substituição suportada.

Símbolos em comentários, strings, caracteres e delimitadores de genéricos não são expressões de produção a alterar. Sinais unários, incremento/decremento, números arbitrários, remoção de blocos e mudanças de assinaturas não têm regra de substituição. Testes nunca são selecionados para mutação; escolha o escopo de produção explicitamente e mantenha código gerado fora dele.

Concatenações conhecidas de strings são excluídas usando literais, declarações e propagação local inequívoca. `this.field` explícito resolve o campo da classe independentemente de parâmetros/locais de mesmo nome; identificador sem qualificação segue o escopo léxico. É conhecimento limitado de tipos, não inferência semântica completa. Aritmética de tipo incerto pode virar candidato e deve passar pelo check do compilador antes dos testes.

## Limitações

Uma limitação é um motivo explícito pelo qual a ferramenta não pode declarar avaliação completa do escopo selecionado. Sintaxe válida ainda não percorrida, como declarações `record`, produz limitação e impede `complete`, mesmo quando outras mutações foram avaliadas. Associações de tokens ambíguas ou ausentes também permanecem explícitas. Erros léxicos/sintáticos no fonte original são erros, não detecções pelos testes. Ausência de substituição nas famílias suportadas é diferente de sintaxe não suportada.

Localizações vêm do lexer oficial, com linha/coluna começando em 1 e offsets/comprimentos em unidades UTF-16 da JVM. Veja [regras de localização](report-format.pt_BR.md#localizações-e-evidência) antes de indexar um buffer de fonte ou mostrar uma localização em bytes.

## Possíveis equivalentes

Uma mutação equivalente preserva o comportamento observável apesar de alterar o fonte. Um possível equivalente é um sobrevivente que exige análise humana para estabelecer essa propriedade. O KofMut não diagnostica equivalência automaticamente.

O código de produção de `fixtures/equivalent` limita valores negativos a zero:

```kf
if (x < 0) { x = 0 }
```

Alterar `<` para `<=` apenas acrescenta uma atribuição de zero quando `x` já é zero. A fixture testa entradas negativa, zero e positiva e ainda retorna um `Survived`, `complete/1`, sem descarte. Reproduza com o [quarto exemplo executável](../README.pt_BR.md#executar-uma-avaliação).

Não exija um teste distintivo impossível para comportamento equivalente. Inspecione cada sobrevivente para decidir se existe diferença observável e se falta um teste adequado. Não há instrumentação de cobertura, `NoCoverage`, exclusão automática, comentário de supressão ou percentual de aprovação. Um sobrevivente sozinho não comprova ausência de cobertura nem equivalência. A [configuração do CLI](cli.pt_BR.md#configurar-um-projeto) e a [referência do relatório](report-format.pt_BR.md) descrevem como coletar e interpretar a evidência real.
