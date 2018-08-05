///process_packet(buffer)
var buffer = argument0;
var msg_id = buffer_read(buffer,buffer_u8);
var clickx = buffer_read(buffer, buffer_u32);//mousepos
var clicky = buffer_read(buffer, buffer_u32);
//do something with that mouse position
remotex = clickx;
remotey = clicky;
