///scr_WAN_received_packet(buffer)
var buffer = argument[0]; //Gets our input value when we execute the script [What our buffer will look like: 1,mouse_x,mouse_y]
var message_id = buffer_read(buffer,buffer_u8); //Reads our Unsigned 8Bit Integer from our buffer. [What our buffer will look like: mouse_x,mouse_y] We remove the 1 because when a buffer reads information, it removes that id from the buffer.

//You set which buffer ID you want to send information with. Maybe buffer id 1 sends mouse_x and mouse_y, id 2 sends Damage, id 3 sends health, etc.
switch(message_id) {
    case 1: //If our message ID is equal to 1.
        var mx = buffer_read(buffer,buffer_u16); //Reads our unsigned 16 Bit Integer from our buffer and assigns it to the variable mx. [Buffer equals: mouse_y] -We deleted our mouse_x from the buffer upon reading it
        var my = buffer_read(buffer,buffer_u16); //Reads our unsigned 16 Bit Integer from our buffer and assigns it to the variable my. [Buffer equals:] -We deleted out mouse_y from the buffer upon reading it.
        //Create the click instance on our server
        instance_create(mx,my,obj_click);
        break;
}
