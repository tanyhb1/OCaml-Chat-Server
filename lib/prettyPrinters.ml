open MsgType

let pp_socket_addr socket_addr =
  match socket_addr with
  | Unix.ADDR_INET (addr, port) ->
    Printf.printf "%s:%d\n" (Unix.string_of_inet_addr addr) port;
    flush stdout
  | _ -> Printf.printf "\n"

let print_socket_addr socket_addr =
  pp_socket_addr socket_addr; flush stdout

let print_ack msg =
  let m =  Mutex.create() in
  Mutex.lock m;
  let msg_string = Bytes.to_string msg in
  Format.printf "@[<v 2>@ << %s@.@]@[> @]@?" msg_string;
  Mutex.unlock m


