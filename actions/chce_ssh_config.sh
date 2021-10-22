#!/bin/bash
# Chce SSH config
# Autor: Artur Stefanski

_maybe_show_help() {
  if [ "$1" == "--help" ] || [ "$1" == "-h" ] || [ -z $1 ]; then
    printf "

Chce SSH config
Autor: Artur Stefanski \n
Sposob uzycia: ./chce_ssh_config.sh [host] [-OPCJA WARTOSC]... [-OPCJA WARTOSC]...

-m \t- nazwe serwera np. x999 (dotyczy tylko serwerow mikr.us)
-u \t- nazwa uzytkownika ssh
-p \t- port ssh


przyklady:

./chce_ssh_config.sh -m x999
./chce_ssh_config.sh -m x999 -u user

./chce_ssh_config.sh host
./chce_ssh_config.sh host -u user
./chce_ssh_config.sh host -p port
./chce_ssh_config.sh host -u user -p port
./chce_ssh_config.sh user@host
./chce_ssh_config.sh user@host -p port

"
    exit 1
  fi
}

_maybe_set_mikrus(){
  mikrus="$1"
  ssh_user="$2"

  if [ -n "$mikrus" ] && [ "$mikrus" != "unset" ]; then

      key="$( echo "$mikrus" | grep -o '[^0-9]\+' )"
      declare -A hosts
      hosts["a"]="srv03"
      hosts["b"]="srv04"
      hosts["e"]="srv07"
      hosts["f"]="srv08"
      hosts["g"]="srv09"
      hosts["h"]="srv10"
      hosts["q"]="mini01"
      host="${hosts[$key]}"
      if [ -z "$host" ]; then
          echo "$key to nie serwer mikrus"
          exit 1
      fi
      host="$host.mikr.us"
      port="$(( 10000 + $(echo "$mikrus" | grep -o '[0-9]\+') ))"
      if [ -n "$ssh_user" ] && [ "$ssh_user" != "unset" ]; then
        ssh_user="$ssh_user"
      else
        ssh_user="root"
      fi

    printf "\nWykryto mikrusa: $mikrus
    User: $ssh_user
    Host: $host
    Port: $port\n\n"

    key_name="$USER-$HOSTNAME"
    key_file_name="$ssh_user-$mikrus"

    ssh-keygen -t rsa -b 4096 -C $key_name -f ~/.ssh/$key_file_name

    echo "ssh-copy-id -i ~/.ssh/$key_file_name $ssh_user@$host -p $port"

    ssh-copy-id -i ~/.ssh/$key_file_name $ssh_user@$host -p $port

    printf "\nHost $key_file_name
    HostName $host
    Port $port
    User $ssh_user
    IdentityFile ~/.ssh/$key_file_name\n" >> ~/.ssh/config

    printf "\n\n Utworzono ssh config teraz mozesz uzywac\n"
    echo "ssh $key_file_name"

    exit 1

  fi

}

_maybe_set_another_server(){
  host="$1"
  ssh_user="$2"
  port="$3"
  if [ -z "$port" ] && [ "$host" == "unset" ]; then
    port="22"
  fi


  if [ -n "$host" ] && [ "$host" != "unset" ]; then

    key_name="$USER-$HOSTNAME"
    if [ -n "$user" ] && [ "$ssh_user" != "unset" ]; then
      key_file_name="$ssh_user-$host"
    else
      key_file_name="$host"
    fi

    ssh-keygen -t rsa -b 4096 -C $key_name -f ~/.ssh/$key_file_name

    if [ -n "$ssh_user" ] && [ "$ssh_user" != "unset" ]; then

      ssh-copy-id -i ~/.ssh/$key_file_name $ssh_user@$host -p $port

      printf "\nHost $key_file_name
    HostName $host
    Port $port
    User $ssh_user
    IdentityFile ~/.ssh/$key_file_name\n" >> ~/.ssh/config

    else

      ssh-copy-id -i ~/.ssh/$key_file_name $host -p $port

      printf "\nHost $key_file_name
    HostName $host
    Port $port
    IdentityFile ~/.ssh/$key_file_name\n" >> ~/.ssh/config

    fi

    printf "\n\n Utworzono ssh config teraz mozesz uzywac\n"
    echo "ssh $key_file_name"

    exit 1

  fi

}





first_arg="$1"

_maybe_show_help $first_arg

MIKRUS="unset"
PORT="unset"
SSH_USER="unset"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -m|--mikrus)
      MIKRUS="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--port)
      PORT="$2"
      shift # past argument
      shift # past value
      ;;
    -u|--user)
      SSH_USER="$2"
      shift # past argument
      shift # past value
      ;;
    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done

_maybe_set_mikrus $MIKRUS $SSH_USER

_maybe_set_another_server $first_arg $SSH_USER $PORT

exit 1