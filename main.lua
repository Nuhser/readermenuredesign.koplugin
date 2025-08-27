local Dispatcher = require("dispatcher")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Translator = require("ui/translator")
local ReaderHighlight = require("apps/reader/modules/readerhighlight")
local ButtonDialog = require("ui/widget/buttondialog")
local UIManager = require("ui/uimanager")
local ffiUtil = require("ffi/util")
local _ = require("gettext")

-- Override creation of the UI for the reader highlight menu.
function ReaderHighlight:onShowHighlightMenu(index)
	local selectButton = nil
	local highlightButton = nil
	local searchButton = nil
	local wikipediaButton = nil
	local wordReferenceButton = nil
	local dictionaryButton = nil
	local translateButton = nil
	local unknownButtons = {}

	for key, fn_button in ffiUtil.orderedPairs(self._highlight_buttons) do
		local button = fn_button(self, index)
		if not button.show_in_highlight_dialog_func or button.show_in_highlight_dialog_func() then
			if key:find("_select") then
				button.text = nil
				button.text_func = nil
				button.icon = index and "button.select-extend" or "button.select"
				selectButton = button
			elseif key:find("_highlight") then
				button.text = nil
				button.text_func = nil
				button.icon = "button.highlight"
				highlightButton = button
			elseif key:find("_wikipedia") then
				button.text = nil
				button.text_func = nil
				button.icon = "button.wikipedia"
				wikipediaButton = button
			elseif key:find("_dictionary") then
				button.text = nil
				button.text_func = nil
				button.icon = "button.dictionary"
				dictionaryButton = button
			elseif key:find("_translate") then
				button.text = nil
				button.text_func = nil
				button.icon = "button.translate"
				translateButton = button
			elseif key:find("_wordreference") then
				button.text = nil
				button.text_func = nil
				button.icon = "button.wordreference"
				wordReferenceButton = button
			elseif key:find("_search") then
				button.text = nil
				button.text_func = nil
				button.icon = "button.search"
				searchButton = button
			else
				table.insert(unknownButtons, button)
			end
		end
	end

	local highlight_buttons = {{}}

	-- Add custom rows.
	highlight_buttons[1] = {
		selectButton,
		highlightButton,
		wikipediaButton,
		wordReferenceButton,
		dictionaryButton,
		translateButton,
		searchButton,
	}

	local DictQuickLookupRemake = self.ui["dictquicklookupremake"]
	if DictQuickLookupRemake:getShowUnknownButtons() then
		-- Split unknownButtons into smaller rows.
		local maxRowLength = 2
		if #unknownButtons > 0 then
			for i = 1, #unknownButtons, maxRowLength do
				local row = {}
				for j = i, math.min(i + maxRowLength - 1, #unknownButtons) do
					row[#row + 1] = unknownButtons[j]
				end
				highlight_buttons[#highlight_buttons + 1] = row
			end
		end
	end

	self.highlight_dialog = ButtonDialog:new{
		buttons = highlight_buttons,
		anchor = function()
			return self:_getDialogAnchor(self.highlight_dialog, index)
		end,
		tap_close_callback = function()
			if self.hold_pos then
				self:clear()
			end
		end,
	}

	-- NOTE: Disable merging for this update,
	--       or the buggy Sage kernel may alpha-blend it into the page (with a bogus alpha value, to boot)...
	UIManager:show(self.highlight_dialog, "[ui]")
end

-- Create the instance for the DictQuickLookupRemake plugin.
local DictQuickLookupRemake = WidgetContainer:extend {
  name = "dictquicklookupremake",
}

function DictQuickLookupRemake:init()
	self.ui.menu:registerToMainMenu(self)
end

function DictQuickLookupRemake:onDispatcherRegisterActions()
	Dispatcher:registerAction("dictquicklookupremake_action", {category="none", event="Close", title=_("Dict Quick Lookup Remake"), general=true,})
end

function DictQuickLookupRemake:getShowUnknownButtons()
	return G_reader_settings:readSetting("dictquicklookupremake_show_unknown_buttons", true)
end

function DictQuickLookupRemake:saveShowUnknownButtons(should_show)
	G_reader_settings:saveSetting("dictquicklookupremake_show_unknown_buttons", should_show)
end

function DictQuickLookupRemake:addToMainMenu(menu_items)
	menu_items.dictquicklookupremake = {
		text = "Dict Quick Lookup Remake",
		sorting_hint = "more_tools",
		sub_item_table = {
			{
				text = "Show Unknown Buttons In Reader Highlight Menu",
				checked_func = function()
					return DictQuickLookupRemake:getShowUnknownButtons()
				end,
				callback = function(button)
					local newValue = self:getShowUnknownButtons() == false
					self:saveShowUnknownButtons(newValue)
				end,
			},
		},
	}
end

function DictQuickLookupRemake:onDictButtonsReady(dict_popup, buttons)
  if dict_popup.is_wiki_fullpage then
	return false
  end

  local vocabularyButton = nil
  local prevDictButton = nil
  local nextDictButton = nil
  local highlightButton = nil
  local searchButton = nil
  local wikipediaButton = nil
  local closeButton = nil
  local wordReferenceButton = nil
  local unknownButtons = {}

  for row = 1, #buttons do
	for column = 1, #buttons[row] do
	  local button = buttons[row][column]

	  if button.id == "vocabulary" then
		vocabularyButton = button
	  elseif button.id == "prev_dict" then
		prevDictButton = button
	  elseif button.id == "next_dict" then
		nextDictButton = button
	  elseif button.id == "highlight" then
		button.text = nil
		button.icon = "button.highlight"
		highlightButton = button
	  elseif button.id == "search" then
		button.text = nil
		button.icon = "button.search"
		searchButton = button
	  elseif button.id == "wikipedia" then
		button.text_func = nil
		if dict_popup.is_wiki then
			button.icon = "button.article"
		else
			button.icon = "button.wikipedia"
		end
		wikipediaButton = button
	  elseif button.id == "close" then
		button.text = nil
		button.icon = "close"
		closeButton = button
	  elseif button.id == "wordreference" then
		button.text = nil
		button.icon = "button.wordreference"
		wordReferenceButton = button
	  else
		table.insert(unknownButtons, button)
	  end
	end
  end

  local translateButton = {
	id = "translate",
	icon = "button.translate",
	callback = function()
	  Translator:showTranslation(dict_popup.word, true)
	end
  }

  local dictionaryButton = {
	id = "dictionary",
	icon = "button.dictionary",
	enabled = dict_popup.is_wiki,
	callback = function()
	  self.ui.dictionary:onLookupWord(dict_popup.word, false, dict_popup.word_boxes)
	end
  }

  -- Remove all rows.
  for row = 1, #buttons do
	buttons[row] = nil
  end

  -- Add custom rows.
  local currentRow = 1

  if vocabularyButton ~= nil then
	buttons[currentRow] = {
	  vocabularyButton,
	}
	currentRow = currentRow + 1
  end

  buttons[currentRow] = {
	highlightButton,
	wikipediaButton,
	wordReferenceButton,
	dictionaryButton,
	translateButton,
	searchButton,
  }
  currentRow = currentRow + 1

  if #unknownButtons > 0 then
	buttons[currentRow] = unknownButtons
	currentRow = currentRow + 1
  end

  return false
end

function DictQuickLookupRemake:onWordReferenceDefinitionButtonsReady(ui, buttons)
	for row = 1, #buttons do
		for column = 1, #buttons[row] do
			local button = buttons[row][column]

			if button.id == "wikipedia" then
				button.text = nil
				button.icon = "button.wikipedia"
			elseif button.id == "dictionary" then
				button.text = nil
				button.icon = "button.dictionary"
			elseif button.id == "translate" then
				button.text = nil
				button.icon = "button.translate"
			end
		end
	end
end

return DictQuickLookupRemake
