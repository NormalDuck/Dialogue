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

export type CreateChoicesTemplate = (
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
export type CreateMessageTemplate = (
	ConstructMessage...
) -> {
	Data: { Message },
	Listeners: {
		{ Type: "Timeout", Time: number, Callback: (player: Player) -> () }
		| { Type: "Trigger", Callback: (player: Player) -> () }
	},
}
export type CreateDialogueTemplate = (
	Message: CreateMessageTemplate,
	Choice: CreateChoicesTemplate
) -> {
	Message: CreateMessageTemplate,
	Choice: CreateChoicesTemplate,
	Listeners: {
		{ Type: "Timeout", Time: number, Callback: (player: Player) -> () }
		| { Type: "Trigger", Callback: (player: Player) -> () }
	},
}
export type ConstructChoice = (ChoiceName: string, Response: CreateDialogueTemplate) -> Choice
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
	ChoiceTemplatePromises: {},
	MessageTemplatePromises: {},
	DialogueTemplatePromises: {},
}

return nil
