# Instalação do Home Assistant Supervisedo na TV box Tanix TX3 rodando Armbian

Este tutorial é baseado em [Instalacao_armbian_hassio_TX3][Instalacao_armbian_hassio_TX3] e foi escrito em 31/01/2024

Apesar deste tutorial ter sido testado, pode ser encontradas adversidades que não podem ser simuladas devido à diversidade de hardware existente e à disponibilidade de software disponível no momento da utilização.

Desse modo, não darei nenhum tipo de suporte a este tutorial, ficando o mesmo ainda disponível para quem quiser por sua conta e risco usar.

1 – Começamos fazendo download do Balena Etcher - https://www.balena.io/etcher/.

2 – Depois fazendo download do ArmBian em https://github.com/ophub/amlogic-s9xxx-armbian/releases

Eu usei uma versão de Armbian_bullseye_xxxxxx por ser baseada em debian e estar atualizada com a última versão.
A imagem que usei foi Armbian_24.2.0_amlogic_s905x3_bullseye_6.6.13_server_2024.01.25.img.gz, mas caso não esteja mais disponível ou se não funcionar para você, teste versões Armbian_24.2.0_amlogic_s905x3_bullseye_xxxxxxxxx.img.gz.
O importante é que comecem com Armbian_24.2.0_amlogic_s905x3_bullseye.

