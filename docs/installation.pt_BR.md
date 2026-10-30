[English](installation.md) | [Português](installation.pt_BR.md) | [KofMut](../README.pt_BR.md)

# Instalar, atualizar e recuperar

Use estes procedimentos para instalação local em Linux/JVM. Atenda primeiro aos [requisitos](../README.pt_BR.md#requisitos). A [referência CLI](cli.pt_BR.md#instalação-local-e-gerenciamento) concentra argumentos exatos de gerenciamento, caminhos, formatos de recibo e regras de recusa.

## Instalar o KofMut

Use um checkout gravável do fonte do KofMut e uma distribuição oficial existente do Kof no `PATH`. O KofMut não instala nem atualiza o Kof. Confira a instalação selecionada e execute na raiz do checkout:

```bash
kof info --json
./install.sh
export PATH="$HOME/.local/bin:$PATH"
kof-mut --version
kof-mut --help
```

Isso instala para o usuário atual em `$HOME/.local`, sem `sudo` nem edição dos perfis do shell. Persista a entrada `bin` na sua configuração do shell se necessário. Sem prefixo explícito, `HOME` deve ser não vazio e absoluto. Para um prefixo gravável personalizado, use esta alternativa:

```bash
./install.sh --prefix "$HOME/tools/kofmut"
export PATH="$HOME/tools/kofmut/bin:$PATH"
kof-mut --version
```

Um prefixo explícito pode ser relativo ao diretório de trabalho do chamador. Coloque caminhos com espaços entre aspas. A instalação retorna 0 no sucesso e 2 em erros de gerenciamento/preparação. Preparação interrompida mantém a imagem ativa anterior disponível. Confira recusas na [referência de gerenciamento](cli.pt_BR.md#instalação-local-e-gerenciamento); comandos alheios e propriedade inválida não autorizam sobrescrever arquivos.

Os documentos públicos instalados ficam em `<prefix>/share/kof-mut/releases/<id>/README.md` e `docs/`, com `<prefix>/share/kof-mut/current` apontando para a versão ativa. Leia o README dessa versão ativa ou `docs/llm-guide.md` (e suas versões em português). `current` é um link simbólico gerenciado para `releases/<id>`. Por exemplo:

```bash
kofmut_prefix="$HOME/.local"
ls "$kofmut_prefix/share/kof-mut/current/docs"
```

O pacote instalado contém fontes de runtime e documentação pública, sem fixtures do checkout, testes de desenvolvimento, histórico interno, jar do Kof ou JDK. Pode ser somente leitura; o estado gerado fica separado. Você pode remover o checkout usado pelo instalador após o sucesso. Continue pela [primeira avaliação independente](usage.pt_BR.md); seu projeto completo dispensa arquivos do checkout.

## Preparar o Kof selecionado

A primeira avaliação com novos conteúdos dos componentes prepara o KofMut e executa verificações comportamentais de compatibilidade antes de qualquer comando do projeto. Versão/ajuda não fazem essa aprovação. O progresso usa stderr:

```text
kof-mut: Kof <version> detected; preparing application...
kof-mut: checking compatibility...
kof-mut: ready; starting evaluation.
```

Preserve stderr e aguarde o processo. A preparação tem limite separado do orçamento da avaliação; não há promessa de duração. As avaliações seguintes verificam os conteúdos e reutilizam aprovação íntegra sem repetir essas mensagens nem verificações comportamentais. Cada avaliação ainda executa sua própria baseline e mutações independentes. Veja [lançador e cache](cli.pt_BR.md#lançador-e-cache) para identidades, caminhos, prazo de preparação de 90 segundos, leases e diagnósticos.

Falha de preparação retorna 2 antes dos comandos do projeto e identifica causa/etapa e local da evidência. Preserve esses logs, corrija a causa e repita o comando original. Não há retorno automático para Kof anterior. Uma chamada interrompida pode não ter relatório final; use as [regras de descoberta do relatório](report-format.pt_BR.md#descobrir-o-relatório-atual).

## Atualizar o KofMut

Escolha o checkout desejado do fonte do KofMut e execute novamente o instalador com o mesmo prefixo:

```bash
./install.sh --prefix "$HOME/tools/kofmut"
"$HOME/tools/kofmut/bin/kof-mut" --version
```

Para o prefixo padrão, execute `./install.sh`. Isso atualiza a aplicação e a documentação distribuída. A preparação valida o novo pacote antes da ativação atômica. Inputs idênticos e íntegros reutilizam a imagem; mudanças na documentação atualizam o pacote reutilizando classes compiladas válidas. Imagens anteriores permanecem disponíveis para avaliações ativas terminarem. Mudança detectada no checkout durante a instalação retorna 2 com `checkout changed during installation; retry`; estabilize o checkout e tente novamente. Veja [gerenciamento](cli.pt_BR.md#instalação-local-e-gerenciamento) para detalhes de atualização/recibos, incluindo uma reinstalação inicial para recibo legado de schema 1.

Pacotes com os fontes de runtime antigos precisam desta atualização do KofMut antes de adotar o Kof 0.6.8. Esses fontes podem falhar na inicialização com `SEM021` na atribuição do argumento de reflexão, inclusive em `--version`. Execute novamente o instalador a partir de um checkout com a correção, usando o mesmo prefixo, conforme acima; selecionar outro Kof no `PATH` não substitui os fontes do KofMut no pacote. O pacote corrigido pode então preparar conteúdos compatíveis do Kof sem o checkout, passando pelas verificações comportamentais normais.

## Adotar outro Kof

Para instalação atual, selecione uma distribuição oficial existente e execute normalmente a próxima avaliação:

```bash
export PATH="/path/to/other-kof/bin:$PATH"
kof info --json
kof-mut run --project "my-project" --files "my-project/scope.json"
```

O projeto ilustrativo já deve estar configurado conforme [uso](usage.pt_BR.md). Isso troca a dependência Kof para chamadas futuras; não atualiza o KofMut. Um pacote atual dispensa reinstalação ou checkout para adotar conteúdos compatíveis do Kof. A próxima avaliação recompila e verifica os novos conteúdos antes da aprovação; versões sozinhas não estabelecem compatibilidade. Inspecione a `kofVersion` efetiva no relatório dessa chamada.

Avaliações ativas mantêm seu runtime concreto selecionado. Preserve essa instalação do Kof disponível e intacta até terminarem; só depois remova uma instalação antiga se desejado. Scripts/executáveis explícitos do projeto mantêm sua própria resolução de dependências. O KofMut não baixa, atualiza nem modifica nenhuma das instalações do Kof.

## Recuperar sem perder evidências

| Condição observada | Procedimento |
| --- | --- |
| Preparação de compatibilidade falha | Preserve diagnósticos, corrija o problema de componente/protocolo informado e repita com o Kof pretendido. Não trate aprovação/relatório anterior como resultado. |
| Cache gerado ausente ou danificado | Repita a chamada original; componentes gerados são reconstruídos automaticamente. Veja [recuperação do cache](cli.pt_BR.md#lançador-e-cache) antes de limpeza manual. |
| Estado gerenciado contém link simbólico recusado | Aguarde chamadas ativas, inspecione o caminho informado e remova só o link inválido com `unlink -- PATH`, preservando seu destino. Tente novamente. Siga o [procedimento completo para links](cli.pt_BR.md#lançador-e-cache). |
| Arquivos do pacote instalado danificados | Reinstale a partir de checkout íntegro e desejado no mesmo prefixo. Arquivos modificados são preservados, sem adoção silenciosa. |
| Propriedade de recibo/coordenação não comprovável ou comando alheio | Preserve os arquivos para inspeção e instale em prefixo novo. Não substitua metadados de propriedade manualmente. |
| Relatório anunciado mas ausente após o término | Guarde stdout/stderr/exit como evidência atual indisponível, investigue falha de publicação e execute com nova identidade após o reparo. Nunca use outro relatório. |

Remoção manual de cache exige aguardar todas as chamadas ativas e preservar logs, recibos, pacote e estado íntegro não relacionado. Locks de estado e instalação exigem filesystem com locks de arquivos e movimentos atômicos. [Recuperação no CLI](cli.pt_BR.md#lançador-e-cache) é o procedimento detalhado canônico.

## Desinstalar

Com o comando instalado:

```bash
kof-mut uninstall
```

Somente o comando instalado oferece desinstalação, inclusive após remover o checkout. Sucesso retorna 0; chamadas ativas ou operações de gerenciamento retornam 2 sem remoção, então aguarde e repita. A desinstalação remove arquivos gerenciados inventariados e intactos da aplicação e o comando. Preserva projetos, configuração, relatórios, logs, Kof, arquivos desconhecidos ou modificados e arquivos persistentes de coordenação. [Caminhos e regras de propriedade](cli.pt_BR.md#instalação-local-e-gerenciamento) definem exatamente o que pode permanecer.
