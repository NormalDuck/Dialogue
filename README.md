# Duck's Dialouge Module
A secure, lightweight, server-sided, Fusion-based module.
## Features
* Server-Sided Listeners: 100% (hopefully) Realiable listeners for every tiny dialogue component.
* Client-Sides Signals: You can use the client-sided signal to detect on client side. It fires whenever server performs a action!
* Built-In Anticheat: Reduces the possibilties for clients to abuse signals.
* Less Exposure of Data: When sending information to client, the signal will automatically remove information that is not needed. This can reduce the chances of clients to know the entire dialogue.
* Full IntelliSense: This module returns a certain type. Preventing you from reading the internals. Enhances your experience when you're scripting!
* ByteNet communication: Uses ByteNet for communication to reduce the bandwidth for networking, this leads to better performance!
## How to install:
Currently it only supports wally package manager. Sorry for the people who use Roblox's editor.
<details>
<summary> wally </summary>
  
```toml
Dialogue = "normalduck/dialogue@1.1.0"
Fusion = "elttob/fusion@0.2.0"
ByteNet = "ffrostflame/bytenet@0.4.5"
TableUtil = "sleitnick/table-util@1.2.1"
Promise = "evaera/promise@4.0.0"
LemonSignal = "data-oriented-house/lemonsignal@1.10.0"
```

</details>
