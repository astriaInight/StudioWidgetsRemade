local studioui = {}

local types = require(script.Types)

--// Colors
local function getCol(c : Enum.StudioStyleGuideColor)
	return settings().Studio.Theme:GetColor(c)
end

function updateColors(gui)
	local bkFrame = gui.BackgroundFrame
	local scroll = bkFrame.Scroll
	local section = scroll.Section
	local secContent = scroll.SectionContent
	local frame = secContent.Frame
	local checkbox = secContent.Checkbox
	local textbox = secContent.Textbox

	section.BackgroundColor3 = getCol(Enum.StudioStyleGuideColor.Titlebar)
	section.Title.TextColor3 = getCol(Enum.StudioStyleGuideColor.MainText)

	bkFrame.BackgroundColor3 = getCol(Enum.StudioStyleGuideColor.MainBackground)
	secContent.BackgroundColor3 = getCol(Enum.StudioStyleGuideColor.MainBackground)

	frame.BackgroundColor3 = getCol(Enum.StudioStyleGuideColor.MainBackground)
	frame.BorderColor3 = getCol(Enum.StudioStyleGuideColor.InputFieldBorder)

	checkbox.BackgroundColor3 = getCol(Enum.StudioStyleGuideColor.MainBackground)
	checkbox.Left.BackgroundColor3 = getCol(Enum.StudioStyleGuideColor.MainBackground)
	checkbox.Left.BorderColor3 = getCol(Enum.StudioStyleGuideColor.InputFieldBorder)
	checkbox.Right.BackgroundColor3 = getCol(Enum.StudioStyleGuideColor.MainBackground)
	checkbox.Right.BorderColor3 = getCol(Enum.StudioStyleGuideColor.InputFieldBorder)
	checkbox.Left.Title.TextColor3 = getCol(Enum.StudioStyleGuideColor.MainText)
	checkbox.Right.Checkbox.BackgroundColor3 = getCol(Enum.StudioStyleGuideColor.CheckedFieldBackground)
	checkbox.Right.Checkbox.BorderColor3 = getCol(Enum.StudioStyleGuideColor.CheckedFieldBorder)

	textbox.BackgroundColor3 = getCol(Enum.StudioStyleGuideColor.MainBackground)
	textbox.Left.BackgroundColor3 = getCol(Enum.StudioStyleGuideColor.MainBackground)
	textbox.Left.BorderColor3 = getCol(Enum.StudioStyleGuideColor.InputFieldBorder)
	textbox.Right.BackgroundColor3 = getCol(Enum.StudioStyleGuideColor.MainBackground)
	textbox.Right.BorderColor3 = getCol(Enum.StudioStyleGuideColor.InputFieldBorder)
	textbox.Left.Title.TextColor3 = getCol(Enum.StudioStyleGuideColor.MainText)
end

--// Plugin stuff
function studioui:SetPlugin(plugin : Plugin)
	self.plugin = plugin
end

