Jai module to enable collecting Performance-Monitoring Counters (PMCs) thread-safe, continuously on a running program.

Inspired (and significantly aided!) by ["The Computer Enhance 2024 International Event Tracing for Windows Halloween
Spooktacular Challenge"](https://www.computerenhance.com/p/announcing-the-etw-halloween-spooktacular).

Includes bindings to the Event Tracing for Windows (ETW) api in the Windows_Event_Tracing module, with examples ported from mmozeiko's gists [etw](https://gist.github.com/mmozeiko/299fc8ff993b9c671eb7fd5c7bd87d51) and [miniperf](https://gist.github.com/mmozeiko/bd5923bcd9d20b5b9946691932ec95fa?ts=4).

A pretty silly example of collecting pmcs per frame and changing the active pmcs - https://youtu.be/ZCFkBtRG2Lg.

Since the end of the spooktacular Casey released his version - [pmctrace](https://github.com/cmuratori/pmctrace). Other than being written by Casey and not me, the official version also now 1) doesn't require the program to be run as admin and 2) adds the ability to use all pmcs, not just ones exposed by ETW. These were things added after the "spooktacular" and, given the license for Caseys version, I'd want to check with him before adding those things here, or just directly porting his version.