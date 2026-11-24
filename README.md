# omp-capri

Minhas customizações do [oh-my-pi (omp)](https://github.com/can1357/oh-my-pi).

## O que tem aqui

| Arquivo | Destino | Descrição |
|---|---|---|
| `themes/capri-afterdark.json` | `~/.omp/agent/themes/` | Tema escuro magenta/violeta/verde inspirado em Cyberpunk: Edgerunners |
| `config.yml` | `~/.omp/agent/` | Tema ativo, preset ASCII, papéis de modelo, startup silencioso |
| `models.yml` | `~/.omp/agent/` | Override de provider do OpenRouter |
| `PERSONALITY.md` | `~/.omp/agent/` | Personalidade "Capri — Project Capricorn" |

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

## Instalação

```bash
git clone https://github.com/lgs4/omp-capri.git
cd omp-capri
./install.sh
```

O script faz backup dos `config.yml`, `models.yml` e `PERSONALITY.md` que já existirem. Se quiser só o tema, copie `themes/capri-afterdark.json` e coloque isto no `config.yml`:

```yaml
theme:
  dark: capri-afterdark
symbolPreset: ascii
```
