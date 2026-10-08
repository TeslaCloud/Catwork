--- English strings of the Radiation plugin: containment zone command syntax and notifications, radiation sickness
-- messages and the filter, Geiger counter, PDB-6 and PDB manual items.

local lang = cw.lang:GetTable('en')

-- Commands
lang['#Command_Containmentboxplace_Syntax'] = '<number Rad/second>'
lang['#Command_Containmentremove_Syntax'] = '[number Search Radius]'
lang['#Command_Containmentsphereplace_Syntax'] = '<number Radius> <number Rad/second>'
lang['#Containment_NoStartPoint'] = 'No start point found.'
lang['#Containment_StartPointSet'] = 'You have set the start point. Now set the end point.'
lang['#Containment_EndPointSet'] = 'You have set the end point.'
lang['#Containment_NoStartPos'] = 'No start position specified.'
lang['#Containment_NoEndPos'] = 'No end position specified.'
lang['#Containment_NoPos'] = 'No position specified.'
lang['#Containment_BoxAdded'] = 'You have added a containment area with the specified parameters: rad: #1.'
lang['#Containment_SphereAdded'] = 'You have added a containment area with the specified parameters: radius: #1, rad: #2.'
lang['#Containment_Removed'] = 'You have removed #1 contamination areas.'
lang['#Containment_NoneFound'] = 'There were no contaminated areas near this position.'
lang['#Containment_Saved'] = 'You have saved the containment areas.'
lang['#Containment_InvalidNumber'] = 'You have to specify a valid number.'

-- Radiation
lang['#Containment_RadPerSecond'] = 'rad/s'
lang['#Containment_RadSickness_Stage1'] = 'You feel very nauseous. After throwing up, you feel slightly tired.'
lang['#Containment_RadSickness_Stage2'] = 'You feel very tired, the vomiting does not stop, and your recovery time is getting longer.'
lang['#Containment_RadSickness_Stage3'] = 'You are bleeding very heavily. You feel terrible, and your hair is falling out.'
lang['#Containment_RadSickness_Stage4'] = 'You are bleeding heavily and continuously. You are vomiting blood.'
lang['#Containment_RadSickness_Stage5'] = 'You are bleeding internally. On top of that, your abdomen is bloated and you are in terrible agony.'
lang['#Containment_RadKnockout'] = '** You are exhausted and feel very sick. You feel a fever all over your body...'
lang['#Containment_FilterBar'] = 'FILTER'

-- Items
lang['#Containment_UseText_ReplaceFilter'] = 'Replace Filter'
lang['#Containment_UseText_Read'] = 'Read'
lang['#Containment_UseText_Check'] = 'Check'
lang['#Item_Filter_PrintName'] = 'Filter'
lang['#Item_Filter_Description'] = 'A filter for GP-5 and GCP-1 type gas masks.'
lang['#Item_Filter_Condition'] = 'Filter condition: #1%'
lang['#Item_GeigerCounter_PrintName'] = 'Geiger Counter'
lang['#Item_GeigerCounter_Description'] = 'An old-looking device for measuring background radiation.'
lang['#Item_PdbBook_PrintName'] = 'PDB User Manual'
lang['#Item_PdbBook_Description'] = 'A rather shabby-looking red book.'
lang['#Item_RadChecker_PrintName'] = 'PDB-6'
lang['#Item_RadChecker_Description'] = 'A device for measuring the radiation dose absorbed by a body.'
lang['#Containment_Book_Learned'] = 'Having read the book, you have improved your medical skills.'
lang['#Containment_Book_AlreadyKnown'] = 'You are already familiar with the contents of this book.'
lang['#Containment_RadDose'] = "Subject's radiation dose:"
lang['#Containment_RadDose_Unknown'] = 'unknown.'
lang['#Containment_RadDose_Value'] = '#1 rad.'
lang['#Containment_RadChecker_NoSkill'] = 'Your medical skills are not sufficient to use this device.'
