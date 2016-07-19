		// background
		itemDef 
		{
			rect			106 0 280 480
			style			WINDOW_STYLE_FILLED
			forecolor		1 1 1 1
			backcolor		0 0 0 0.7
			visible			1
			decoration
		}

		// header
		itemDef
		{
			rect			106 0 280 42
			style			WINDOW_STYLE_SHADER
			background		"surf_banner"
			visible			1
			decoration
		}

		// mod name
		itemDef
		{
			visible			1
			rect 			116 -22 1 1 HORIZONTAL_ALIGN_LEFT VERTICAL_ALIGN_BOTTOM
			origin			0 0
			forecolor		1 1 1 1
			text			"^7Surf Mod by ^3atrX^7\nSpecial thanks to ^2NinjaWa"
			textfont		UI_FONT_NORMAL
			textalign		ITEM_ALIGN_LEFT
			textscale		0.33
			decoration
		}