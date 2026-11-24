# omp-capri

Temas **Capri Afterdark** e personalidade **Capri — Project Capricorn** para o [oh-my-pi (OMP)](https://github.com/can1357/oh-my-pi).

O pacote altera apenas a aparência do OMP e, opcionalmente, adiciona a personalidade como contexto global. Modelos, providers, credenciais e demais preferências permanecem intocados.

## Variantes

| Variante | Uso | Acento normal | Vermelho |
|---|---|---|---|
| `capri-afterdark` | Terminais já calibrados, como o perfil correspondente do iTerm2 | Rosa | Acentos e erros |
| `capri-afterdark-deck-lcd` | Steam Deck LCD com Konsole | Ciano/violeta | Somente erros, remoções e arquivos não rastreados |

A variante Deck acompanha uma paleta ANSI nativa do Konsole. Isso evita que o Konsole substitua as cores do OMP pela paleta padrão e transforme acentos normais, níveis altos de raciocínio e erros em tons visualmente parecidos.

## Conteúdo

| Arquivo | Destino | Descrição |
|---|---|---|
| `themes/capri-afterdark.json` | `~/.omp/agent/themes/` | Tema Capri original |
| `themes/capri-afterdark-deck-lcd.json` | `~/.omp/agent/themes/` | Tema com separação semântica para o LCD |
| `konsole/CapriAfterdarkDeckLCD.colorscheme` | `$XDG_DATA_HOME/konsole/` | Paleta normal, intensa e faint do Konsole |
| `konsole/CapriAfterdarkDeckLCD.profile` | `$XDG_DATA_HOME/konsole/` | Perfil do Konsole que seleciona a paleta |
| `AGENTS.md` | bloco gerenciado em `~/.omp/agent/AGENTS.md` | Personalidade Capri para novas sessões |
| `install.sh` | executado localmente | Instalador idempotente com backup |

## Steam Deck LCD + Konsole

O perfil foi desenhado considerando as características oficiais do Deck LCD: tela IPS de 7", resolução 1280×800, brilho típico de 400 nits e renderização sRGB mais quente/vibrante introduzida pelo SteamOS 3.5.5.

```bash
git clone https://github.com/lgs4/omp-capri.git
cd omp-capri
./install-deck-lcd.sh
```

O instalador:

1. instala e seleciona `capri-afterdark-deck-lcd` no OMP;
2. instala o esquema e um perfil dedicado do Konsole;
3. torna esse perfil o padrão usando `kwriteconfig6` ou `kwriteconfig5`;
4. preserva seu perfil anterior e faz backup do `konsolerc` antes de alterá-lo;
5. instala a personalidade Capri.

Feche todas as janelas do Konsole e abra uma nova depois da instalação.

### Instalar sem trocar o perfil padrão do Konsole

```bash
./install-deck-lcd.sh --no-konsole-default
```

Depois selecione **Capri Afterdark - Steam Deck LCD** em **Settings → Manage Profiles** ou inicie uma janela com:

```bash
konsole --profile "Capri Afterdark - Steam Deck LCD"
```

### Somente o visual

```bash
./install-deck-lcd.sh --theme-only
```

Isso não altera o `AGENTS.md`.

## Tema original

```bash
./install.sh
```

Para instalar apenas o visual original:

```bash
./install.sh --theme-only
```

## Cores semânticas da variante Deck

| Função | Cor |
|---|---|
| respostas da Capri | `#E5C2E8` |
| texto técnico e geral | `#F2EAF0` |
| acento e função | `#70D9E5` |
| estrutura e palavras-chave | `#C3A0F2` |
| sucesso e adição | `#55D99B` |
| atenção e estado dirty | `#F0D36A` |
| erro e remoção | `#FF667A` |
| fundo | `#120F16` |

O vermelho não é usado para níveis normais de raciocínio, títulos, links ou modelo ativo.

## Ajuste de tela do SteamOS

O SteamOS oferece **Settings → Adjust Display Colors** para controlar vibrância e temperatura. O instalador não altera essas opções. Se a vibrância estiver muito acima do padrão, até cores semanticamente separadas podem voltar a parecer saturadas; use o padrão como ponto inicial.

## Segurança, backup e rollback

- O script usa `PI_CODING_AGENT_DIR` quando definido; sem ele, instala em `~/.omp/agent`.
- Arquivos alterados recebem backup em `~/.omp/agent/backups/<tema>-<data>/`.
- O conteúdo Capri ocupa um bloco gerenciado dentro de `AGENTS.md`; instruções existentes fora dele são preservadas.
- Reexecutar o instalador não duplica conteúdo nem cria backups quando tudo já está atualizado.
- Nenhum arquivo de autenticação, modelo ou provider faz parte deste repositório.
- Para voltar ao perfil anterior do Konsole, selecione-o em **Settings → Manage Profiles**. O `konsolerc` anterior também fica no diretório de backup informado pelo instalador.

## Atualização

```bash
cd omp-capri
git pull --ff-only
./install-deck-lcd.sh
```

## Referências

- [Valve — especificações do Steam Deck LCD](https://www.steamdeck.com/en/tech/deck)
- [Valve — SteamOS 3.5.5 e ajustes de cor do LCD](https://steamcommunity.com/games/1675200/announcements/detail/5484882897552407489)
- [KDE — perfis do Konsole](https://docs.kde.org/trunk_kf6/en/konsole/konsole/profiles.html)
- [KDE — formato de referência do esquema Breeze](https://github.com/KDE/konsole/blob/master/data/color-schemes/Breeze.colorscheme)
