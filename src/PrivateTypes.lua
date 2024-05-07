--[=[
	@interface Message
	.Head string -- the name to be displayed
	.Body string -- the message to be displayed
	@within DialogueServer
	@private
]=]
export type Message = {
	Head: string,
	Body: string,
	Listeners: Listeners,
}

--[=[
	@interface Choice
	.ChoiceName string
	.UUID string -- For communicating which choice it picks (internal)
	.Response DialogueTemplate
	@within DialogueServer
	@private
]=]
export type Choice = {
	ChoiceName: string,
	UUID: string,
	Response: DialogueTemplete,
	Listeners: Listeners,
}

--[=[
	@interface ChoicesTemplate
	.ChoiceMessage { string } -- The message to be displayed
	.Data Choice -- The choices that are passed for the constructor
	@within DialogueServer
	@private
]=]
export type ChoicesTemplate = {
	ChoiceMessage: string,
	Data: { Choice },
	Listeners: Listeners,
}

--[=[
	@interface MessageTemplate
	.Data { Message }
	@within DialogueServer
	@private
]=]
export type MessageTemplate = {
	Data: { Message },
	Listeners: Listeners,
}

--[=[
	@interface DialogueTemplate
	.Message MessageTemplate
	.Choice ChoicesTemplate
	@within DialogueServer
	@private
]=]
export type DialogueTemplete = {
	Message: MessageTemplate,
	Choice: ChoicesTemplate,
	Listeners: Listeners,
}

export type CreateChoicesTemplate = (ChoiceMessage: string, ConstructChoice...) -> ChoicesTemplate
export type CreateMessageTemplate = (ConstructMessage...) -> MessageTemplate
export type CreateDialogueTemplate = (Message: MessageTemplate, Choice: ChoicesTemplate) -> DialogueTemplete
export type ConstructChoice = (ChoiceName: string, Response: CreateDialogueTemplate) -> Choice
export type ConstructMessage = (Head: string, Body: string, Image: string) -> Message

export type MountInfo = {
	Message: MessageTemplate,
	Choices: ChoicesTemplate,
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

export type Listeners = {
	Listeners: {
		{ Type: "Timeout", Time: number, Callback: (player: Player) -> () }
		| { Type: "Trigger", Callback: (player: Player) -> () }
	}?,
}

return nil
