# LEAD Docker

## Dependências: [Docker](https://docs.docker.com/engine/install/ubuntu/).

## 1. Instalação

Arquitetura adaptada do excelente grupo de pesquisa croata: [Larics Lab](https://github.com/larics/uav_ros_simulation). 

```
mkdir -p ~/drone_env/src # Criação de uma pasta catkin
cd ~/drone_env/src/
git clone https://github.com/luccagandra/cbr_simulation.git
cd cbr_simulation/
. docker_build.sh
. docker_run.sh
```

## Opcional - QGroundControl original

```
sudo usermod -a -G dialout $USER
sudo apt-get remove modemmanager
```

Download QGroundControl (Fora do workspace src!)
```
cd ~/drone_env
wget https://s3-us-west-2.amazonaws.com/qgroundcontrol/latest/QGroundControl.AppImage
chmod +x ./QGroundControl.AppImage 
./QGroundControl.AppImage
```


## Opcional - Aliases no .bashrc

Alias servem como substitudos de um ou mais comandos no terminal. Recomendo a inserção destes em seu .bashrc
```
alias bashrc='nano ~/.bashrc'
alias refresh='source ~/.bashrc'
alias kill_gazebo='killall gzserver && killall gzclient'
alias kill_ros='killall -9 roscore && killall -9 rosmaster'
```

# 2. Execução


## Comandos úteis TMUX (Simulação aberta)

Sempre tecle <kbd>Ctrl</kbd> + <kbd>b</kbd> para realizar qualquer ação no TMUX.

(<kbd>Ctrl</kbd> + <kbd>b</kbd>) + <kbd>k</kbd> : Fecha todos os programas no TMUX

(<kbd>Ctrl</kbd> + <kbd>b</kbd>) + <kbd>[</kbd> : Sobe ou desce as linhas em alguma janela

(<kbd>Ctrl</kbd> + <kbd>b</kbd>) + <kbd>↑ ↓ → ←</kbd> : Muda as janelas

(<kbd>Ctrl</kbd> + <kbd>b</kbd>) + <kbd>1 2 3 4</kbd> : Muda as abas

## Comandos úteis Docker (Fora do docker)

### Problema de autorização "X11 Xauthority": 

```
cd ~/drone_env/src/cbr_simulation
. restart_container.bash
```

### Fechar docker:
```
docker stop lead_drone_latest
```

# TO-DO

- Inserir mais dependências no dockerfile
- Resolver problema de xauth-docker
