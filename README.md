<p align="center"> <img src="https://img.shields.io/badge/Node%20doesn't%20exist%20within%20these%20lands%2B-3C873A?logo=node.js&logoColor=white"/> <img src="https://img.shields.io/badge/Discord.js-v14(or%20at%20least%20I%20hope)-5865F2?logo=discord&logoColor=white"/> <img src="https://img.shields.io/badge/Status-Kill%20Me%20Already-red"/> <img src="https://img.shields.io/badge/License-MIT-lightgrey"/> </p> <p align="center"> <b>I wanna cry.</b> <br><i>ScIeNtIfIc pUrPoSes</i>. <br/> </p>



<h1 align="center" font-size=20px>
  Holy C, anyone?
</h1>




# Okay, Seriously though;
----

## This is an AI-assisted implementation of a discord wrapper using the HolyC Library from Terry A. Davis and the HolyC Compiler Library from James Barford. 

- The main.c has been modified to apply openSSL methods. Therefore you will have to replace the main.c after cloning the compiler with git.


-----

I'm still in the process of applying Discord's Protocol over the TLS/Websocket methods, so it will likely be still a long time before I can use it for actual applications.


## Roadmap
----
|Progress|Base Part|
| ---- | ---- |
|✔|TLS|
|✔|WebSocket handshake |
|✔ |WebSocket frames |

|Progress|KSON Part|
| ---- | ---- |
|✔ |ParseNumber |
|✔ |ParseString |
|⬜|ParseObject |
|⬜|ParseNull |
|⬜|ParseBoolean |
|⬜|ParseArray |
|⬜|KSONStringify |

|Progress|Gateway|
| ---- | ---- |
|⬜|Gateway Hello |
|⬜|Heartbeat |
|⬜|Identify |

|Progress|API|
| ---- | ---- |
|⬜|READY event |
|⬜|Event dispatcher |
|⬜|Bot API |

# So what the fuck is KSON?
----
## KSON (Katsuragi Script Object Notation) is just a custom JSON Processor and Parser built with HolyC and for this repository specifically.

It's just JSON with microtransaction clothes.
