export type MakeChoicesTemplate = (ChoiceMessage: string, MakeChoice...) -> Signals
export type MakeMessageTemplate = (MakeMessage...) -> Signals
export type MakeDialogueTemplate = (Message: MakeMessageTemplate, Choice: MakeChoicesTemplate) -> Signals
export type MakeChoice = (ChoiceName: string, Response: MakeDialogueTemplate) -> Signals
export type MakeMessage = (Head: string, Body: string) -> Signals
export type Mount = (MakeDialogueTemplate, Part: Instance) -> ()

export type GetDialogueState = () -> "Message" | "Choice" | "Closed"
export type GetMessage = () -> string
export type GetChoices = () -> { { UUID: string, ChoiceName: string } }
export type DialogueServer = {
	MakeChoice: MakeChoice,
	MakeMessage: MakeMessage,
	MakeChoicesTemplate: MakeChoicesTemplate,
	MakeMessageTemplate: MakeMessageTemplate,
	MakeDialogueTemplate: MakeDialogueTemplate,
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
