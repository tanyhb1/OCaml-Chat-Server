let msg_BUFFER_SIZE = 4096

type msg_type = | SEND of int | ACK of int | BAD 

type msg = {
    t: msg_type;
    payload: bytes;
  }

let show_msg_type our_msg_type =
  match our_msg_type with
  | SEND length -> Printf.sprintf "SEND[%d]" length
  | ACK length -> Printf.sprintf "ACK[%d]" length
  | BAD -> "BAD"



