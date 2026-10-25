# Resumo do sistema exibido no início de cada terminal interativo.
# Copiado para ~/.zsh_sysinfo.zsh pelo oh_my_zsh_setup.sh e carregado pelo ~/.zshrc.
# Usa /proc e /sys (sem forks) para não atrasar o startup; só df e hostname são externos.
# Cor dos rótulos: número 256 em ~/.zsh_sysinfo_color (definido pela paleta do setup).

_zsh_sysinfo() {
  emulate -L zsh

  local c=244 up days hours mins temp= mem_total=0 mem_avail=0 k v ip disk
  [[ -r ~/.zsh_sysinfo_color ]] && c=$(<~/.zsh_sysinfo_color)
  local l="%F{$c}" r="%f"

  read -r up _ < /proc/uptime
  up=${up%.*}
  days=$(( up / 86400 )) hours=$(( up % 86400 / 3600 )) mins=$(( up % 3600 / 60 ))
  local uptime_str="${mins}m"
  (( hours )) && uptime_str="${hours}h ${uptime_str}"
  (( days ))  && uptime_str="${days}d ${uptime_str}"

  local loads=(${=$(</proc/loadavg)})

  [[ -r /sys/class/thermal/thermal_zone0/temp ]] &&
    temp=$(printf '%.1f°C' $(( $(</sys/class/thermal/thermal_zone0/temp) / 1000.0 )))

  while read -r k v _; do
    case $k in
      MemTotal:)     mem_total=$v ;;
      MemAvailable:) mem_avail=$v; break ;;
    esac
  done < /proc/meminfo
  local mem_str
  mem_str=$(printf '%.1f/%.1fG' $(( (mem_total - mem_avail) / 1048576.0 )) $(( mem_total / 1048576.0 )))

  local df_out=(${(f)"$(df -h --output=used,size,pcent / 2>/dev/null)"})
  local d=(${=df_out[2]})
  disk="$d[1]/$d[2] (${d[3]//\%/%%})"

  ip=${${=:-$(hostname -I 2>/dev/null)}[1]}

  # Sem banner, o hostname faz o papel de título.
  [[ -f ~/.zsh_banner ]] || print -P "%B${l}${HOST}${r}%b"
  print -P "${l}up${r} ${uptime_str}  ${l}load${r} ${loads[1]}${temp:+  ${l}temp${r} $temp}"
  print -P "${l}mem${r} ${mem_str}  ${l}disk${r} ${disk}${ip:+  ${l}ip${r} $ip}"
  print
}

_zsh_sysinfo
unfunction _zsh_sysinfo
