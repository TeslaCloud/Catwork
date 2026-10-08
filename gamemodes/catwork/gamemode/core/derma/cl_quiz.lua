--- Defines `cw.quiz`, the full-screen quiz a player has to answer before playing.
--
-- `Populate` adds a combo box for each question from `cw.quiz:GetQuestions`; picking an answer sends the `QuizAnswer`
-- Cable message and the Continue button sends `QuizCompleted`, after which the server decides whether the answers pass.

local backdropColor = Color(0, 0, 0, 255)

local PANEL = {}

--- Builds the full-screen quiz with its question list and the Disconnect and Continue buttons.
--
-- Continue sends the `QuizCompleted` Cable message; the server decides whether the answers pass.
function PANEL:Init()
  local smallTextFont = cw.option:GetFont('menu_text_small')
  local scrH = ScrH()
  local scrW = ScrW()

  self.createTime = SysTime()

  self:SetPos(0, 0)
  self:SetSize(scrW, scrH)
  self:SetPaintBackground(false)
  self:SetMouseInputEnabled(true)
  self:SetKeyboardInputEnabled(true)

  self.scrollList = vgui.Create('DScrollPanel', self)
  self.scrollList:SizeToContents()

  self.panelList = vgui.Create('cwPanelList', self.scrollList)
  self.panelList:SetPadding(2)
  self.panelList:SetSpacing(3)
  self.panelList:SizeToContents()

  self.disconnectButton = vgui.Create('cwLabelButton', self)
  self.disconnectButton:SetFont(smallTextFont)
  self.disconnectButton:SetText('#QuizPanel_Disconnect')
  self.disconnectButton:FadeIn(0.5)
  self.disconnectButton:SetCallback(function(panel)
    RunConsoleCommand('disconnect')
  end)

  self.disconnectButton:SizeToContents()
  self.disconnectButton:SetMouseInputEnabled(true)
  self.disconnectButton:SetPos((scrW * 0.2) - (self.disconnectButton:GetWide() / 2), scrH * 0.9)

  self.continueButton = vgui.Create('cwLabelButton', self)
  self.continueButton:SetFont(smallTextFont)
  self.continueButton:SetText('#QuizPanel_Continue')
  self.continueButton:FadeIn(0.5)
  self.continueButton:SetCallback(function(panel)
    cable.send('QuizCompleted', true)
  end)

  self.continueButton:SizeToContents()
  self.continueButton:SetMouseInputEnabled(true)
  self.continueButton:SetPos((scrW * 0.8) - (self.continueButton:GetWide() / 2), scrH * 0.9)
end

--- Blurs the background and draws a black backdrop over the screen.
function PANEL:Paint(w, h)
  cw.core:RegisterBackgroundBlur(self, self.createTime)
  cw.core:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), backdropColor)

  return true
end

--- Removes the quiz's background blur along with it.
function PANEL:OnRemove()
  cw.core:RemoveBackgroundBlur(self)
end

--- Fills the quiz with a combo box for each question from `cw.quiz:GetQuestions`, sorted by question text.
--
-- Each answer is sent to the server with the `QuizAnswer` Cable message as soon as it is picked.
function PANEL:Populate()
  local quizQuestions = cw.quiz:GetQuestions()
  local questions = {}

  self.questionsForm = vgui.Create('DForm')
  self.questionsForm:SetName(cw.quiz:GetName())
  self.questionsForm:SetPadding(4)

  self.panelList:Clear(true)

  local label = vgui.Create('cwInfoText', self)
    label:SetText('#QuizPanel_Warning')
    label:SetInfoColor('orange')
  self.panelList:AddItem(label)

  self.panelList:AddItem(self.questionsForm)

  -- The questions are keyed by a CRC, so they go into a list to be sortable.
  for k, v in pairs(quizQuestions) do
    questions[#questions + 1] = { k, v }
  end

  table.sort(questions, function(a, b)
    return a[2].question < b[2].question
  end)

  for k, v in ipairs(questions) do
    local panel = vgui.Create('DComboBox', self.questionsForm)
    local question = vgui.Create('DLabel', self.questionsForm)
    local key = v[1]

    self.questionsForm:AddItem(question)

    question:SetText(v[2].question)
    question:SetDark(true)
    question:SetTextColor(Color(255, 255, 255))
    question:SizeToContents()

    -- Called when an option is selected.
    function panel:OnSelect(index, value, data)
      cable.send('QuizAnswer', { key, index })
    end

    for k2, v2 in pairs(v[2].possibleAnswers) do
      panel:AddChoice(v2)
    end

    self.questionsForm:AddItem(panel)
  end
end

--- Centres the question list on the screen at half the screen width.
function PANEL:PerformLayout(w, h)
  local scrW = ScrW()
  local scrH = ScrH()

  self.panelList:SetSize(scrW * 0.5, math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75))
  self.panelList:SetPos(0, 0)
  self.scrollList:SetSize(scrW * 0.5, ScrH() * 0.75)
  self.scrollList:SetPos((scrW / 2) - (self.panelList:GetWide() / 2), (scrH / 2) - (self.panelList:GetTall() / 2))

  derma.SkinHook('Layout', 'Panel', self)
end

--- Lays the quiz out again each frame.
function PANEL:Think()
  self:InvalidateLayout(true)
end

vgui.Register('cw.quiz', PANEL, 'DPanel')
