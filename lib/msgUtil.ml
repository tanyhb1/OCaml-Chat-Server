open MsgType

(* If shorter than the length of our header,i.e. 9 or less, we know msg is BAD. Otherwise, construct msg from bytes using offsetting by determining if it is a msg to be sent (prefixed by 'S') or if it is an acknowledgement (prefixed by 'A')*)       
let translate_bytes_to_msg bytes len =
  if (len < 10) then
    {t=BAD; payload= Bytes.empty}
  else
    let res = ref (Char.code @@ Bytes.get bytes 1) in
    for i = 1 to 7
    do
      res := !res lor (Char.code (Bytes.get bytes (i + 1)) * Batteries.Int.pow 2 (i * 8));
   done;
    let our_msg_type =
      match (Bytes.get bytes 0) with
      | 'S' -> 
        SEND !res
      | 'A' ->
        ACK !res
      | _ ->
        BAD
    in
    let our_payload = Bytes.sub bytes 9 (len - 9) in
    {t=our_msg_type; payload=our_payload}
