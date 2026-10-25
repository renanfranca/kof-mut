[English](README.md) | [Português](README.pt_BR.md)

# Equivalent boundary mutation

`Calc.clamp` replaces negative values with zero and preserves all other values.
The tests cover negative, zero and positive inputs: `-7 → 0`, `0 → 0`, `7 → 7`.

Changing `x < 0` to `x <= 0` only adds an assignment of zero to an already zero
value. Every observable result is the same. The expected KofMut result is one
`Survived`, `complete`, exit 1 and no discarded candidates. KofMut reports the
survivor for human analysis; it does not automatically identify or suppress
semantic equivalence. Adding a test that pretends these versions behave
differently would misrepresent the function's contract.
