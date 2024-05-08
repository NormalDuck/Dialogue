# Duck's Dialogue
A secure, lightweight, server-sided, Fusion-based module.
## Features
* Server-Sided Listeners: Realiable listeners for every tiny dialogue component.
* Client-Sides Signals: You can use the client-sided signal to detect on client side. It fires whenever server performs a action!
* Built-In Anticheat: Reduces the possibilties for clients to abuse signals.
* Less Exposure of Data: When sending information to client, the signal will automatically remove information that is not needed. This can reduce the chances of clients to know the entire dialogue.
* Full IntelliSense: This module returns a certain type. Preventing you from reading the internals. Enhances your experience when you're scripting!
* ByteNet communication: Uses ByteNet for communication to reduce the bandwidth for networking, this leads to better performance!
## How to install
Currently it only supports wally package manager. Sorry for the people who use Roblox's editor.
### Wally
```toml
Dialogue = "normalduck/dialogue@1.1.0"
Fusion = "elttob/fusion@0.2.0"
ByteNet = "ffrostflame/bytenet@0.4.5"
TableUtil = "sleitnick/table-util@1.2.1"
Promise = "evaera/promise@4.0.0"
LemonSignal = "data-oriented-house/lemonsignal@1.10.0"
```
### Roblox
Install the Roblox rbxm file in the release page. Drag it into replicated storage. 

## Potential Issues You May encounter
* there might be weird promise warnings, those for you to figure out cuz you typed something wrong
* **require the module from replicated storage both client and server side, or the module won't work if you only do it on server side, which just kicks you**

<summary> How This Module works </summary>
<details>
Whenever the client triggers a proximity prompt that has a tag "Dialogue" for CollectionService tags it closes all the proximity prompts (if the client attempts to trigger any other proximity prompt during a dialogue, they will be kicked). Whenever the ProximityPrompt is triggered (This is done by ProximityPromptService on the server side), the server will send a small portion of the dialogue (interally the dialogue is broken into smaller components, sending bits and bits to the client). First it will expose the message to the client, when the client is done reading (just by clicking on it) it will trigger "FinishedMessage" event, the server does some checks, seeing if the current state is message or choice, if its choice the server will kick the client (asuming you can't finish a message for a choice state). If the there message to continue, expose the message. If not, find if there is choices, expose the choice if there is. At choice state the client can invoke back to the server the UUID the choice is provided, the server identifies if the UUID for the choices, if UUID exists then it checks if the choice has a response. If so, repeats back into message state.

Every time the information is sent, the server will remove unnecessary data, this includes the response, the listeners. The client will be completely dependent on what the server sends. This makes the server be able to carefully monitor everything the client (so trigger and timeout signals will be realiable) because server is the one who exposes the information. Although the clients can send "correct" signals but it can't really benefit them in any way other than automating tasks. The client will never know what the choice, what this message will lead to.
</details>
