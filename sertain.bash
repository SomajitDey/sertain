# sertain: http SERver ToolchAIN library
# Defines functions, combining which, one can easily make a basic http server using ncat and jq
# No need for nodejs, go etc. Just pure bash scripting.

httparse(){
  # Description: http request header parser. Reads http request headers. Output is json.
  # Parameters: none
  # TODO: parse query strings from path

  local method path version
  read -rd $'\r\n' method path version && read

  echo "{"

  printf "\"method\": \"${method//\"/\\\"}\"" 
  printf ",\n\"path\": \"${path//\"/\\\"}\"" 
  printf ",\n\"version\": \"${version//\"/\\\"}\"" 

  local header value
  while IFS=: read -rd $'\r\n' header value && read && [[ -n "${header}" ]];do
    value="${value//\"/\\\"}"
    echo ","
    echo -n "\"${header}\": \"${value#' '}\""
  done

  echo -e "\n}"

  return 0
  ### Next read should be from payload
}; export -f httparse

status(){
  # Description: Print the response status-line for v1.1 based on given status-code and reason-phrase.
  # Parameters: $1=status-code $2=reason-phrase
  # TODO:
  
  printf "HTTP/1.1 ${1} ${2}\r\n"
  
  return 0
}; export -f status

header(){
  # Description: Print header with given key and value.
  # Parameters: $1=header-key $2=header-value
  # TODO:
  
  if [[ -n "${1}" ]]; then
    printf "${1}: ${2}\r\n"
  else
    printf "\r\n"
  fi
  
  return 0
}; export -f header


dl_payload(){
  # Description: Read and output client-sent payload.
  # Parameters: Content-Length as obtained from: httparse | jq -r '."Content-Length"'
  # TODO:

  if (("${1}"==0));then return; fi # No content
  local payload
  read -N "${1}" payload
  printf "${payload}"
  
  return 0
}; export -f dl_payload

dl_stream(){
  # Description: Read and output client-sent stream. Decide if it is stream using Transfer-Encoding header
  # Parameters: None
  # TODO:

  while :;do
    local size
    read -d $'\r\n' size && read || break # In case of broken connection to client
    if ((size==0)); then read && break; fi # Check if end of stream
    local chunk
    read -d $'\r\n' -N "$((16#${size}))" chunk && read # Convert chunk-size to decimal from hex
    printf "${chunk}"
  done
  
  return 0
}; export -f dl_stream

ul_payload(){
  # Description: Write payload to be uploaded and the corresponding headers at stdout.
  # Parameters: Filename to read payload from. Otherwise read payload from stdin.
  # TODO:

  local payload_file="${1:-/dev/stdin}"
  local buffer="$(mktemp /tmp/XXXXX)"
  trap "rm -f ${buffer}" return exit
  cat "${payload_file}" > "${buffer}" # Just to manage file/stdin duality
  
  header "Connection" "close"
  header "Content-Length" "$(wc -c ${buffer}|awk '{ print $1 }')"
  header
  cat "${buffer}"
  
  return 0  
}; export -f ul_payload

ul_stream(){
  # Description: Write stream to be uploaded and the corresponding headers at stdout.
  # Parameters: None
  # Remarks: This function runs an infinite loop. To denote end of stream, send SIGTERM.
  # pid required to send SIGTERM is output at stderr
  # TODO:
  
  header "Connection" "keep-alive"
  header "Transfer-Encoding" "chunked"
  header
  
  ( echo "${BASHPID}" >&2
  
  trap 'loop=false' TERM
  
  local loop=true
  local size char chunk
  
  while "${loop}"; do
    chunk=
    size=0
    while read -r -s -d '' -N1 -t 0.1 char; do
      ((size++))
      chunk="${chunk}${char}"
    done
    if ((size!=0));then
      printf "%x\r\n" "${size}"
      printf "${chunk}\r\n"
    fi
  done
  printf "0\r\n\r\n" # End of stream marker
  
  exit 0)
  
  return 0
}; export -f ul_stream
