export type Message = {
	Head: string,
	Body: string,
	Listeners: {
		{ Type: "Timeout", Time: number, Callback: (player: Player) -> () }
		| { Type: "Trigger", Callback: (player: Player) -> () }
	},
}

export type Choice = {
	ChoiceName: string,
	UUID: string,
	Response: MountInfo,
	Listeners: {
		{ Type: "Timeout", Time: number, Callback: (player: Player) -> () }
		| { Type: "Trigger", Callback: (player: Player) -> () }
	},
}

export type CreateChoicesTemplete = (
	ChoiceMessage: string,
	ConstructChoice...
) -> {
	ChoiceMessage: string,
	Data: { Choice },
	Listeners: {
		{ Type: "Timeout", Time: number, Callback: (player: Player) -> () }
		| { Type: "Trigger", Callback: (player: Player) -> () }
	},
}
export type CreateMessageTemplete = (
	ConstructMessage...
) -> {
	Data: { Message },
	Listeners: {
		{ Type: "Timeout", Time: number, Callback: (player: Player) -> () }
		| { Type: "Trigger", Callback: (player: Player) -> () }
	},
}
export type CreateDialogueTemplete = (
	Message: CreateMessageTemplete,
	Choice: CreateChoicesTemplete
) -> {
	Message: CreateMessageTemplete,
	Choice: CreateChoicesTemplete,
	Listeners: {
		{ Type: "Timeout", Time: number, Callback: (player: Player) -> () }
		| { Type: "Trigger", Callback: (player: Player) -> () }
	},
}
export type ConstructChoice = (ChoiceName: string, Response: CreateDialogueTemplete) -> Choice
export type ConstructMessage = (Head: string, Body: string, Image: string) -> Message
export type MountInfo = {
	Message: {
		Data: { Message },
		Listeners: {
			{ Type: "Timeout", Time: number, Callback: (player: Player) -> () }
			| { Type: "Trigger", Callback: (player: Player) -> () }
		},
	},
	Choices: {
		ChoiceMessage: string,
		Data: { Choice },
		Listeners: {
			{ Type: "Timeout", Time: number, Callback: (player: Player) -> () }
			| { Type: "Trigger", Callback: (player: Player) -> () }
		},
	},
	Listeners: {
		{ Type: "Timeout", Time: number, Callback: (player: Player) -> () }
		| { Type: "Trigger", Callback: (player: Player) -> () }
	},
}
export type ActivePlayerData = {
	CurrentClientDialogue: MountInfo,
	CurrentClientMessage: number,
	ExposeType: string,
	MessagePromises: {},
	ChoicePromises: {},
	ChoiceTempletePromises: {},
	MessageTempletePromises: {},
	DialogueTempletePromises: {},
}

return nil
