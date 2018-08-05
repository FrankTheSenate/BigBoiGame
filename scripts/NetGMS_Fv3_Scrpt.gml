#define Net_Setup
///Net_Setup( tcp , udp )
   //TCP Setup
   if ( argument[ 0 ] == true ) {
      globalvar NetTcp_Sck , NetTcp_Bfr , NetTcp_Con;
      globalvar NetTcp_Dis , NetTcp_Ipa , NetTcp_Prt;
      globalvar NetTcp_Que , NetTcp_Lst;
      
      NetTcp_Sck = -1; NetTcp_Bfr = -1;
      NetTcp_Con = -1; NetTcp_Dis = -1;
      NetTcp_Ipa = -1; NetTcp_Prt = -1;
      NetTcp_Lst = -1; NetTcp_Que = -1;
   }
   
   //Udp Setup
   if ( argument[ 1 ] == true ) {
      globalvar NetUdp_Sck , NetUdd_Hst , NetUdp_Bfr;
      globalvar NetUdp_Ipa , NetUdp_Prt , NetUdp_Map;
      
      NetUdp_Sck = -1; NetUdp_Hst = -1;
      NetUdp_Bfr = -1; NetUdp_Ipa = -1;
      NetUdp_Prt = -1; NetUdp_Map = -1;
   }

#define Net_TcpServer
///Net_TcpServer( port , maxclients , buffer size )
   NetTcp_Sck = network_create_server( network_socket_tcp , argument[ 0 ] , argument[ 1 ] );
   NetTcp_Bfr = buffer_create( argument[ 2 ] , buffer_fixed , 1 );
   NetTcp_Lst = ds_list_create();
   NetTcp_Que = ds_list_create();
   NetTcp_Prt = argument[ 0 ];
   return ( NetTcp_Sck >= 0 ) + ( ( NetTcp_Sck < 0 ) * -1 );

#define Net_TcpClientRaw
///Net_TcpClientRaw( port , url / ip , buffer size )
   NetTcp_Sck = network_create_socket( network_socket_tcp );
   NetTcp_Bfr = buffer_create( argument[ 2 ] , buffer_fixed , 1 );
   NetTcp_Prt = argument[ 0 ];
   NetTcp_Ipa = argument[ 1 ];
   var result = network_connect_raw( NetTcp_Sck , argument[ 1 ] , argument[ 0 ] );
   return ( result >= 0 ) + ( ( result < 0 ) * -1 );

#define Net_TcpClient
///Net_TcpClient( port , url / ip , buffer size )
   NetTcp_Sck = network_create_socket( network_socket_tcp );
   NetTcp_Bfr = buffer_create( argument[ 2 ] , buffer_fixed , 1 );
   NetTcp_Prt = argument[ 0 ];
   NetTcp_Ipa = argument[ 1 ];
   var result = network_connect( NetTcp_Sck , argument[ 1 ] , argument[ 0 ] );
   return ( result >= 0 ) + ( ( result < 0 ) * -1 );

#define Net_UdpServer
///Net_UdpServer(  port , maxclients , ip , buffer size )
   NetUdp_Sck = network_create_socket( network_socket_udp );
   NetUdp_Hst = network_create_server( network_socket_udp , argument[ 0 ] , argument[ 1 ] );
   NetUdp_Bfr = buffer_create( argument[ 3 ] , buffer_fixed , 1 );
   NetUdp_Prt = argument[ 0 ];
   NetUdp_Ipa = argument[ 2 ];
   NetUdp_Map = ds_map_create();
   return ( NetUdp_Sck >= 0 && NetUdp_Hst >= 0 ) + ( ( NetUdp_Sck < 0 && NetUdp_Hst < 0 ) * -1 );

#define Net_UdpDestroy
///Net_UdpDestroy()
   if ( NetUdp_Sck != -1 ) {
      network_destroy( NetUdp_Sck );
      network_destroy( NetUdp_Hst );
      buffer_delete( NetUdp_Bfr );
      ds_map_destroy( NetUdp_Map );
      NetUdp_Sck = -1;
      NetUdp_Hst = -1;
      NetUdp_Bfr = -1;
      NetUdp_Map = -1;
   }

#define Net_TcpDestroy
///Net_TcpDestroy()
   if ( NetTcp_Sck != -1 ) {
      network_destroy( NetTcp_Sck );
      buffer_delete( NetTcp_Bfr );
      NetTcp_Sck = -1;
      NetTcp_Bfr = -1;
      
      if ( NetTcp_Lst != -1 ) {
         ds_list_destroy( NetTcp_Lst );
         ds_list_destroy( NetTcp_Que );
         NetTcp_Lst = -1;
         NetTcp_Que = -1;
      }
   }

