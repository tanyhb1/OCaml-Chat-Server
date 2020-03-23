open MsgType
    
let send_msg socket_descr msg =
  let total = Bytes.length msg in
  let count = Unix.send socket_descr msg 0 (Bytes.length msg) [] in
  if (count < total) then
    let current = ref count in
    while !current < total do
      let pos,len = !current,((Bytes.length msg - !current)) in
      let count = Unix.send socket_descr msg pos len [] in
      current := !current + count;
    done
  
let send_ack socket_descr current_time msg =
  let time = Unix.gettimeofday () in
  Format.printf "@[@.< %s@.@]@[> @]@?" msg;
  let ack = "Affffffff" ^ (Printf.sprintf "Message received! Message sent was: \"%s\", Round-trip time : \"%f\"" msg (time -. !current_time)) in
  current_time := time;
  send_msg socket_descr (Bytes.of_string ack)
