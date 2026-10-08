--- Defines the `cw.quiz` library, the quiz that new players have to pass before they can play.
--
-- Schemas add questions with `cw.quiz:AddQuestion` and switch the quiz on with `cw.quiz:SetEnabled`. The server also
-- sets the share of correct answers needed and the callback run for players who fail.

library.New('quiz', cw)

local stored = cw.quiz.stored or {}
cw.quiz.stored = stored

--- Sets the title shown on the quiz panel.
--
-- @param name [String The quiz title, can be a language phrase]
function cw.quiz:SetName(name)
  self.name = name
end

--- Returns the title shown on the quiz panel.
--
-- @return [String The quiz title; `#QuizPanel_Questions` when none is set]
function cw.quiz:GetName()
  return self.name or '#QuizPanel_Questions'
end

--- Sets whether new players have to pass the quiz.
--
-- @param enabled [Boolean Whether the quiz is enabled]
function cw.quiz:SetEnabled(enabled)
  self.enabled = enabled
end

--- Returns whether new players have to pass the quiz.
--
-- @return [Boolean Whether the quiz is enabled, or `nil` if it was never set]
function cw.quiz:GetEnabled()
  return self.enabled
end

--- Returns how many questions the quiz has.
--
-- @return [Number The number of questions]
function cw.quiz:GetQuestionsAmount()
  return table.Count(stored)
end

--- Returns every quiz question.
--
-- @return [Map<Map> Question tables with `question`, `answer` and `possibleAnswers` keys, keyed by
-- the short CRC of the question text]
function cw.quiz:GetQuestions()
  return stored
end

--- Returns a quiz question.
--
-- @param index [Number The question's index, the short CRC of its text]
-- @return [Map The question table with `question`, `answer` and `possibleAnswers` keys, or `nil`]
function cw.quiz:GetQuestion(index)
  return stored[index]
end

--- Returns whether an answer to a quiz question is correct.
--
-- The answer is correct when it is one of the question's correct answers (if `answer` is a list),
-- the text of the correct possible answer, or equal to the stored answer itself.
--
-- @param index [Number The question's index]
-- @param answer [Any The player's answer: the answer text or its position]
-- @return [Boolean `true` if the answer is correct, otherwise `nil`]
function cw.quiz:IsAnswerCorrect(index, answer)
  question = self:GetQuestion(index)

  if question then
    if type(question.answer) == 'table' and table.HasValue(question.answer, answer) then
      return true
    elseif answer == question.possibleAnswers[question.answer] then
      return true
    elseif question.answer == answer then
      return true
    end
  end
end

--- Adds a question to the quiz.
--
-- The question's index is the short CRC of its text.
--
-- ```
-- cw.quiz:AddQuestion('#Quiz_RP2_Question', 2,
--   '#Quiz_RP2_Answer1',
--   '#Quiz_RP2_Answer2',
--   '#Quiz_RP2_Answer3',
--   '#Quiz_RP2_Answer4')
-- ```
--
-- @param question [String The question text, can be a language phrase]
-- @param answer [Number Position of the correct answer among the possible answers, or a List of
-- accepted answers]
-- @param ... [String The possible answers, in the order they are shown]
function cw.quiz:AddQuestion(question, answer, ...)
  local index = cw.core:GetShortCRC(question)

  stored[index] = {
    possibleAnswers = { ... },
    question = question,
    answer = answer
  }
end

--- Removes a question from the quiz.
--
-- @param question [Any The question's index or its text]
function cw.quiz:RemoveQuestion(question)
  if stored[question] then
    stored[question] = nil
  else
    local index = cw.core:GetShortCRC(question)

    if stored[index] then
      stored[index] = nil
    end
  end
end

if CLIENT then
  --- Sets whether the local player has completed the quiz.
  --
  -- @param completed [Boolean Whether the quiz is completed]
  function cw.quiz:SetCompleted(completed)
    self.completed = completed
  end

  --- Returns whether the local player has completed the quiz.
  --
  -- @return [Boolean Whether the quiz is completed, or `nil` before the server has said]
  function cw.quiz:GetCompleted()
    return self.completed
  end

  --- Returns the quiz panel while it is open.
  --
  -- @return [Panel The quiz panel, or `nil` if it is not valid]
  function cw.quiz:GetPanel()
    if IsValid(self.panel) then
      return self.panel
    end
  end
else
  --- Marks a player as having completed the quiz, or clears it.
  --
  -- Stores the current number of questions in the player's `Quiz` data, so adding or removing
  -- questions makes players take the quiz again. Tells the player's client.
  --
  -- @param player [Player The player to mark]
  -- @param completed [Boolean Whether the player has completed the quiz]
  function cw.quiz:SetCompleted(player, completed)
    if completed then
      player:SetData('Quiz', self:GetQuestionsAmount())
    else
      player:SetData('Quiz', nil)
    end

    netstream.Start(player, 'QuizCompleted', completed)
  end

  --- Returns whether a player has completed the current quiz.
  --
  -- Bots always count as having completed it.
  --
  -- @param player [Player The player to check]
  -- @return [Boolean Whether the player has completed the quiz]
  function cw.quiz:GetCompleted(player)
    if player:GetData('Quiz') == self:GetQuestionsAmount() then
      return true
    else
      return player:IsBot()
    end
  end

  --- Sets the share of questions a player must answer correctly to pass.
  --
  -- @param percentage [Number Required percentage, from 0 to 100]
  function cw.quiz:SetPercentage(percentage)
    self.percentage = percentage
  end

  --- Returns the share of questions a player must answer correctly to pass.
  --
  -- @return [Number Required percentage; 100 when none is set]
  function cw.quiz:GetPercentage()
    return self.percentage or 100
  end

  --- Runs the quiz kick callback for a player who failed the quiz.
  --
  -- @param player [Player The player who failed]
  -- @param correctAnswers [Number How many questions they answered correctly]
  -- @see cw.quiz:SetKickCallback
  function cw.quiz:CallKickCallback(player, correctAnswers)
    local kickCallback = self:GetKickCallback()

    if kickCallback then
      kickCallback(player, correctAnswers)
    end
  end

  --- Returns the function that handles players who failed the quiz.
  --
  -- @return [Function The callback set with `cw.quiz:SetKickCallback`, or a default that kicks the
  -- player with the `#QuizPanel_KickReason` phrase in English]
  function cw.quiz:GetKickCallback()
    if self.kickCallback then
      return self.kickCallback
    else
      return function(player, correctAnswers)
        player:Kick(cw.lang:GetString('en', '#QuizPanel_KickReason'))
      end
    end
  end

  --- Sets the function that handles players who failed the quiz.
  --
  -- ```
  -- cw.quiz:SetKickCallback(function(player, correctAnswers)
  --   player:Kick('You failed the quiz.')
  -- end)
  -- ```
  --
  -- @param Callback [Function Called as `Callback(player, correctAnswers)`]
  function cw.quiz:SetKickCallback(Callback)
    self.kickCallback = Callback
  end
end
