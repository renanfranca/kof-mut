# Revalidação com Kof 0.7.0

Data: 2026-11-03 (UTC). Registro completo, com a matriz do SiFuture, em
[kof-sifuture `.agent/validation/kof-0.7.0-revalidation.md`](../../../kof-sifuture/.agent/validation/kof-0.7.0-revalidation.md).
Executa a parte que ficou de fora em [kof-0610-revalidation.md](kof-0610-revalidation.md).

| Item | Valor |
| --- | --- |
| KofMut | checkout `64c85f886fe117b80440bea22da60dc13865f369`, limpo; imagem instalada `b5401898d74f18086fa29ed8f59f55f3e51a84a1608a5b4a23278f6282735d79` |
| Kof 0.7.0 | `kof.jar` `fda317b89bb05ffdb068c2d4ff80be71ecfa5dee821b7b322bfe296acb24ae17`, primeiro no PATH |
| Kof 0.6.4 | alternativa `KOF_MUT_COMPATIBILITY_OTHER`, `kof.jar` `137a838d…9c62` |

## Resultados

| Passo | Exit | Resultado |
| --- | ---: | --- |
| `PATH=<0.7.0>/bin:$PATH KOF_MUT_COMPATIBILITY_OTHER=<0.6.4>/bin ./scripts/check`, locale herdado | 1 | 5 testes de argv Unicode falharam em `run-a`, `run-b`, `cli-a`, `install-b` |
| o mesmo com `LC_ALL=C.UTF-8` | 0 | 9 filas passaram, 803 s (referência 0.6.4: 795 s) |
| `verify-kofmut` do SiFuture | 0 | 1 Killed, 1 Survived, `kofVersion` 0.7.0 |
| receita manual do SiFuture (Background + Meteor) | 1 | `complete`, 42 candidatos, 38 Killed, 4 Survived, iguais ao 0.6.4 |

A falha com locale herdado não é do Kof: o shell define `LANG=en_US.UTF-8`,
esse locale não está instalado e a JVM passa a decodificar argv como ASCII.
Um probe com `kof run` imprime `"a????o ????"` em 0.6.4, 0.6.10 e 0.7.0, e
`"ação 😀"` em 0.6.4 e 0.7.0 com `LC_ALL=C.UTF-8`.

Conclusão: o KofMut instalado adota o 0.7.0 e passa a checagem completa em
um shell com locale UTF-8 válido. Evidência local opcional no SiFuture em
`.agent/tmp/kof-070/56e99392-da69-4674-b9e0-906d6e585000/`.
