<h1 align="center">
  Holy C, anyone?
</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Node%20does%20not%20exist%20within%20these%20lands-3C873A?logo=node.js&logoColor=white" alt="No Node badge">
  <img src="https://img.shields.io/badge/Discord.js-v14%20(or%20at%20least%20I%20hope%20I)-5865F2?logo=discord&logoColor=white" alt="Discord.js v14 badge">
  <img src="https://img.shields.io/badge/Status-Kill%20Me%20Already-red" alt="Status Kill Me Already badge">
  <img src="https://img.shields.io/badge/License-LMFAO%20You%20Think-lightgrey" alt="License LMFAO badge">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/language-HolyC-orange" alt="HolyC language badge">
  <img src="https://img.shields.io/badge/Discord%20Gateway-v10-5865F2?logo=discord&logoColor=white" alt="Discord Gateway v10 badge">
  <img src="https://img.shields.io/badge/API-WIP-yellow" alt="API WIP badge">
  <img src="https://img.shields.io/badge/KSON-Parser-blueviolet" alt="KSON parser badge">
  <img src="https://img.shields.io/badge/made%20with-Agony%20and%20Faith%20in%20HolyC-purple" alt="Made with pain badge">
</p>

<h3 align="center">
<strong>I have no tears and I want to cry.</strong><br>
<i>ScIeNtIfIc pUrPoSes.</i>

  Also, in Japanese, Holy シ!!
</h3>

## Table of Contents
- [Okay, Seriously Though](#okay-seriously-though)
- [Why Does This Exist](#why-does-this-exist)
- [Roadmap](#roadmap)
- [What's KSON?](#whats-kson)
- [Building](#building)

---

## Okay, Seriously Though

This is an AI-assisted implementation of a Discord gateway client built on the HolyC Library from Terry A. Davis, using the HolyC Compiler Library from James Barford.

> I uploaded a modified `main.c` linked with `-lssl` and `-lcrypto`. You'll need to replace the compiler's stock `main.c` with this one after cloning. I don't bear any responsibility if it breaks on you.

## Why Does This Exist

My dumbass thought "can HolyC talk to Discord's Gateway?" and it had become a question that I needed answers to. Nobody was going to stop me from finding out the hard way, unfortunately. So here you go — hand-rolled TLS, WebSocket framing, and a JSON parser included. 

I cried multiple times making this. Prayers to the 5 rivers I evaporated.

## Roadmap

| Progress | Section | Feature | Current|
| :---: | --- | --- | --- |
| ✔ | Base | TLS | |
| ✔ | Base | WebSocket handshake | |
| ✔ | Base | WebSocket frames | |
| ✔ | KSON | ParseNumber | |
| ✔ | KSON | ParseString | |
| ✔ | KSON | ParseObject | |
| ✔ | KSON | ParseNull | |
| ✔ | KSON | ParseBoolean | |
| ✔ | KSON | ParseArray | |
| ✔ | KSON | KSONStringify (QoL) | |
| ✔ | Gateway | Hello | |
| ✔ | Gateway | Heartbeat | |
| ✔ | Gateway | Identify | |
| ✔ | API | READY event |Finished |
| ⬜ | API | Event dispatcher |<--- We are here --- |
| ⬜ | API | Bot API | |



## What's KSON?

<details>
<summary>Click to expand the tangent</summary>

<br>

<img width="480" height="480" alt="KSON meme" src="https://github.com/user-attachments/assets/89ab8259-bed3-4493-afc9-ff28edc6378a" />

## KSON (KSON Script Object Notation) is a JSON processor and parser inspired by a mistake of mine, built with HolyC specifically for this repository.

<img width="861" height="439" alt="image" src="https://github.com/user-attachments/assets/30b4b4ea-53e2-4cef-82ce-b4c07ff8f073"/><br>
- The aforementioned mistake

</details>

## Building

```bash
# Clone the HolyC compiler
git clone https://github.com/jamesbarford/holyc-lang.git
cd holyc-lang

# Replace the stock main.c with the modified one from this repo
cp /path/to/DiscordHC/main.c ./main.c

# Build with SSL/crypto linked in
make LDFLAGS="-lssl -lcrypto"
```

No guarantees. God Bless(?)
<br>
<img width="736" height="480" alt="f6a6922589435655151484d7a78d10cf_2059325017191946237" src="https://github.com/user-attachments/assets/0cf284c6-24d9-4a46-8ddf-bfced4ecd611" />


---

### About
Proof of concept. I can **NOT** guarantee that this will work.

