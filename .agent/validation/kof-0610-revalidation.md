# Revalidação com Kof 0.6.10 (SiFuture e KofMut)

Data: 2026-11-01/02 (UTC). Encerrada por decisão do usuário antes da bateria longa do KofMut: o 0.6.10 **não deve ser adotado ainda**. Registro parcial e explícito; nada abaixo aprova o 0.6.10.

Evidência bruta: `.agent/tmp/kof-0610/e6eab6d5-f4d2-44bd-8663-c0bdfa21b195/` (abreviada **E**). Cada comando tem `<nome>.{json,stdout,stderr}` com argv, cwd, PATH, início/fim UTC, duração monotônica e exit nativo, gravados por `.agent/tmp/kof-0610/record`. Inventário SHA-256: `E/raw-evidence.sha256` (120 arquivos).

## Identidade

| Item | Valor |
| --- | --- |
| Kof 0.6.10 | `~/.local/share/kof/kof-0.6.10-linux-x86_64`, `kof.jar` `a6bbbb33bd1ba1cbd3bbfaf424b81106df3c713a10bb3642a10ecdd9b023b800`, Eclipse Adoptium 25.0.5, primeiro no PATH (`~/.local/bin/kof`) |
| Kof 0.6.4 (controle) | `kof.jar` `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62` |
| KofMut | checkout `9f9bb069f02b8dfb6e291b4bbed18c0daced1c37`, limpo; imagem instalada `b5401898d74f18086fa29ed8f59f55f3e51a84a1608a5b4a23278f6282735d79`, `src/main` idêntico ao checkout |
| SiFuture | `ba8739d9c125e5a7693dd388631d8fd09d702714`, limpo; arquivos rastreados iguais antes/depois |
| Pesquisa Kof | `~/projects/kof` em `b5b63d14e` (registro de release 0.6.10), somente leitura |
| Navegador | Google Chrome 155.0.8059.39 (WSLg, `DISPLAY=:0`) |

Nenhuma distribuição Kof foi baixada, alterada ou atualizada. Nenhum commit foi criado.

## SiFuture com 0.6.10

| Passo | Comando | Exit | Resultado |
| --- | --- | ---: | --- |
| check | `python3 scripts/kof_project.py check --target jvm\|js --json --kof kof` | 0 / 0 | success true, 0 erros |
| test | `python3 scripts/kof_project.py test --target jvm\|js --kof kof` | 0 / 0 | 0 failed of 114, nos dois alvos |
| build | `python3 scripts/kof_project.py build --output E/sf-build-out` | 0 | 113 arquivos, com `index.html` e `Default.mjs` |
| Python | `python3 -m unittest discover -s tests -p 'test_*.py'` | 0 | 16 testes OK |
| CI | `bash tests/ci-contract.sh` | 127 → 0 | primeiro: `rg: command not found` (ferramenta ausente); com o ripgrep 15.0.0 já existente do VS Code no PATH temporário: 28 PASS |
| sensores | `scripts/kof-sensors/test` | **1** | 21 testes, 1 falha, 8 erros |
| sensores | `mvn -f scripts/kof-sensors/pom.xml test` sem `-Dkof.jar` | 1 | falha esperada (`systemPath ... ${kof.jar}`) |
| sensores | `scripts/kof-sensors/run .` | **1** | `success: false`, 14 falhas em 25 arquivos |
| sensores | `scripts/kof-sensors/verify-kofmut <kof-mut> E/verify-kofmut-out` | 0 | `detected` complete/0 (1 Killed), `survived` complete/1 (1 Survived), `kofVersion` 0.6.10, fixtures preservadas |
| navegador | sete `python3 tests/browser*.py` | **1** em seis | só `browser_meteor.py` passa |

Controle com o mesmo código e Kof 0.6.4: os sete percursos passam (exit 0). Com 0.6.9, `browser.py` e `browser_controls.py` falham da mesma forma que com 0.6.10.

## Bloqueio 1: regressão `Column`/`Row` continua no 0.6.10

Sintomas no navegador: `#game-keyboard`, `#subchief-status` e `#boss-status` nunca aparecem (timeout 30000 ms), e `canvas:visible` resolve dois elementos. O JS gerado pelo 0.6.10 em `E/sf-build-out/Default.mjs` contém `kofListAdd(__kof_t14, heading("Teclado"))`, uma chamada nua no lugar de `this.heading(...)`.

Reprodutor mínimo de `kof-sifuture/.agent/validation/kof-0.6.9-ui-column-method-issue.md` (cópia em `E/repro-Main.kf`), num diretório sem `kof.toml` ancestral:

| Kof | build JS | `node out/Default.mjs` | `kof run --target jvm` |
| --- | ---: | --- | --- |
| 0.6.10 | 0 | exit 1, `ReferenceError: heading is not defined` | exit 1, `NoSuchMethodError: 'java.lang.Object Default.Main.heading(java.lang.String)'` |
| 0.6.4 | 0 | `ok` | `ok` |

O Kof triou o defeito como issue **#991** (commit `c74cc85d8`: "Column/Row 1-arg branch skips argument inference ... one-line fix validated in an isolated export"), mas a correção não está no 0.6.10. O commit `5fb5b910a` continua ancestral do registro de release.

## Bloqueio 2: posição do nó de construtor mudou no 0.6.7

O analisador de sensores (`scripts/kof-sensors/src/main/java/sifuture/sensors/Spans.java:100`) espera que `ConstructorDeclarationNode.position()` aponte para o token após o `}` do corpo. O probe `E/CtorProbe.java`, que usa o lexer e o parser oficiais de cada jar, mostra (`E/ctor-position-probe.txt`):

| Kof | Posição de `constructor() { ... }` |
| --- | --- |
| 0.6.4, 0.6.5, 0.6.6 | após o corpo |
| 0.6.7, 0.6.8, 0.6.9, 0.6.10 | início da declaração (`constructor(`, `Box(`) |

O defeito não é do 0.6.10. Os sensores foram validados por último com 0.6.4 e quebram em qualquer Kof ≥ 0.6.7. Corrigir isso cabe ao SiFuture: deixar de depender de onde o nó de construtor começa ou termina. Nada foi alterado nesta revalidação.

## KofMut com 0.6.10

Executado: apenas o `verify-kofmut` acima. O KofMut instalado adotou o 0.6.10 pela aprovação normal de compatibilidade e produziu um Killed e um Survived corretos.

**Não executado**, por decisão do usuário (sem aprovação nem reprovação):

- `PATH=<0.6.10>/bin:$PATH KOF_MUT_COMPATIBILITY_OTHER=<0.6.4>/bin ./scripts/check`;
- comandos focados de compatibilidade e `launch-arguments` com 0.6.4 primeiro e 0.6.10 como alternativa;
- receita manual de mutação do SiFuture (Background + Meteor), cuja referência com 0.6.4 é `complete`, 42 candidatos, 38 Killed e 4 Survived.

## Conclusão

O Kof 0.6.10 **não deve ser usado ainda** no SiFuture. O jogo compila e passa nos 114 testes em JVM e JS, mas seis dos sete percursos de navegador falham por causa da regressão #991 do compilador, ainda sem correção. A interface de controles quebra em tempo de execução nos dois alvos, mesmo com build exit 0. Os sensores também falham, mas isso vem de uma mudança de AST do 0.6.7 e deve ser adaptado no SiFuture, independentemente da versão do Kof. Para adotar uma versão futura, repita esta matriz e rode a parte do KofMut que ficou de fora.