function studioui:Window(title : string?, options : types.windowOptions?)
	--// Constructor
	local title = title or "Plugin"
	local options = options or { width = 200, height = 200, minWidth = 40, minHeight = 40 }
	
	local plugin = assert(self.plugin, "Please run StudioUI:SetPlugin(plugin) before creating a window.")
	
	local pluginGui = plugin:CreateDockWidgetPluginGui(
		title,
		DockWidgetPluginGuiInfo.new(
			Enum.InitialDockState.Float,
			false,
			false,
			options.width,
			options.height,
			options.minWidth,
			options.minHeight
		)
	)
	
	pluginGui.Title = title
	
	for _, elem in pairs(script.WinGui:GetChildren()) do
		elem:Clone().Parent = pluginGui
	end
	
	--// Theme handling
	updateColors(pluginGui)
	settings().Studio.ThemeChanged:Connect(function()
		updateColors(pluginGui)
	end)
	
	--// Setup elements & store them
	local bkFrame = pluginGui.BackgroundFrame
	local scrFrame = bkFrame.Scroll
	local sectionBtn = scrFrame.Section
	local secContentFrame = scrFrame.SectionContent
	
	sectionBtn.Parent = nil
	secContentFrame.Parent = nil
	
	--// Func
	local window = {}
	
	function window:Show()
		pluginGui.Enabled = true
	end
	
	function window:Hide()
		pluginGui.Enabled = false
	end
	
	function window:IsVisible()
		return pluginGui.Enabled
	end
	
	function window:ToggleVisible()
		pluginGui.Enabled = not pluginGui.Enabled
	end
	
	function window:TitledSection(title : string, default : boolean?)
		--// Defaults
		assert(title, "Please provide a title for new sections.")
		if default == nil then default = true end
		
		--// Constructor
		local newSection = sectionBtn:Clone()
		local secTitle = newSection.Title
		secTitle.Text = title
		local secArrow = newSection.ArrowHolder.Arrow
		
		local newSecContent = secContentFrame:Clone()
		
		
		--// Locate inputs
		local secTextbox = newSecContent.Textbox
		secTextbox.Parent = nil
		
		local secCheckbox = newSecContent.Checkbox
		secCheckbox.Parent = nil
		
		local secSlider = newSecContent.Slider
		secSlider.Parent = nil
		
		local emptySecFrame = newSecContent.Frame
		emptySecFrame.Parent = nil
		
		
		local secOpen = default
		
		--// Func
		local section = {}
		
		function section:Collapse()
			newSecContent.Visible = false
			secArrow.Rotation = -90
		end
		
		function section:Expand()
			newSecContent.Visible = true
			secArrow.Rotation = 0
		end
		
		function section:AppendObject(obj : Instance)
			obj.Parent = newSecContent
		end
		
		function section:Textbox(valueName : string, callback : any?)
			assert(valueName, "Value name required when creating editable value. ")
			
			local newSecItem = secTextbox:Clone()
			local secItemLeft = newSecItem.Left
			local secItemRight = newSecItem.Right
			local secItemTitle = secItemLeft.Title
			local secItemTextbox = secItemRight.Input
			
			secItemTitle.Text = valueName
			
			newSecItem.Parent = newSecContent
			
			local Textbox = { Text = "" }
			
			secItemTextbox:GetPropertyChangedSignal("Text"):Connect(function()
				local curText = secItemTextbox.Text
				
				if callback then callback(curText) end
				
				Textbox.Text = curText
			end)
		end
		
		function section:Checkbox(valueName : string, default : boolean?, callback : any?)
			assert(valueName, "Value name required when creating editable value. ")

			local newSecItem = secCheckbox:Clone()
			local secItemLeft = newSecItem.Left
			local secItemRight = newSecItem.Right
			local secItemTitle = secItemLeft.Title
			local secItemCheckbox = secItemRight.Checkbox
			local secItemCheck = secItemCheckbox.Selector
			
			local checked = default or false
			
			secItemTitle.Text = valueName
			
			--// Default check
			secItemCheck.Visible = checked

			newSecItem.Parent = newSecContent
			
			local Checkbox = { Checked = checked }
			
			secItemCheckbox.MouseButton1Click:Connect(function()
				checked = not checked
				
				Checkbox.Checked = checked
				
				secItemCheck.Visible = checked
				
				if callback then callback(checked) end
			end)
		end
		
		function section:Frame()
			local newEmptyFrame = emptySecFrame:Clone()

			local frameButton = newEmptyFrame.Button
			frameButton.Parent = nil
			
			newEmptyFrame.Parent = newSecContent
			
			--// Func
			local frame = {}
			
			function frame:Button(text : string, callback)
				local newButton = frameButton:Clone()
				newButton.Text = text
				
				if callback then
					newButton.MouseButton1Click:Connect(callback)
				end
				
				newButton.Parent = newEmptyFrame
			end
			
			function frame:Layout(fillDirection : Enum.FillDirection, horizontalAlign : Enum.HorizontalAlignment, verticalAlign : Enum.VerticalAlignment, padding : UDim)
				local frameLayout = Instance.new("UIListLayout")
				frameLayout.FillDirection = fillDirection or Enum.FillDirection.Vertical
				frameLayout.VerticalAlignment = verticalAlign or Enum.VerticalAlignment.Top
				frameLayout.HorizontalAlignment = horizontalAlign or Enum.HorizontalAlignment.Left
				frameLayout.Padding = padding or UDim.new(0, 0)
				
				frameLayout.Parent = newEmptyFrame
			end
			
			return frame
		end
		
		--// Default
		if secOpen then
			section:Expand()
		else
			section:Collapse()
		end
		
		--// Toggle
		newSection.MouseButton1Click:Connect(function()
			secOpen = not secOpen
			
			if secOpen then
				section:Expand()
			else
				section:Collapse()
			end
		end)
		
		--// Parent stuff
		newSection.Parent = scrFrame
		newSecContent.Parent = scrFrame
		
		return section
	end
	
	return window
end

return studioui
