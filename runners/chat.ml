open ChatUtil
open PrettyPrinters

(* Set default host to localhost and port to 8888.
For server, server_mode = true. For client, server_mode = false. *)
let default_host = ref "127.0.0.1"
let default_port = ref 8888
let server_mode = ref true
let started = ref false
let set_host string =
  default_host := string

let set_server_mode string =
  if (string = "client") then
    server_mode := false
  else server_mode := true

(* let filename_param =
 *   let open Core.Command.Param in
 *   anon ("filename" %: string)
 * 
 * let command =
 *   let open Core.Command in
 *   let open Param in
 *   basic
 *     ~summary: "Ahrefs chat server."
 *     ~readme: (fun () -> "Basic usage: chat [-h <host>] [-p <port>].\n Host and port are set to localhost by default. Starts as server by default, specify server_mode by using optional flag [-m 'client'/'server']")
 *     [%map_open    
 *       let host = flag "h" (required string) ~doc:"Host to connect to. Default localhost (127.0.0.1)"
 *       in let port = flag "p" (required int) ~doc:"Port to listen to. Default 8888"
 *       in let server_mode = flag "m" (required string) ~doc:"Server_Mode. Default: server"
 *       in
 *       fun () -> 
 *         set_host host;
 *         set_server_mode server_mode
 *     ] *)

let parse_flags_and_set_host_and_port()=
  let usage_msg = "Basic usage: chat [-h <host>] [-p <port>].\n
 Host and port are set to localhost by default. Starts as server by default, specify server_mode by using optional flag [-m 'client'/'server']" in
  let flags =
    [("-m", Arg.Symbol (["client"; "server"], set_server_mode), " By default, starts as server");
     ("-h", Arg.String set_host, "Host to connect to: default localhost (127.0.0.1)");
     ("-p", Arg.Set_int default_port, "Port to connect to: default 8888");] in
  Arg.parse flags (fun a -> ()) usage_msg
    
let () =
  parse_flags_and_set_host_and_port();
  let socket_descr = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
  let socket_addr = Unix.ADDR_INET (Unix.inet_addr_of_string !default_host, !default_port) in
  if (!server_mode) then
    ( Unix.bind socket_descr socket_addr;
      Unix.listen socket_descr 1;
      while true do
        if (not !started) then
          (started := true;
           Printf.printf "Server started\n ")
        else Printf.printf "Server restarted\n";
        (print_socket_addr socket_addr;
         let client_socket_descr, client_socket_addr = Unix.accept socket_descr in
         let online = ref true in
         Printf.printf "Received a connection from:\n ";
         print_socket_addr client_socket_addr;
         chat client_socket_descr client_socket_addr online;
         Printf.printf "Client exited chat.\n";)
      done;
      Unix.close socket_descr;)
  else
    ( let online = ref true in
      Printf.printf "Attempting connection as client to:\n";
      print_socket_addr socket_addr;
      Printf.printf "as ";
      print_socket_addr (Unix.getsockname socket_descr);
      Unix.connect socket_descr socket_addr;
      chat socket_descr socket_addr online)

