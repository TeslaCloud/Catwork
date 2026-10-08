--- English strings of the Combine Civil Authority plugin: the Combine PDA and its citizen status, residence, job,
-- points and isolation dialogs, its log entries and notifications, and the information terminal.

local lang = cw.lang:GetTable('en')

lang['#Combine_PDA'] = 'Combine PDA'
lang['#Combine_PDA_Desc'] = 'Access various Combine systems and the citizen registry.'
lang['#Err_CMB_InsufficientPermissions'] = "ERROR: Insufficient permissions to access the unit's data."
lang['#Status_Title'] = 'Change Citizen Status'
lang['#Status_Desc'] = 'What status would you like this citizen to have?'
lang['#Status_Citizen'] = 'Citizen'
lang['#Status_Unverified'] = 'Unverified'
lang['#Status_AntiCitizen'] = 'Anti-Citizen'
lang['#Status_NoData'] = 'No Data'
lang['#Status_Unknown'] = 'Unknown'
lang['#Status_Deceased'] = 'Deceased'
lang['#OK'] = 'OK'
lang['#Cancel'] = 'Cancel'
lang['#PDA_ChangeCitizenStatus'] = 'Change Citizen Status'
lang['#PDA_ChangeResidence'] = 'Change Residential Address'
lang['#PDA_ChangeJob'] = 'Change Civil Faction'
lang['#PDA_CWUPoints'] = 'Issue Union Points'
lang['#PDA_LP'] = 'Issue Loyalty Points'
lang['#PDA_CP'] = 'Issue Crime Points'
lang['#PDA_Card'] = 'View Data Card'
lang['#PDA_Jail'] = 'Issue Isolation Order'
lang['#PDA_Unjail'] = 'Revoke Isolation Order'
lang['#LP'] = 'LP'
lang['#CP'] = 'CP'
lang['#WP'] = 'WP'
lang['#Job_Title'] = "Change Worker's Faction"
lang['#Job_Desc'] = "What union worker's faction would you like to assign this citizen to?"
lang['#Residence_Title'] = 'Realty Manager'
lang['#Residence_Desc'] = 'What address or room number would you like to assign to this citizen?'
lang['#Residence'] = 'Realty'

lang['#PDA_SubLP'] = 'Remove Loyalty Points'
lang['#PDA_SubCP'] = 'Remove Crime Points'
lang['#PDA_IssuePointsDesc'] = 'How many points do you want to issue?'
lang['#PDA_RemovePointsDesc'] = 'How many points do you want to remove?'
lang['#PDA_JailConfirm'] = 'Are you sure you want to isolate this citizen?'
lang['#PDA_UnjailConfirm'] = 'Are you sure you want to remove the isolation from this citizen?'
lang['#PDA_Error'] = 'ERROR!'
lang['#PDA_NoLogs'] = 'There are no logs to display!'

lang['#PDA_Log_UnknownEntry'] = 'UNKNOWN ENTRY'
lang['#PDA_Log_Overwatch'] = 'Overwatch'
lang['#PDA_Log_CitizenStatus'] = 'Citizen status changed:'
lang['#PDA_Log_Residence'] = 'Residence changed:'
lang['#PDA_Log_Job'] = 'Job changed:'
lang['#PDA_Log_LP'] = 'Loyalty points changed:'
lang['#PDA_Log_CP'] = 'Crime points changed:'
lang['#PDA_Log_WP'] = 'Work points changed:'
lang['#PDA_Log_Jail'] = 'Isolation order issued!'
lang['#PDA_Log_Unjail'] = 'Isolation order revoked!'

lang['#PDA_NotCWUOrCombine'] = "You are not a Civil Worker's Union worker or the Combine!"
lang['#PDA_NotCombine'] = 'You are not the Combine!'
lang['#PDA_CitizenStatusSet'] = "You have set #1's citizen status to"
lang['#PDA_ResidenceSet'] = "#1's residential address was set to"
lang['#PDA_JobSet'] = "#1's job was set to"
lang['#PDA_LPIssued'] = 'Issued #1 loyalty points to #2.'
lang['#PDA_LPRemoved'] = 'Removed #1 loyalty points from #2.'
lang['#PDA_CPIssued'] = 'Issued #1 crime points to #2.'
lang['#PDA_CPRemoved'] = 'Removed #1 crime points from #2.'
lang['#PDA_WPIssued'] = 'Issued #1 work points to #2.'
lang['#PDA_JailDone'] = 'The isolation order for #1 has been successfully executed!'
lang['#PDA_UnjailDone'] = 'The isolation order for #1 has been successfully removed!'
lang['#PDA_Jailed'] = 'You are now under isolation!'
lang['#PDA_Unjailed'] = 'You are no longer under isolation!'

lang['#CombineMonitor_Title'] = 'Information Terminal'
lang['#CombineMonitor_Waiting'] = 'Awaiting data input...'
lang['#CombineMonitor_Name'] = 'Name'
lang['#CombineMonitor_ID'] = 'ID'
lang['#CombineMonitor_Loyalty'] = 'Loyalty'
lang['#CombineMonitor_Violations'] = 'Violations'
lang['#CombineMonitor_Work'] = 'Work: #1 (lvl #2)'
lang['#CombineMonitor_Status'] = 'Status'
lang['#CombineMonitor_Residence'] = 'Residence'
lang['#CombineMonitor_Job'] = 'Civil faction'
lang['#CombineMonitor_VerifyStatus'] = 'Verify your status'
lang['#CombineMonitor_AtCWU'] = 'at the CWU office'
