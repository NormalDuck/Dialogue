export type CreateChoicesTemplete = (ChoiceMessage: string, ConstructChoice...) -> Listeners
export type CreateMessageTemplete = (ConstructMessage...) -> Listeners
export type CreateDialogueTemplete = (Message: CreateMessageTemplete, Choice: CreateChoicesTemplete) -> Listeners
export type ConstructChoice = (ChoiceName: string, Response: CreateDialogueTemplete, Timeout: number) -> Listeners
export type ConstructMessage = (Head: string, Body: string) -> Listeners
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

export type Listeners = {
	AddTriggerSignal: (self: Listeners, fn: (player: Player) -> ()) -> Listeners,
	AddTimeoutSignal: (self: Listeners, Time: number, fn: (player: Player) -> ()) -> Listeners,
}

return nil