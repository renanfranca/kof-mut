[English](README.md) | [Português](README.pt_BR.md)

# Mutação de limite equivalente

`Calc.clamp` substitui valores negativos por zero e preserva os demais valores.
Os testes cobrem entradas negativa, zero e positiva: `-7 → 0`, `0 → 0`, `7 → 7`.

Trocar `x < 0` por `x <= 0` apenas acrescenta a atribuição de zero a um valor
que já é zero. Todos os resultados observáveis são iguais. O resultado esperado
do KofMut é um `Survived`, `complete`, exit 1 e nenhum candidato descartado.
O KofMut apresenta o sobrevivente para análise humana; não identifica nem
suprime equivalência semântica automaticamente. Acrescentar um teste que finja
uma diferença entre essas versões distorceria o contrato da função.
