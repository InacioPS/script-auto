# Script de automação de instalação de pacotes
Esse script é bem simples e tem a proposta de servir para a maioria das bases linux, sendo a mais beneficiadas a base *Archlinux* por conta do *Aur*.

A única coisa necessária para facilitar a sua vida e fazer uma listagem dos pacotes instalado por você, depois disso é só colar o nome dos pacotes dentro da linha com:

<pre>
PACOTES=(
"NOME DO PACOTE"
fish
discord
)
</pre>

<pre>
AUR_PACOTES=(
asusctl
)
</pre>

> [!IMPORTANT]
>
> O script só aceita nomes exatos, mas de caso não tenha o pacote, o script vai simplesmente pular o pacote.

Se estiver usando o *Archlinux/Derivados* use esse comando para listar os pacotes instalado pelo o usuario no *repositório official*:

```bash
pacman -Qenq
```

E pelo *Aur*:

```bash
pacman -Qemq
```