#define Net_Handle
///Net_Handle( script id )
   switch( ds_map_find_value( async_load , "type" ) ) {
      case network_type_connect:
         NetTcp_Con = ds_map_find_value( async_load , "socket" );
         ds_list_add( NetTcp_Lst , NetTcp_Con );
         ds_list_add( NetTcp_Que , NetTcp_Con );
      break;
      case network_type_disconnect:
         NetTcp_Dis = ds_map_find_value( async_load , "socket" );
         var index = ds_list_find_index( NetTcp_Lst , NetTcp_Dis );
         var queue = ds_list_find_index( NetTcp_Que , NetTcp_Dis );
         
         if ( index != -1 ) {
            ds_list_delete( NetTcp_Lst , index );
         }
         
         if ( index != -1 ) {
            ds_list_delete( NetTcp_Que , queue );
         }
      break;
      case network_type_data:
            var buffer = ds_map_find_value( async_load , "buffer" );
            var bsize = ds_map_find_value( async_load , "size" );
            buffer_seek( buffer , buffer_seek_start , 0 );
            var msgid = buffer_read( buffer , buffer_u8 );
            script_execute( argument[ 0 ] , buffer , bsize , msgid );
      break;
   }

#define Net_TcpCast
///Net_TcpCast( msgid , server name )
   var buffer = NetTcp_Bfr;
   buffer_seek( buffer , buffer_seek_start , 0 );
   buffer_write( buffer , buffer_u8 , argument[ 0 ] );
   buffer_write( buffer , buffer_string , string( argument[ 1 ] ) );
   network_send_broadcast( NetTcp_Sck , NetTcp_Prt , buffer , buffer_tell( buffer ) );

#define Net_UdpCast
///Net_UdpCast( msgid , server name )
   var buffer = NetUdp_Bfr;
   buffer_seek( buffer , buffer_seek_start , 0 );
   buffer_write( buffer , buffer_u8 , argument[ 0 ] );
   buffer_write( buffer , buffer_string , string( argument[ 1 ] ) );
   network_send_broadcast( NetUdp_Sck , NetUdp_Prt , buffer , buffer_tell( buffer ) );

#define Net_Bytes
///Net_Bytes( buffer id )
   return buffer_tell( argument[ 0 ] );

#define Net_Analyze
///Net_Analyze( msgid )
   var buffer = NetTcp_Bfr;
   buffer_seek( buffer , buffer_seek_start , 0 );
   buffer_write( buffer , buffer_u8 , argument[ 0 ] );
   var result = network_send_packet( NetTcp_Sck , buffer , buffer_tell( buffer ) );
   return ( result >= 0 ) + ( ( result < 0 ) * -1 );

#define Net_Inquire
///Net_Inquire( buffer )
   var server_name = buffer_read( argument[ 0 ] , buffer_string );
   var server_ipaddress = ds_map_find_value( async_load , "ip" );
   ds_map_add( NetUdp_Map , server_name , server_ipaddress );

#define Net_Enqueue
///Net_Enqueue( msgid )
   var position = 0;
   var buffer = NetTcp_Bfr;
   
   repeat( ds_list_size( NetTcp_Que ) ) {
      var socket = ds_list_find_value( NetTcp_Que , position );
      buffer_seek( buffer , buffer_seek_start , 0 );
      buffer_write( buffer , buffer_u8 , argument[ 0 ] );
      buffer_write( buffer , buffer_u16 , socket );
      network_send_packet( socket , buffer , buffer_tell( buffer ) );
      position += 1;
   }

#define Net_Requeue
///Net_Requeue( buffer , msgid )
   var queued_socket = buffer_read( argument[ 0 ] , buffer_u16 );
   var socket = NetTcp_Sck , buffer = NetTcp_Bfr;
   
   buffer_seek( buffer , buffer_seek_start , 0 );
   buffer_write( buffer , buffer_u8 , argument[ 1 ] );
   buffer_write( buffer , buffer_u16 , queued_socket );
   network_send_packet( socket , buffer , buffer_tell( buffer ) );
   
   return queued_socket;

#define Net_Dequeue
///Net_Dequeue( buffer )
   var socket = buffer_read( argument[ 0 ] , buffer_u16 );
   var index = ds_list_find_index( NetTcp_Que , socket );
   
   if ( index != -1 ) {
      ds_list_delete( NetTcp_Que , index );
   }

#define Net_TcpAssets
///Net_TcpAssets( asset )
   switch( argument[ 0 ] ) {
      case 0: return NetTcp_Sck; break;
      case 1: return NetTcp_Bfr; break;
      case 2: return NetTcp_Con; break;
      case 3: return NetTcp_Dis; break;
      case 4: return NetTcp_Ipa; break;
      case 5: return NetTcp_Prt; break;
      case 6: return NetTcp_Lst; break;
      case 7: return NetTcp_Que; break;
      case 8: return ds_list_size( NetTcp_Lst ); break;
      case 9: return ds_list_size( NetTcp_Que ); break;
   }

#define Net_UdpAssets
///Net_UdpAssets( asset )
   switch( argument[ 0 ] ) {
      case 0: return NetUdp_Sck; break;
      case 1: return NetUdp_Hst; break;
      case 2: return NetUdp_Bfr; break;
      case 3: return NetUdp_Ipa; break;
      case 4: return NetUdp_Prt; break;
      case 5: return NetUdp_Map; break;
      case 6: return ds_map_size( NetUdp_Map ); break;
   }

