///save_game()
//This script will save our game
if (file_exists("Save.sav")) file_delete("Save.sav");   //If the save file exists, delete it so we can overwrite it.

ini_open("Save.sav");                                   //Opens the save file for reading and writing.

//-----------------------------------------------------------------------------------------------------------------
// Information to store in our save file
//-----------------------------------------------------------------------------------------------------------------
//Use ini_write_real(sectionID,Key,informationToBeStored) for numbers
//Use ini_write_string(secionID,Key,informationToBeStored) for strings

//Example:
//ini_write_real("Player","Points",score)
//ini_write_string("Player","Name",name)
//ini_write_string("Useless Information","What",health)
//
//will come out as this in the save file.
//
//[Player]
//Name = Paul
//Points = 0
//
//[Useless Information]
//What = 100

ini_write_string("Player","UserID",username);           //Writes our username
//-----------------------------------------------------------------------------------------------------------------
ini_close();                                            //Closes our ini file for reading and writing.
