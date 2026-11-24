# omp-capri

Tema **Capri Afterdark** e personalidade **Capri — Project Capricorn** para o [oh-my-pi (OMP)](https://github.com/can1357/oh-my-pi).

O pacote altera apenas a aparência do OMP e, opcionalmente, adiciona a personalidade como contexto global. Modelos, providers, credenciais e demais preferências permanecem intocados.

## Conteúdo

| Arquivo | Destino | Descrição |
|---|---|---|
| `themes/capri-afterdark.json` | `~/.omp/agent/themes/` | Tema escuro magenta, violeta e verde |
| `AGENTS.md` | bloco gerenciado em `~/.omp/agent/AGENTS.md` | Personalidade Capri para novas sessões |
| `install.sh` | executado localmente | Instalador idempotente com backup |

## Paleta

| Nome | Cor |
|---|---|
| background | `#100C14` |
| surface | `#1B1420` |
| foreground | `#E5D9E3` |
| border | `#542039` |
| accent | `#F04491` |
| magenta | `#E34A92` |
| violet | `#B99AEF` |
| green | `#00C768` |
| warning | `#B2D94B` |
| error | `#EE2865` |

## Instalação no Steam Deck ou Linux

O OMP e o Git precisam estar disponíveis no `PATH`.

```bash
git clone https://github.com/lgs4/omp-capri.git
cd omp-capri
./install.sh
```

Feche e abra o OMP depois da instalação. A personalidade é carregada apenas em sessões novas.

### Somente o visual

```bash
./install.sh --theme-only
```

Essa opção instala o tema, seleciona `capri-afterdark` como tema escuro e usa símbolos ASCII, sem alterar `AGENTS.md`.

## Segurança e convivência com configurações existentes

- O script usa `PI_CODING_AGENT_DIR` quando definido; sem ele, instala em `~/.omp/agent`.
- Arquivos alterados recebem backup em `~/.omp/agent/backups/capri-afterdark-<data>/`.
- O conteúdo Capri ocupa um bloco gerenciado dentro de `AGENTS.md`; instruções existentes fora dele são preservadas.
- Reexecutar o instalador não duplica o bloco nem cria backups quando tudo já está atualizado.
- Nenhum arquivo de autenticação, modelo ou provider faz parte deste repositório.

## Atualização

```bash
cd omp-capri
git pull --ff-only
./install.sh
```
