--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("quiz", cw)

local stored = cw.quiz.stored or {}
cw.quiz.stored = stored

-- A function to set the quiz name.
function cw.quiz:SetName(name)
	self.name = name
end

-- A function to get the quiz name.
function cw.quiz:GetName()
	return self.name or "#QuizPanel_Questions"
end

-- A function to set whether the quiz is enabled.
function cw.quiz:SetEnabled(enabled)
	self.enabled = enabled
end

-- A function to get whether the quiz is enabled.
function cw.quiz:GetEnabled()
	return self.enabled
end

-- A function to get the amount of quiz questions.
function cw.quiz:GetQuestionsAmount()
	return table.Count(stored)
end

-- A function to get the quiz questions.
function cw.quiz:GetQuestions()
	return stored
end

-- A function to get a question.
function cw.quiz:GetQuestion(index)
	return stored[index]
end

-- A function to get if an answer is correct.
function cw.quiz:IsAnswerCorrect(index, answer)
	question = self:GetQuestion(index)

	if (question) then
		if (type(question.answer) == "table" and table.HasValue(question.answer, answer)) then
			return true
		elseif (answer == question.possibleAnswers[question.answer]) then
			return true
		elseif (question.answer == answer) then
			return true
		end
	end
end

-- A function to add a new quiz question.
function cw.quiz:AddQuestion(question, answer, ...)
	local index = cw.core:GetShortCRC(question)

	stored[index] = {
		possibleAnswers = {...},
		question = question,
		answer = answer
	}
end

-- A function to remove a quiz question.
function cw.quiz:RemoveQuestion(question)
	if (stored[question]) then
		stored[question] = nil
	else
		local index = cw.core:GetShortCRC(question)

		if (stored[index]) then
			stored[index] = nil
		end
	end
end

if (CLIENT) then
	function cw.quiz:SetCompleted(completed)
		self.completed = completed
	end

	-- A function to get whether the quiz is completed.
	function cw.quiz:GetCompleted()
		return self.completed
	end

	-- A function to get the quiz panel.
	function cw.quiz:GetPanel()
		if (IsValid(self.panel)) then
			return self.panel
		end
	end
else
	function cw.quiz:SetCompleted(player, completed)
		if (completed) then
			player:SetData("Quiz", self:GetQuestionsAmount())
		else
			player:SetData("Quiz", nil)
		end

		netstream.Start(player, "QuizCompleted", completed)
	end

	-- A function to get whether a player has completed the quiz.
	function cw.quiz:GetCompleted(player)
		if (player:GetData("Quiz") == self:GetQuestionsAmount()) then
			return true
		else
			return player:IsBot()
		end
	end

	-- A function to set the quiz percentage.
	function cw.quiz:SetPercentage(percentage)
		self.percentage = percentage
	end

	-- A function to get the quiz percentage.
	function cw.quiz:GetPercentage()
		return self.percentage or 100
	end

	-- A function to call the quiz kick Callback.
	function cw.quiz:CallKickCallback(player, correctAnswers)
		local kickCallback = self:GetKickCallback()

		if (kickCallback) then
			kickCallback(player, correctAnswers)
		end
	end

	-- A function to get the quiz kick Callback.
	function cw.quiz:GetKickCallback()
		if (self.kickCallback) then
			return self.kickCallback
		else
			return function(player, correctAnswers)
				player:Kick(cw.lang:GetString("en", "#QuizPanel_KickReason"))
			end
		end
	end

	-- A function to set the quiz kick Callback.
	function cw.quiz:SetKickCallback(Callback)
		self.kickCallback = Callback
	end
end
