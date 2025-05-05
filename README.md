# Instalação do Home Assistant Supervisedo na TV box Tanix TX3 rodando Armbian

Este tutorial é baseado em [Instalacao_armbian_hassio_TX3][Instalacao_armbian_hassio_TX3] e foi escrito em 31/01/2024

Apesar deste tutorial ter sido testado, podem ser encontradas adversidades que não foram simuladas devido à grande variedade de hardware existente e à alteração de software disponível.

Desse modo, não darei nenhum tipo de suporte a este tutorial, ficando o mesmo ainda disponível para quem quiser por sua conta e risco usar.

1 – Começamos fazendo download do Balena Etcher - https://www.balena.io/etcher/.

2 – Depois fazendo download do ArmBian de https://github.com/ophub/amlogic-s9xxx-armbian/releases

Eu usei uma versão de Armbian_25.05.0_amlogic_s905x3_bookworm_xxxxxx por ser baseada em debian e estar atualizada com a última versão.
A imagem que usei foi Armbian_25.05.0_amlogic_s905x3_bookworm_6.12.23_server_2025.04.15.img.gz, mas caso não esteja mais disponível ou se não funcionar para você, teste versões Armbian_25.05.0_amlogic_s905x3_bookworm_xxxxxxxxx.img.gz.
O importante é que comecem com Armbian_xx.xx.x_amlogic_s905x3_bookworm.

3 – Com um MicroSD formatado vamos gravar a imagem do Armbian com o BalenaEtcher no MicroSD.

4 – Quando concluído, devemos ejetar o MicroSD, reinstalar no computador e abrir uEnv.txt que esta na raiz do MicroSD. Devemos substituir o dtb que lá está por um referente a sua TX3 (meson-sm1-tx3-bz.dtb ou meson-sm1-tx3-qz.dtb).

![uenv](https://user-images.githubusercontent.com/43672635/212434955-3c84c7e5-49ce-41e8-b596-eefc1b564e4a.png)

5 – Ejetar o MicroSD do computador e colocar na porta de MicroSD na lateral direita da TANIX.

6 – Ligar o cabo HDMI e cabo de Rede na TANIX. Atenção que a TANIX ainda deve estar desligada da eletricidade.

7 – Com uma agulha acionar o botão de reset atrás da TANIX até sentir o clique, então ligar a box à energia.

8 – Quando aparecer o símbolo ```TX3``` no monitor/televisão, largar o botão de reset. Esperar o carregamento do armbian na sua TV box, no final deve aparecer um ip atribuído.
Algumas vezes não aparece o símbolo ```TX3``` e começa a aparecer a sequência de carregamento, não tem problema.
Se não for atribuído um IP, retire e reinsira o cabo de rede sem desligar a tv box. Se mesmo assim não conseguir obter o IP, tente outro dbt editando uEnv.txt voltando ao ponto 4.
Caso ainda não obtenha sucesso, tente outra imagem do armbian, voltando ao ponto 2.

9 - Em seguida vamos acessar o armbian usando putty pelo Windows ou terminal caso use Mac, no terminal do Mac: ssh root@IP_BOX, onde IP_BOX é o IP da TV box. A senha inicial é 1234 (usuário root e senha 1234).

![putty](https://user-images.githubusercontent.com/43672635/212269473-e8f5bc73-39d8-4352-98cf-fd8240dec856.png)

Quando entrar vai ser solicitado para criar uma nova senha para o usuário root e depois para criar um novo usuário e sua respectiva senha, é só seguir os passos. Anotar esses dados (senha do root, novo usuário e senha do novo usuário). São muito importantes.

10- Aqui vamos criar a nova senha senha do usuário root

![criar pass](https://user-images.githubusercontent.com/43672635/212269776-ed27a55b-6676-4eca-a8e3-6418d0ad7947.jpeg)

11- Agora vamos escolher a opção 1 (bash).

![opcao1](https://user-images.githubusercontent.com/43672635/212270022-2681da32-4073-4102-85f8-3daa138bbdd9.jpeg)

12- Aqui vamos definir o novo usuário, em seguida será solicitada a senha e a confirmação e então será solicitado o nome real do usuário (basta dar Enter).

![user name](https://user-images.githubusercontent.com/43672635/212333440-deb4cfc2-1f09-4f76-ae35-2d5c272f1a41.jpeg)

13 - Agora será solicitado a definição da linguagem, baseada na timezone detectada. Basta dar Enter...

![enter](https://user-images.githubusercontent.com/43672635/212333795-0eef3850-bc21-4ff2-8772-10e93a15e41e.jpeg)

14 - Após a definição da liguagem já estamos prontos para instalar o armbian na memória eMMC da TV box dando o seguinte comando: ```armbian-install -m yes -a no```

15 - Vai aparecer uma lista de dtb´s e deveremos escolher o mesmo dtb definido no ponto 4, que poderá ser o 518, 520. Note que este número pode mudar conforme a imagem do armbian utilizada, o importante é que se refira ao dtb definido anteriormente (meson-sm1-tx3-bz.dtb ou meson-sm1-tx3-qz.dtb).

16 - Então aparece para escolher o tipo de formatação a ser utilizado na memória eMMC. Escolher 1 (ext4).

17 - Finalmente após alguma espera (nunca interrompa o processo) vamos ter uma msg no final. Então digite ```poweroff``` para finalizar a seção do armbian e desligar a TV box.

18 - Agora devemos desligar a energia, retirar o MicroSD e voltar a ligar a energia.

19 - Vamos acessar novamente o armbian com o usuário root e a nova senha definida para o root (como em 9, agora com a nova senha).
E executar um comando para fazer as atualizações e ajustes do armbian, bem como a instalação do Home Assistant supervisor (possivelmente o armbian será reinializado, necessitanto fazer um novo acesso e repetir o comando).

Devemos copiar e colar este comando:

```curl -sL https://raw.githubusercontent.com/leofig-rj/Hassio-Tanix-TX3/master/script/hassio_tanix_tx3_2025_04.sh | bash -s ```

Estando tudo OK, vai aparecer a tela abaixo. Devemos selecionar ```qemuarm-64``` (movimentar com a seta para baixo e dar enter).

![osagents](https://user-images.githubusercontent.com/43672635/212336624-b7161dfe-b0d1-4440-a8aa-589c95bd3abb.jpeg)

20 - Será instalado o home assistant com o supervisor. E se tudo correr bem, vamos receber a informação de conclusão.

21 - Vamos no nosso browser, acessar http://ip_da_box:8123 e aguardar a instalação. Quando aparecer a tela para criar novo login ou restaurar backup, devemos fazer um reboot para que as alterações seja aplicadas, comandando ```sudo reboot``` na linha de comando.

Boas instalações!

[Instalacao_armbian_hassio_TX3]: https://github.com/maxcalavera81/Instalacao_armbian_hassio_TX3/tree/main
