local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Translator = require("ui/translator")
local _ = require("gettext")

local DictQuickLookupRemake = WidgetContainer:extend {
  name = "dictquicklookupremake",
}

function DictQuickLookupRemake:onDictButtonsReady(dict_popup, buttons)
  if dict_popup.is_wiki_fullpage then
    return false
  end

  local prevDictButton = nil
  local nextDictButton = nil
  local highlightButton = nil
  local searchButton = nil
  local wikipediaButton = nil
  local closeButton = nil
  local wordReferenceButton = nil

  for row = 1, #buttons do
    for column = 1, #buttons[row] do
      local button = buttons[row][column]

      if button.id == "prev_dict" then
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

  buttons[1] = {
    highlightButton,
    wikipediaButton,
    wordReferenceButton,
    dictionaryButton,
    translateButton,
    searchButton,
  }
  buttons[2] = nil

  return false
end

return DictQuickLookupRemake
