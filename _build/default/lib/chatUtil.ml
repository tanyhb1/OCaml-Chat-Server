open Unix
open Mutex
open PrettyPrinters
open MsgType
open MsgUtil
open MsgSend

let receiving_thread socket_descr socket_addr online _ =
  let buffer = Bytes.create msg_BUFFER_SIZE in
  try
    while !online
    do
      let ready = Thread.wait_timed_read socket_descr 0.015 in
      let current_time = ref (Unix.gettimeofday ()) in
      if (ready) then
        (let count = Unix.recv socket_descr buffer 0 msg_BUFFER_SIZE [] in
         if (count > 0) then
           ( let msg = translate_bytes_to_msg buffer count in
             match msg.t with
             | SEND length ->
               send_ack socket_descr current_time (Bytes.to_string msg.payload)
             | ACK length ->
               print_ack msg.payload
             | BAD ->
               Printf.printf "Error: Received BAD message type\n >";
           )
         else online := false)
    done;
    Thread.exit();
    online := false;
  with
  | exn ->
    ( Thread.exit();
      online := false;
      Printf.printf "Received an exception";
      raise exn)     

let sending_thread socket_descr socket_addr online _ =
  Printf.printf ">"; flush Pervasives.stdout;
  try
    while !online
    do
      (*poll to check if should return/restart *)
      let ready = Thread.wait_timed_read stdin 0.015 in
      if (ready) then        
        ( Printf.printf ">";
          flush Pervasives.stdout;
          try
            let msg = read_line () in
            if (String.length msg > 0) then
              let m = Mutex.create () in
              Mutex.lock m;
              let length = String.length msg in
              let msg_to_be_sent = Bytes.make (length + 9) 'S' in
              Bytes.blit (Bytes.of_string msg) 0 msg_to_be_sent 9 length;
              send_msg socket_descr msg_to_be_sent;
              Mutex.unlock m;
          with End_of_file ->
              online := false;)              
    done;
    Thread.exit();
    online := false;
  with
  | exn ->
    Thread.exit();
    online := false;
    Printf.printf "Received an exception.";
    raise exn
      
let chat socket_descr socket_addr online =
  Printf.printf "\n<<<Ahref Chat Server>>>\n"; flush Pervasives.stdout;
  let t1 = Thread.create (receiving_thread socket_descr socket_addr online) () in
  let t2 = Thread.create (sending_thread socket_descr socket_addr online) () in
  while !online do Thread.delay(0.2) done;
  Thread.join t1;
  Thread.join t2;
  Unix.close socket_descr;
  (* Thread.kill t1;
   * Thread.kill t2; *)