3 – Com um PENDRIVE formatado (é bom formatar com https://www.sdcard.org/downloads/formatter/) vamos gravar a imagem do Armbian com o BalenaEtcher no PENDRIVE.

4 – Quando concluído, abrir uEnv.txt que esta na raiz da PENDRIVE e substituir o dtb que lá está por um referente a sua TX3 (meson-sm1-tx3-bz.dtb ou meson-sm1-tx3-qz.dtb).

![uenv](https://user-images.githubusercontent.com/43672635/212434955-3c84c7e5-49ce-41e8-b596-eefc1b564e4a.png)

5 – Ejetar a PEN do computador e colocar na porta UBS 3.0 na lateral esquerda da TANIX.

6 – Ligar o cabo HDMI e cabo de Rede na TANIX. Atenção que a TANIX ainda deve estar desligada da eletricidade.

7 – Com uma agulha acionar o botão de reset atrás da TANIX até sentir o clique então ligar a box á energia.

8 – Quando aparecer o símbolo ```TX3``` no monitor/televisão, largar o botão de reset. Esperar o carregamento do armbian na sua box, no final deve aparecer um ip atribuído.
Algumas vezes não aparece o símbolo ```TX3``` e começa a aparecer a sequência de carregamento, não tem problema.
Se não for atribuído um IP, retire e reinsira o cabo de rede sem desligar a tv box. Se mesmo assim não conseguir obter o IP, tente outro dbt editando uEnv.txt voltando ao ponto 4.
Caso ainda não obtenha sucesso, tente outra imagem do armbian, voltando ao ponto 2.

9 - Em seguida vamos acessar o armbian usando putty pelo Windows ou terminal caso use Mac, no terminal do Mac: ssh root@IP_BOX, onde IP_BOX é o IP da TV box. A senha inicial é 1234 (usuário root e senha 1234).

![putty](https://user-images.githubusercontent.com/43672635/212269473-e8f5bc73-39d8-4352-98cf-fd8240dec856.png)

Quando entrar vai ser solicitado para criar uma nova senha para o usuário root e depois para criar um novo usuário e sua senha, é só seguir os passos. Anotar esses dados (senha do root, novo usuário e senha do novo usuário). São muito importantes.

10- Aqui vamos criar a nova senha senha do usuário root

![criar pass](https://user-images.githubusercontent.com/43672635/212269776-ed27a55b-6676-4eca-a8e3-6418d0ad7947.jpeg)

11- agora vamos escolher a opção 1 (bash).

![opcao1](https://user-images.githubusercontent.com/43672635/212270022-2681da32-4073-4102-85f8-3daa138bbdd9.jpeg)

12- Aqui vamos escolher o novo usuário, em seguida será solicitada a senha e a confirmação e então solicitar o nome real do usuário (basta dar Enter).

![user name](https://user-images.githubusercontent.com/43672635/212333440-deb4cfc2-1f09-4f76-ae35-2d5c272f1a41.jpeg)

13 - Então será solicitado a definição da linguagem, baseada na timezone detectada. Basta dar Enter...

![enter](https://user-images.githubusercontent.com/43672635/212333795-0eef3850-bc21-4ff2-8772-10e93a15e41e.jpeg)

14 - Após a definição da liguagem já estamos prontos para instalar o armbian na memória eMMC da TV box dando o seguinte comando: ```armbian-install -m yes -a no```

15 - Vai aparecer uma lista de dtb´s ao qual deveremos escolher o mesmo escolhido no ponto 4, que poderá ser o 518, 520. Note que este número pode mudar conforme a imagem do armbian utilizada, o importante é que se refira ao dtb definido anteriormente (meson-sm1-tx3-bz.dtb ou meson-sm1-tx3-qz.dtb).

![dtb](https://user-images.githubusercontent.com/43672635/212334717-b3a50641-f55c-4f01-b631-e1b2b3f32d07.jpeg)

16 - Então aparece para escolher o tipo de formatação a ser utilizado na memória eMMC. Escolher 1 (ext4).

17 - Finalmente após alguma espera (nunca interrompam o processo) vamos ter esta msg no final. Então digite poweroff para finalizar a seção do armbian e desligar a TV box.

18 - Agora desligar a energia, retirar o PENDRIVE e voltar a ligar.

19 - Vamos acessar novamente o armbian com o usuário root e a nova senha definida para o root (como em 9, agora com a nova senha).
Então vamos executar um comando para fazer as atualizações e ajustes do armbian e a instalação do Home Assistant supervisor (possivelmente o armbian poderá ser reinializado, necessitanto fazer um novo acesso e repetir o comando).
Devemos copiar e colar este comando ```curl -sL https://raw.githubusercontent.com/maxcalavera81/Instalacao_armbian_hassio_TX3/main/instalacao_homeassistant.sh | bash -s```
Depois de tudo bem sucedido vai aparecer a seguinte caixa e selecionamos ```qemuarm-64``` com a seta para baixo e damos enter.

![osagents](https://user-images.githubusercontent.com/43672635/212336624-b7161dfe-b0d1-4440-a8aa-589c95bd3abb.jpeg)

20 - Então será instalado o home assistant com o supervisor. Se tudo correr bem, vamos receber a informação de conclusão.

21 - Vamos no nosso browser acessar http://ip_da_box:8123 e aguardar a instalação. Quando aparecer a tela para criar novo login ou restaurar backup, devemos fazer um reboot para que as alterações seja aplicadas, comandando ```sudo reboot```.

Se quisermos usar o bluetooth ou o wifi da box temos que acessar novamente o armbian como usuário root e dar o comando ```sudo armbian-config``` e vai abrir uma caixa de opções.

![network](https://user-images.githubusercontent.com/43672635/212344741-788c48c3-e7e4-4fce-b1b4-25d86ddac8f3.png)

Escolhemos a opção ```network``` e depois vamos escolher a opção ```bt install``` e aguardam a instalação.

![bt install](https://user-images.githubusercontent.com/43672635/212345004-a5651ad2-c35e-4fa4-81f5-170757be65f1.png)

Depois de concluído a instalação basta ir ao Home Assistant e fazer a integração do bluetooth.

Boas instalações!











I created the file ***hassio_tanix_tx3.sh***, which is a script for installing Home Assistant on TV Box Tanix TX3.

This script is largely based on MadDoct <@MadDoct> / Dale Higgs' <@dale3h> work on [MadDoct/hassio-installer][MadDoct-hassio-installer].

This script will install Docker, [Agent for Home Assistant OS][os-agent], and then install
[Home Assistant Supervised][supervised-installer].

The entire procedure is based on the image ***Armbian_20.10_Arm-64_buster_current_5.9.0.img.xz*** taken from [armbian storage][armbian-storage].

## Requirements

- Tanix TX3 TV BOX

## Installation Instructions

1. Download [Armbian_20.10_Arm-64_buster_current_5.9.0.img.xz][armbian-image].
2. Flash ***Armbian_20.10_Arm-64_buster_current_5.9.0.img.xz*** on a PEN DRIVE of at least 8 GB.
3. Copy the files from the ***boot*** folder to the root of the PEN DRIVE, obeying the subfolders. The files ***extlinux.conf*** and ***extlinux.conf-menu*** must be overwritten.
4. At the root of the PEN DRIVE, RENAME the file ***u-boot-s905x2-s922*** to ***u-boot.ext***.
5. Install the PEN DRIVE on the Tanix TX3 USB 3.0 port and boot, pressing the reset button. Change the initial password from ***1234*** to your convenience and create a new user.
6. Run this as root user to transfer Amrbian to eMMC:
```bash
./install-aml.sh
```
7. Reboot (remove the PEN DRIVE).
8. With Armbian on eMMC, run this as root user:
```bash
curl -sL https://raw.githubusercontent.com/leofig-rj/Hassio-Tanix-TX3/master/script/hassio_tanix_tx3.sh | bash -s
```
9. When ***Select machine type*** appears, select: ***qemuarm-64***

## License

MIT License

Copyright (c) 2021 Leonardo Figueiro, Bruno Melo <@maxcalavera81>, MadDoct <@MadDoct> and Dale Higgs <@dale3h>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[os-agent]: https://github.com/home-assistant/os-agent
[supervised-installer]: https://github.com/home-assistant/supervised-installer
[Instalacao_armbian_hassio_TX3]: https://github.com/maxcalavera81/Instalacao_armbian_hassio_TX3/tree/main
[MadDoct-hassio-installer]: https://github.com/MadDoct/hassio-installer
[armbian-storage]: https://users.armbian.com/balbes150/arm-64
[armbian-image]: https://users.armbian.com/balbes150/arm-64/Armbian_20.10_Arm-64_buster_current_5.9.0.img.xz
