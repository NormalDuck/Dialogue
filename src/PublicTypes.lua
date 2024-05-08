export type MakeChoicesTemplete = (ChoiceMessage: string, MakeChoice...) -> Signals
export type MakeMessageTemplete = (MakeMessage...) -> Signals
export type MakeDialogueTemplete = (Message: MakeMessageTemplete, Choice: MakeChoicesTemplete) -> Signals
export type MakeChoice = (ChoiceName: string, Response: MakeDialogueTemplete, Timeout: number) -> Signals
export type MakeMessage = (Head: string, Body: string) -> Signals
export type Mount = (MakeDialogueTemplete, Part: Instance) -> ()

export type GetDialogueState = () -> "Message" | "Choice" | "Closed"
export type GetMessage = () -> string
export type GetChoices = () -> { { UUID: string, ChoiceName: string } }
export type DialogueServer = {
	MakeChoice: MakeChoice,
	MakeMessage: MakeMessage,
	MakeChoicesTemplete: MakeChoicesTemplete,
	MakeMessageTemplete: MakeMessageTemplete,
	MakeDialogueTemplete: MakeDialogueTemplete,
	Mount: Mount,
}

export type DialogueClient = {
	CloseDialgoue: RBXScriptSignal,
	OpenDialogue: RBXScriptSignal,
	ChoiceChosen: RBXScriptSignal,
	SwitchToChoice: RBXScriptSignal,
	NextMessage: RBXScriptSignal,
	GetDialogueState: GetDialogueState,
	GetMessage: GetMessage,
	GetChoices: GetChoices,
}

export type Signals = {
	AddTriggerSignal: (self: Signals, fn: (player: Player) -> ()) -> Signals,
	AddTimeoutSignal: (self: Signals, Time: number, fn: (player: Player) -> ()) -> Signals,
}

return nil
