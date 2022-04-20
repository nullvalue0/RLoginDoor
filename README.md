# RLoginDoor
This program is designed to allow an existing winsock connection to be inter-connected to an RLogin server.  An example of this in action (and the reason why I wrote this program) would be if you are running the GameSrv telnet server and want to run TWGS (Trade Wars Game Server) on the same machine, this will allow the connection to be passed from GameSrv to TWGS without having to run TWGS on a separate port for the users.

This was developed in Visual Basic 6.0. I recently discovered a backup of this old code so I am releasing it to github so I never lose it again.

## COMMAND-LINE:

IMPORTANT: Pass all command-lines in the order show below.

RLoginDoor.exe /c{handle} /h{hostname} /p{port} /u1{username1} /u2{username2} [/show] [/TW]

/c{handle}	Client's connection id to the original server.
/h{hostname}	Hostname or IP Address to the RLogin server, which you wish to connect to.
/p{port}	Port of the RLogin server, typically 513.
/u1{username1}	The first parameter to be passed during RLogin connection, typically the username.
/u2{username1}	The second parameter, usually not very important.
[/show]		Optional. Will allow the RLoginDoor window to be shown during execution. Normally it is hidden, but in this mode you will be able to watch the data transfers.
[/TW]		Optional. Pass this argument if you are using RLoginDoor for connecting to TWGS. This option will bypass the first TWGS screen which asks you to select a game. (by automatically pressing the key "A").  In order for this to work, there should be only 1 game set 
up under TWGS, and that game's Description should be set to "GAME 1 - RLoginDoor".

## MORE INFO ON GameSrv/TWGS SETUP:

In GameSrv, add a new item for Trade Wars.  In the command line, and example would be this:

C:\Program Files\RLoginDoor\RLoginDoor.exe /c*H /h127.0.0.1 /p513 /u1*U /u2myserver /TW

*H is the connection handle, and *U is the connected username

The section in the INI file should look something like this:

[L]
Access=10
Command=C:\Program Files\RLoginDoor\RLoginDoor.exe /c*H /h127.0.0.1 /p513 /u1*U /u2myserver /TW
Description=BBS Forums
DropFile=0

In TWGS, Click Configure, then go to the Server tab.  For Game Port, select "513".. Next to that, Protocol should automatically change to "RLogin".  If you want to use the TWGS opening screen bypass feature (/TW at command-line), click the Games tab.  Make sure there is only one game listed there, then rename the description for the first game to "GAME 1 - RLoginDoor".
