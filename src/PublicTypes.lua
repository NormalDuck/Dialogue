export type CreateChoicesTemplete = (ChoiceMessage: string, ConstructChoice...) -> Signals
export type CreateMessageTemplete = (ConstructMessage...) -> Signals
export type CreateDialogueTemplete = (Message: CreateMessageTemplete, Choice: CreateChoicesTemplete) -> Signals
export type ConstructChoice = (ChoiceName: string, Response: CreateDialogueTemplete, Timeout: number) -> Signals
export type ConstructMessage = (Head: string, Body: string) -> Signals
export type Mount = (CreateDialogueTemplete, Part: Instance) -> ()

export type	GetDialogueState =  () -> "Message" | "Choice" | "Closed"
export type	GetMessage = () -> string
export type	GetChoices= () -> { { UUID: string, ChoiceName: string } }
export type DialogueServer = {
	ConstructChoice: ConstructChoice,
	ConstructMessage: ConstructMessage,
	CreateChoicesTemplete: CreateChoicesTemplete,
	CreateMessageTemplete: CreateMessageTemplete,
	CreateDialogueTemplete: CreateDialogueTemplete,
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