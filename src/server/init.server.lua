local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Compile = require(ReplicatedStorage.Packages.compile)

Compile.Mount(
	Compile.CreateDialogueTemplete(
		Compile.CreateMessageTemplete(
			Compile.ConstructMessage(
				"lorem ipsum",
				"您认为伟大的中华人民共和国所奉行的共和制度是我们所思所想的吗？"
			),
			Compile.ConstructMessage(
				"Sigma",
				"我作为黄浚杰却做不到识时务者为俊杰的态度真是令我羞愧！"
			)
		),
		Compile.CreateChoicesTemplete(
			"lorem ipsum?",
			Compile.ConstructChoice(
				"废物",
				Compile.CreateDialogueTemplete(
					Compile.CreateMessageTemplete(
						Compile.ConstructMessage("sigma", "的确，我也感同身受！"),
						Compile.ConstructMessage("wom", "但是您也要跟着死！")
					)
				)
			),
			Compile.ConstructChoice("skksjkdfjkdj")
		)
	),
	workspace.Sigma
)
