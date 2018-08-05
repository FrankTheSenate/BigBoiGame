///load_game()
//This script will load our game.
if (file_exists("Save.sav")) {

ini_open("Save.sav");//Opens our file for reading and writing

//-----------------------------------------------------------------------------------------------------------------
// Information to load from our save file
//-----------------------------------------------------------------------------------------------------------------
//Use ini_read_real(sectionID,Key,defaultValue) for numbers
//Use ini_read_string(secionID,Key,defaultValue) for strings

//Example: ini_read_real("Player","Points",0) will return this from the save file.
//[Player]
//Points = (Whatever was saved for this key).

username = ini_read_string("Player","UserID","");      //Reads our Username.

//-----------------------------------------------------------------------------------------------------------------

ini_close();
}
