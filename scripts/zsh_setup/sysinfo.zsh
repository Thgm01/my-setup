# Resumo do sistema (estilo MOTD de servidor) exibido no início de cada terminal interativo.
# Copiado para ~/.zsh_sysinfo.zsh pelo oh_my_zsh_setup.sh e carregado pelo ~/.zshrc.
# Lê quase tudo de /proc e /sys; comandos externos (df, ip, who, systemctl, docker) só quando existem.
# Cor dos rótulos: número 256 em ~/.zsh_sysinfo_color (definido pela paleta do setup).

_zsh_sysinfo() {
  emulate -L zsh -o extended_glob

  local c=244
  [[ -r ~/.zsh_sysinfo_color ]] && c=$(<~/.zsh_sysinfo_color)
  local dim="%F{240}" r="%f" sep="  %F{240}·%f  "
  local k v line f

  # Cor por nível de uso: normal (paleta), alerta (amarelo), crítico (vermelho).
  _level() { (( $1 >= $3 )) && print -n 160 || { (( $1 >= $2 )) && print -n 178 || print -n $c } }

  # Barra de 20 células preenchida pelo percentual, seguida do percentual.
  _bar() {
    local pct=$1 n=$(( ($1 * 20 + 50) / 100 ))
    (( n > 20 )) && n=20
    print -n "%F{$(_level $1 70 90)}${(l:n::━:)}%F{238}${(l:20-n::━:)}%f ${(l:3:)pct}%%"
  }

  # Linha "rótulo  valor" com rótulo alinhado.
  _row() { print -P " %F{$c}${(r:9:)1}%f $2" }

  # --- coleta -------------------------------------------------------------

  local os= model=
  [[ -r /etc/os-release ]] && while IFS= read -r line; do
    [[ $line == PRETTY_NAME=* ]] && { os=${${line#PRETTY_NAME=}//\"/}; break }
  done < /etc/os-release
  [[ -r /proc/device-tree/model ]] && model=${${$(</proc/device-tree/model)//$'\0'/}%%[[:space:]]#}
  [[ -z $model && -r /sys/class/dmi/id/product_name ]] && model=$(</sys/class/dmi/id/product_name)

  local cores=0
  while read -r k _; do [[ $k == processor ]] && (( cores++ )); done < /proc/cpuinfo
  (( cores )) || cores=1

  local up days hours mins
  read -r up _ < /proc/uptime
  up=${up%.*}
  days=$(( up / 86400 )) hours=$(( up % 86400 / 3600 )) mins=$(( up % 3600 / 60 ))
  local uptime_str="${mins}m"
  (( hours )) && uptime_str="${hours}h ${uptime_str}"
  (( days ))  && uptime_str="${days}d ${uptime_str}"

  local loads=(${=$(</proc/loadavg)})
  local load_pct=$(( ${loads[1]} * 100 / cores ))
  load_pct=${load_pct%.*}

  # Temperatura da CPU: zona "cpu*" se existir, senão a zona 0.
  local temp_c= zone=
  for f in /sys/class/thermal/thermal_zone<->/type(N); do
    [[ $(<$f) == (#i)cpu* ]] && { zone=${f:h}; break }
  done
  [[ -z $zone && -d /sys/class/thermal/thermal_zone0 ]] && zone=/sys/class/thermal/thermal_zone0
  [[ -n $zone && -r $zone/temp ]] && temp_c=$(( $(<$zone/temp) / 1000 ))

  # GPU (Jetson): carga em 0..1000.
  local gpu_pct=
  for f in /sys/devices/gpu.0/load /sys/devices/platform/gpu.0/load \
           /sys/devices/platform/bus@0/17000000.gpu/load /sys/devices/platform/17000000.gpu/load; do
    [[ -r $f ]] && { gpu_pct=$(( $(<$f) / 10 )); break }
  done

  local mem_total=0 mem_avail=0 swap_total=0 swap_free=0
  while read -r k v _; do
    case $k in
      MemTotal:)     mem_total=$v ;;
      MemAvailable:) mem_avail=$v ;;
      SwapTotal:)    swap_total=$v ;;
      SwapFree:)     swap_free=$v ;;
    esac
  done < /proc/meminfo
  local mem_used=$(( mem_total - mem_avail )) swap_used=$(( swap_total - swap_free ))

  local df_out=(${(f)"$(df -h --output=used,size,pcent / 2>/dev/null)"})
  local d=(${=df_out[2]})

  local procs=(/proc/<->(N/))
  local users=(${(f)"$(who 2>/dev/null)"})

  # IPs por interface, ignorando bridges e interfaces virtuais do Docker.
  local nets=() iface addr
  for line in ${(f)"$(ip -4 -o addr show scope global 2>/dev/null)"}; do
    local w=(${=line}); iface=$w[2] addr=${w[4]%/*}
    [[ $iface == (docker*|br-*|veth*|virbr*) ]] && continue
    nets+=("${dim}${iface}${r} ${addr}")
  done

  local failed=
  (( $+commands[systemctl] )) && failed=${#${(f)"$(systemctl --failed --no-legend --plain 2>/dev/null)"}}

  local containers=
  (( $+commands[docker] )) && [[ -w /var/run/docker.sock ]] &&
    containers=${#${(f)"$(docker ps -q 2>/dev/null)"}}

  # Atualizações: Ubuntu mantém esse resumo em cache (mesmo usado pelo MOTD).
  local updates=
  [[ -r /var/lib/update-notifier/updates-available ]] &&
    updates=${${(M)${(f)"$(</var/lib/update-notifier/updates-available)"}:#*can be applied immediately*}%% *}

  # --- saída --------------------------------------------------------------

  # Sem banner, o hostname faz o papel de título.
  [[ -f ~/.zsh_banner ]] || print -P "%B%F{$c}${HOST}%f%b"
  print -P " ${dim}${model:+$model  ·  }${os}  ·  $(</proc/sys/kernel/osrelease) ${CPUTYPE}${r}"
  print

  local sys="${uptime_str}${sep}%F{$c}users%f ${#users}${sep}%F{$c}procs%f ${#procs}"
  [[ -n $temp_c ]] && sys+="${sep}%F{$c}temp%f %F{$(_level $temp_c 70 80)}${temp_c}°C%f"
  _row up "$sys"
  _row cpu "$(_bar $load_pct)  ${dim}load ${loads[1,3]} · ${cores} cores${r}"
  [[ -n $gpu_pct ]] && _row gpu "$(_bar $gpu_pct)"
  _row mem "$(_bar $(( mem_used * 100 / mem_total )))  ${dim}$(printf '%.1f/%.1fG' $(( mem_used / 1048576.0 )) $(( mem_total / 1048576.0 )))${r}"
  (( swap_total )) &&
    _row swap "$(_bar $(( swap_used * 100 / swap_total )))  ${dim}$(printf '%.1f/%.1fG' $(( swap_used / 1048576.0 )) $(( swap_total / 1048576.0 )))${r}"
  _row disk "$(_bar ${d[3]%\%})  ${dim}${d[1]}/${d[2]} em /${r}"
  (( $#nets )) && _row net "${(pj:$sep:)nets}"

  local svc=()
  [[ -n $failed ]] && { (( failed )) && svc+=("%F{160}${failed} units falhando%f") || svc+=("systemd ok") }
  [[ -n $containers ]] && svc+=("docker ${containers} rodando")
  (( $#svc )) && _row services "${(pj:$sep:)svc}"

  local alerts=()
  [[ -n $updates && $updates != 0 ]] && alerts+=("%F{178}${updates} atualizações%f")
  [[ -f /var/run/reboot-required ]] && alerts+=("%F{160}reboot necessário%f")
  (( $#alerts )) && _row avisos "${(pj:$sep:)alerts}"
  print

  unfunction _level _bar _row
}

_zsh_sysinfo
unfunction _zsh_sysinfo
