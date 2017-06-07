@ECHO off

echo Example: cd c:\temp\sql
echo Example: exec_initialization.bat MIKE-BASE-2012 sa hst@9asc HSTASC c:\temp\sql 1 1
echo Tip!!: to monitor progress of batch file, start powershell and run the following:  Get-Content c:\temp\HSTASC_Error.txt –Wait
echo.
echo server name: %1
echo db username: %2
echo db userpwd : %3
echo db name    : %4
echo source code dir : %5
echo update flag: %6
SET update=%6

echo center (first center only): %7

SET TRACEFILE=c:\temp\%4_Error.txt
SET CHPFILE=c:\temp\%4_ckp.txt

if not exist c:\temp md c:\temp 

if exist "%TRACEFILE%" del /Q "%TRACEFILE%"
if exist "%CHPFILE%" del /Q "%CHPFILE%"

if %update%==1 (
	rem ************************************************************************************
	rem Pre-Update data fixes.  no point in doing this unless we are doing an update
	rem ************************************************************************************

	ECHO Processing dat_DataFixes_PreUpdate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -i %5\Data\dat_DataFixes_PreUpdate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
)

	rem ************************************************************************************
	rem full text system procs - the real ones, not the posers
	rem ************************************************************************************

	ECHO Processing p_Create_FullTextCatalog.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_Create_FullTextCatalog.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_Create_FullTextIndex.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_Create_FullTextIndex.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_Drop_FullTextIndex.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_Drop_FullTextIndex.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

if %update%==0 (
	rem ************************************************************************************
	rem Pathways Tables that have have full text indexes that need to be created.
	rem ************************************************************************************

	ECHO Processing t_ItemMaster.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_ItemMaster.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_CPTCode.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_CPTCode.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_LanguageCode.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_LanguageCode.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_Disposition.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_Disposition.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_ICDDiag.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_ICDDiag.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_Employee.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_Employee.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_Physician.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_Physician.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_VisitParticipant.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_VisitParticipant.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_VisitPhysician.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_VisitPhysician.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 


)

if %update%==0 (
	rem ************************************************************************************
	rem EHR Tables
	rem ************************************************************************************

	rem System Tables

	ECHO Processing t_EHR_Area.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Area.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_AreaFunction.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AreaFunction.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Category.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Category.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_EquipmentCategory.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_EquipmentCategory.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_DBDictionary.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DBDictionary.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_ViewPrimaryTable.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ViewPrimaryTable.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_CenterConfiguration.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_CenterConfiguration.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_DischargeInstruction.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DischargeInstruction.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_AnesthesiaConfig.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AnesthesiaConfig.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_AnesthesiaMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AnesthesiaMedication.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_UserPreference.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_UserPreference.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	rem Configuration Tables
	
	ECHO Processing t_EHR_ConsentType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ConsentType.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_QuestionRhetorical.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_QuestionRhetorical.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_QuestionType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_QuestionType.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_QuestionTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_QuestionTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_QuestionnaireTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_QuestionnaireTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_QuestionnaireQuestionTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_QuestionnaireQuestionTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_ChartConfiguration.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ChartConfiguration.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_ChartMaster.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ChartMaster.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_ChartTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ChartTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_BundleTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_BundleTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_WorkflowTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_WorkflowTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_ModuleTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ModuleTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_ChartBundleTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ChartBundleTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_ChartWorkflowTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ChartWorkflowTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_BundleWorkflowTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_BundleWorkflowTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_WorkflowModuleTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_WorkflowModuleTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_WorkflowModuleDependencyTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_WorkflowModuleDependencyTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_FieldSet.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_FieldSet.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_UIDictionary.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_UIDictionary.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_UIDictionary_Archive.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_UIDictionary_Archive.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_FieldSetIdentifyingField.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_FieldSetIdentifyingField.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_DBDictionaryUIDictionary.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DBDictionaryUIDictionary.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_HL7InterfaceTrigger.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_HL7InterfaceTrigger.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_HL7InterfaceTriggerMessage.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_HL7InterfaceTriggerMessage.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_AuditLog.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AuditLog.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_HX_AuditLog.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_HX_AuditLog.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_HX_AuditRow.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_HX_AuditRow.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_HX_AuditRowDelta.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_HX_AuditRowDelta.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_HX_AuditRowPrimaryKey.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_HX_AuditRowPrimaryKey.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_AnesthesiaGas.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AnesthesiaGas.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_BodySite.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_BodySite.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_TransportType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_TransportType.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Position.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Position.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Typeahead.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Typeahead.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_LateStartReason.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LateStartReason.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	 
	ECHO Processing t_EHR_Route.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Route.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_LOINC.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LOINC.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Lab.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Lab.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Test.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Test.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_LabTest.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LabTest.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_PositioningAidType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PositioningAidType.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_TRDictionary.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_TRDictionary.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Sterilizer.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Sterilizer.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_SterilizationContainer.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_SterilizationContainer.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_LaryngoscopeBlade.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LaryngoscopeBlade.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_O2DeliveryType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_O2DeliveryType.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_FTSearch.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_FTSearch.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_UnitOfMeasure.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_UnitOfMeasure.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 


	rem Chart Tables

	ECHO Processing t_EHR_Chart.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Chart.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Bogus.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Bogus.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Bundle.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Bundle.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Workflow.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Workflow.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Module.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Module.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_QuestionResponse.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_QuestionResponse.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_CommunicationLog.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_CommunicationLog.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_CommunicationLogDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_CommunicationLogDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_PatientLimitation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PatientLimitation.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Prep.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Prep.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_PrepDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PrepDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_PsychosocialStatus.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PsychosocialStatus.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_SkinCondition.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_SkinCondition.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_VitalSigns.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_VitalSigns.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_WoundClass.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_WoundClass.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_RoomTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_RoomTime.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_EventTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_EventTime.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Solution.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Solution.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Dressing.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Dressing.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_DressingDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DressingDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_NPOStatus.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_NPOStatus.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_HeightWeightBMI.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_HeightWeightBMI.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_Dentition.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Dentition.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_ObserverInformation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ObserverInformation.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_AirwayManagement.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AirwayManagement.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_ColonDecompression.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ColonDecompression.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_PatientPosition.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PatientPosition.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_DrainsAndPacks.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DrainsAndPacks.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_Thermoregulation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Thermoregulation.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_Specimen.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Specimen.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_SpecimenDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_SpecimenDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_PositioningAid.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PositioningAid.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_Tourniquet.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Tourniquet.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_TourniquetDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_TourniquetDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_DischargeStatus.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DischargeStatus.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_IVDiscontinued.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_IVDiscontinued.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_DressingAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DressingAssessment.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_XRay.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_XRay.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_XRayDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_XRayDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_IVInsertion.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_IVInsertion.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_VTERiskAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_VTERiskAssessment.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_Person.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Person.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing t_EHR_Signature.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Signature.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing t_EHR_PatientValuables.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PatientValuables.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_LevelOfConsciousness.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LevelOfConsciousness.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_InstrumentSterilization.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_InstrumentSterilization.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_Anesthesia.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Anesthesia.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_PatientArrivalTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PatientArrivalTime.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_CancelCase.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_CancelCase.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_OxygenTherapy.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OxygenTherapy.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_OxygenTherapyDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OxygenTherapyDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_Note.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Note.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_VisitAddendum.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_VisitAddendum.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_Diagnosis.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Diagnosis.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_DiagnosisPreOp.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DiagnosisPreOp.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_DiagnosisPostOp.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DiagnosisPostOp.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_Procedure.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Procedure.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_ScheduledProcedure.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ScheduledProcedure.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_PerformedProcedure.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PerformedProcedure.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_InterimOperativeReport.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_InterimOperativeReport.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_FallRiskAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_FallRiskAssessment.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_BloodProductAdministration.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_BloodProductAdministration.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_PainAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PainAssessment.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_FireRiskAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_FireRiskAssessment.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_LearningAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LearningAssessment.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_Discharge.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Discharge.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_TimeOut.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_TimeOut.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_PostOpExtremityCheck.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PostOpExtremityCheck.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_PostOpExtremityCheckDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PostOpExtremityCheckDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_PatientHandoff.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PatientHandoff.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_Counts.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Counts.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_CountsDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_CountsDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_PostAnesthesiaRecoveryScore.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PostAnesthesiaRecoveryScore.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_IntakeAndOutputDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_IntakeAndOutputDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_AnesthesiaPostOpAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AnesthesiaPostOpAssessment.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_ConsciousSedation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ConsciousSedation.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_Explant.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Explant.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_PatientTransfer.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PatientTransfer.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_PostAnesthesiaCare.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PostAnesthesiaCare.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	 
	ECHO Processing t_EHR_PostAnesthesiaCareDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PostAnesthesiaCareDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_OperativeReportDocument.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OperativeReportDocument.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_OperativeReportDocumentDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OperativeReportDocumentDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_Alert.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Alert.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_OrderSignature.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OrderSignature.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_OrderTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OrderTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_OrderTextTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OrderTextTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_OrderMedicationTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OrderMedicationTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_Order.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Order.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_OrderText.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OrderText.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_OrderMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OrderMedication.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_OrderPhysicianSignature.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OrderPhysicianSignature.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_OrderAnesthesiaSignature.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OrderAnesthesiaSignature.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_Cautery.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Cautery.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_CauteryDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_CauteryDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing t_EHR_LaserOphthalmic.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LaserOphthalmic.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_LaserOphthalmicDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LaserOphthalmicDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_EquipmentOtherDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_EquipmentOtherDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_QuickChartMaster.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_QuickChartMaster.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_OperativeReport.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_OperativeReport.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_PostOpCare.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PostOpCare.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_Problem.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Problem.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_ProblemDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ProblemDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_InstrumentTray.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_InstrumentTray.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_InstrumentTrayDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_InstrumentTrayDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_AuditRow.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AuditRow.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_AuditRowDelta.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AuditRowDelta.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_AuditRowPrimaryKey.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AuditRowPrimaryKey.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_AllergyChart.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AllergyChart.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_AllergyReaction.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AllergyReaction.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_AllergyChartDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AllergyChartDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_AllergyModule.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AllergyModule.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_HomeMedicationDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_HomeMedicationDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_HomeMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_HomeMedication.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_MedicationReconciliationSignature.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_MedicationReconciliationSignature.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_StaffDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_StaffDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	
	
	ECHO Processing t_EHR_Document.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Document.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_DocumentDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DocumentDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_HistoryAndPhysicalAttestation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_HistoryAndPhysicalAttestation.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_SupplyUsed.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_SupplyUsed.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_SupplyUsedDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_SupplyUsedDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_ImplantLog.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ImplantLog.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_ImplantLogDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ImplantLogDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_Consent.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Consent.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_QuestionCategory.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_QuestionCategory.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_QuestionTemplateArea.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_QuestionTemplateArea.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_QuestionTemplateCategory.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_QuestionTemplateCategory.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_MedicationAdministrationDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_MedicationAdministrationDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_MedicationAdministration.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_MedicationAdministration.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_ASAClassification.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ASAClassification.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_AnesthesiaPhysicalAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AnesthesiaPhysicalAssessment.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_BodySiteConceptCode.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_BodySiteConceptCode.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing t_EHR_GCode.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_GCode.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_GCodeDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_GCodeDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing t_EHR_DocumentReview.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DocumentReview.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_DocumentReviewDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DocumentReviewDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_BloodGlucoseDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_BloodGlucoseDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing t_EHR_GSDDMedicationGroup.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_GSDDMedicationGroup.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing t_EHR_LabPathDocument.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LabPathDocument.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing t_EHR_LabPathDocumentDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LabPathDocumentDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing t_EHR_LabPathDocumentReviewDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LabPathDocumentReviewDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing t_EHR_LabPathMissingResultDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LabPathMissingResultDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_VersedFentanylSummary.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_VersedFentanylSummary.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_HistoryAndPhysical.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_HistoryAndPhysical.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing t_EHR_InHouseLabResults.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_InHouseLabResults.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_InHouseLabResultsDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_InHouseLabResultsDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_InHouseLabResultsReview.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_InHouseLabResultsReview.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_InHouseLabResultsReviewDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_InHouseLabResultsReviewDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_ScheduledAnesthesia.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ScheduledAnesthesia.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_PerformedAnesthesia.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PerformedAnesthesia.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing t_EHR_ConsentQuestionnaireTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ConsentQuestionnaireTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing t_EHR_ChartTemplateStore.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ChartTemplateStore.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing t_EHR_CLOTest.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_CLOTest.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing t_EHR_InjectionInformation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_InjectionInformation.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_AnesthesiaCare.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AnesthesiaCare.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_LaserOther.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LaserOther.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_LaserOtherDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LaserOtherDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
		
	ECHO Processing t_EHR_LaserPowerUnit.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LaserPowerUnit.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_LaserTimeUnit.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_LaserTimeUnit.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing t_EHR_AnesthesiaHistory.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AnesthesiaHistory.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing t_EHR_Image.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Image.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Pin.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Pin.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
		
	ECHO Processing t_EHR_Traction.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Traction.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_TractionDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_TractionDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_RoomInHardStop.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_RoomInHardStop.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_MonitorModel.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_MonitorModel.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_MonitorModelCenter.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_MonitorModelCenter.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Monitor.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Monitor.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_MonitorCenterConfiguration.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_MonitorCenterConfiguration.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_MonitorModelCenterConfiguration.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_MonitorModelCenterConfiguration.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_MonitorOwner.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_MonitorOwner.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_VitalSignsModule.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_VitalSignsModule.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_QuestionHistoric.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_QuestionHistoric.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_TaskTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_TaskTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_Task.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Task.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_TaskAssignment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_TaskAssignment.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_ColonoscopyTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ColonoscopyTime.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_MonitorPendingData.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_MonitorPendingData.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_AllergenMedicationAlias.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AllergenMedicationAlias.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_ItemMasterRouteDefault.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ItemMasterRouteDefault.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_PostAnesthesiaAirwayDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PostAnesthesiaAirwayDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_DischargeInstructionSet.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DischargeInstructionSet.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_DischargeInstructionSetDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DischargeInstructionSetDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_DischargeInstructions.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DischargeInstructions.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_DischargeInstructionsDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DischargeInstructionsDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_DischargeInstructionsReview.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_DischargeInstructionsReview.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_PrintSet.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PrintSet.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_PrintSetDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PrintSetDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_PrintSetArea.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PrintSetArea.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_PrintSetWorkflow.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_PrintSetWorkflow.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_BedsideVisitDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_BedsideVisitDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_ProgressNote.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_ProgressNote.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_EffectiveUserPermission.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_EffectiveUserPermission.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_Side.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Side.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing t_EHR_VitalsAnesthesiaGraph.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_VitalsAnesthesiaGraph.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_AnesthesiaGasDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AnesthesiaGasDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_AnesthesiaGraphModuleGasConfig.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AnesthesiaGraphModuleGasConfig.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_AnesthesiaGraphModuleMedicationConfig.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AnesthesiaGraphModuleMedicationConfig.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
		
	ECHO Processing t_EHR_AnesthesiaGraphGasConfig.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AnesthesiaGraphGasConfig.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing t_EHR_AnesthesiaGraphMedicationConfig.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_AnesthesiaGraphMedicationConfig.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 


)
	rem ************************************************************************************
	rem Any tables that are brand new post v1.5 go here as well as in the above section.  
	rem we want to run these scripts both on updates and on new installs
	rem ************************************************************************************
if %update%==1 (
	ECHO Processing t_EHR_Side.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Tables\t_EHR_Side.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
)

	rem ************************************************************************************
	rem Views
	rem ************************************************************************************
		

	ECHO Processing v_EHR_QuestionResponse.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_QuestionResponse.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing v_EHR_LookUpEHROrder.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_LookUpEHROrder.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
		
	ECHO Processing v_EHR_LookUpItemMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_LookUpItemMedication.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
		
	ECHO Processing v_EHR_Bundle.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_Bundle.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 


	ECHO Processing v_EHR_UIDictionary.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_UIDictionary.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_WorkflowUIDictionary.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_WorkflowUIDictionary.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_Employee.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_Employee.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_Image.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_Image.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_Physician.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_Physician.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing v_EHR_UserStaff.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_UserStaff.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing v_EHR_WorkflowRoomTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_WorkflowRoomTime.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing v_EHR_O2DeliveryType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_O2DeliveryType.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_BundleEventTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_BundleEventTime.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_Modifier.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_Modifier.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_AnesthesiaPostOpAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_AnesthesiaPostOpAssessment.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing v_EHR_PositioningAid.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_PositioningAid.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_UserFullName.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_UserFullName.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_InstrumentSterilization.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_InstrumentSterilization.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_DrainsAndPacks.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_DrainsAndPacks.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	 
	ECHO Processing v_EHR_Header.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_Header.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	 
	ECHO Processing v_EHR_WorkflowArea.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_WorkflowArea.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_IntakeAndOutputDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_IntakeAndOutputDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
		
	ECHO Processing v_EHR_IVInsertion.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_IVInsertion.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	


	ECHO Processing v_EHR_ItemMasterForTourniquet.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_ItemMasterForTourniquet.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_LaserOphthalmicDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_LaserOphthalmicDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_PatientHandoff.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_PatientHandoff.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_PatientHandoffToArea.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_PatientHandoffToArea.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_TourniquetDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_TourniquetDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_PatientDocument.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_PatientDocument.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_DischargeMedicationDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_DischargeMedicationDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing v_EHR_DischargeInstructionsDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_DischargeInstructionsDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing v_EHR_Gender.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_Gender.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_EmployeeType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_EmployeeType.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing v_EHR_ImplantLogDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_ImplantLogDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing v_EHR_ItemMasterForCautery.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_ItemMasterForCautery.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing v_EHR_Disposition.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_Disposition.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing v_EHR_BloodGlucoseDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_BloodGlucoseDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing v_EHR_VersedFentanylSummary.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_VersedFentanylSummary.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing v_EHR_ItemEquipmentForTourniquet.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_ItemEquipmentForTourniquet.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing v_EHR_OxygenTherapyComplex.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_OxygenTherapyComplex.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing v_EHR_ItemMasterForLaserOther.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_ItemMasterForLaserOther.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing v_EHR_LaserOtherDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_LaserOtherDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing v_EHR_ProblemDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_ProblemDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_PatientLocation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_PatientLocation.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing v_EHR_PinnedItems.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_PinnedItems.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing v_EHR_BLOCList.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_BLOCList.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing v_EHR_PatientLocations.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_PatientLocations.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing v_EHR_PatientHandoffFromArea.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_PatientHandoffFromArea.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing v_EHR_EquipmentOtherDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_EquipmentOtherDetail.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing v_EHR_AnesthesiaType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Views\v_EHR_AnesthesiaType.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	rem ************************************************************************************
	rem Functions
	rem ************************************************************************************
	
	ECHO Processing f_EHR_PatientIdVisit.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_PatientIdVisit.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing f_EHR_PatientAllergies.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_PatientAllergies.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing f_EHR_GetDOS.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetDOS.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing f_EHR_GetProcedures.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetProcedures.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing f_EHR_GetPhysicians.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetPhysicians.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing f_EHR_IsConsentSigned.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsConsentSigned.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing f_EHR_IsChartProcedureConsentSigned.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsChartProcedureConsentSigned.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing f_EHR_GetLastActionUser.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetLastActionUser.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing f_EHR_GetLastActionDate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetLastActionDate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_NormalizeDate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_NormalizeDate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_GetAnesthesiaType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetAnesthesiaType.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_GetFULLName.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetFULLName.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_GetVisitStatus.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetVisitStatus.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_NeedsAuditDelta.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_NeedsAuditDelta.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_GetQuestionTemplateKey.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetQuestionTemplateKey.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	
	
	ECHO Processing f_EHR_GetServiceName.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetServiceName.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	
	
	ECHO Processing f_EHR_Init_AppendVersionNumber.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_Init_AppendVersionNumber.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	

	ECHO Processing f_EHR_Age.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_Age.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	

	ECHO Processing f_EHR_MergePrefCard.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_MergePrefCard.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	
	
	ECHO Processing f_EHR_MergePrefCard_Equipment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_MergePrefCard_Equipment.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	

	ECHO Processing f_EHR_NormalizeTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_NormalizeTime.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	
	
	ECHO Processing f_EHR_GetPathwaysProceduresByVisitKey.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetPathwaysProceduresByVisitKey.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	
	
	ECHO Processing f_EHR_GetPathwaysProceduresByChartKey.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetPathwaysProceduresByChartKey.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	

	ECHO Processing f_EHR_GetPathwaysPreopDiagnosesByVisitKey.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetPathwaysPreopDiagnosesByVisitKey.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	

	ECHO Processing f_EHR_GetPathwaysPreopDiagnosesByChartKey.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetPathwaysPreopDiagnosesByChartKey.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	
	
	ECHO Processing f_EHR_GetPathwaysPlannedAnesthesiaByVisitKey.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetPathwaysPlannedAnesthesiaByVisitKey.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	
	
	ECHO Processing f_EHR_GetPathwaysPlannedAnesthesiaByChartKey.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetPathwaysPlannedAnesthesiaByChartKey.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	

	ECHO Processing f_EHR_Allergies.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_Allergies.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	

	ECHO Processing f_EHR_QC_GetModuleTemplates.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_QC_GetModuleTemplates.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing f_EHR_ExistsProcedureQuestion.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_ExistsProcedureQuestion.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing f_EHR_ExistsAnesthesiaQuestion.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_ExistsAnesthesiaQuestion.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing f_EHR_QC_GetQuickChartTemplates.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_QC_GetQuickChartTemplates.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing f_EHR_Init_AppendNameAndVersionNumber.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_Init_AppendNameAndVersionNumber.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
			
	ECHO Processing f_EHR_GetLatestPatientDocKeyByVisitKey.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetLatestPatientDocKeyByVisitKey.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	

	ECHO Processing f_EHR_GetQuestionProblemStatement.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetQuestionProblemStatement.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	

	ECHO Processing f_EHR_GetQuestionResponsesForModule.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetQuestionResponsesForModule.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_GetQuestionLabTestName.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetQuestionLabTestName.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_GetQuestionLabTestResult.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetQuestionLabTestResult.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_IsRoomTimeInCompleted.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsRoomTimeInCompleted.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_IsModuleInFirstBundle.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsModuleInFirstBundle.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_IsModuleNA.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsModuleNA.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_IsPAM.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsPAM.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_IsInRange.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsInRange.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_GetCenterAvatarDays.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetCenterAvatarDays.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_GetLimitationsProblemStatement.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetLimitationsProblemStatement.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_NeedsPreloadResponseForQuestionsHistoric.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_NeedsPreloadResponseForQuestionsHistoric.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_HasWorkflowFullPermission.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_HasWorkflowFullPermission.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_SplitString.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_SplitString.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_AcceptingMonitorDataStartTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_AcceptingMonitorDataStartTime.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_GetModuleDesignIDFromRoomTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetModuleDesignIDFromRoomTime.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_AreaLocationInOut.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_AreaLocationInOut.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_RptGetSecondaryDXString.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_RptGetSecondaryDXString.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_RemoveDupStrings.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_RemoveDupStrings.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_GetUserID.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetUserID.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_GetLatestUserID2.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetLatestUserID2.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_GetRoomTimeUserID3.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetRoomTimeUserID3.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_TaskAdminTable.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_TaskAdminTable.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_CenterPhysicianTable.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_CenterPhysicianTable.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_GetAnesthesiaUserID5.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetAnesthesiaUserID5.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_GetPhysicianUserID8.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetPhysicianUserID8.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_WorkflowUpdateUserTable.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_WorkflowUpdateUserTable.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_GetAllergiesStatement.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetAllergiesStatement.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_isPhysicianOrderNeedSignature.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_isPhysicianOrderNeedSignature.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_GetKeyOfHardCodeQuestionnaireTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetKeyOfHardCodeQuestionnaireTemplate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_IsBLOCExistsInWorkflow.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsBLOCExistsInWorkflow.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_ChartOverdue.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_ChartOverdue.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_GetCenterIDByWorkflowKey.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetCenterIDByWorkflowKey.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_IsBLOCExistsInBundle.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsBLOCExistsInBundle.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_HasPhysicianSignTask.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_HasPhysicianSignTask.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_HasPatientSignTask.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_HasPatientSignTask.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_ConsentSignValidation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_ConsentSignValidation.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_EnableLateStart.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_EnableLateStart.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_IsLateStart.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsLateStart.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_CamelFormat.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_CamelFormat.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_IsRegNextWorkflowRoomIn.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsRegNextWorkflowRoomIn.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_IsMandatory.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsMandatory.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_IsBMM.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_IsBMM.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing f_EHR_PhoneFormatValidation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_PhoneFormatValidation.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing f_EHR_GetBundleKeyByWorkflowKey.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Functions\f_EHR_GetBundleKeyByWorkflowKey.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	rem ************************************************************************************
	rem Sequences
	rem ************************************************************************************

	ECHO Processing s_EHR_AuditLogSequence.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Sequences\s_EHR_AuditLogSequence.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	rem ************************************************************************************
	rem Stored Procedures
	rem ************************************************************************************

	ECHO Processing p_EHR_QC_TableClone.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_TableClone.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_QC_TableClone >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -Q "exec p_EHR_QC_TableClone" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_InteractWithSuppliesUsed.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_InteractWithSuppliesUsed.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_InteractWithVisitImplant.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_InteractWithVisitImplant.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_DischargeStatusBackFilling.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_DischargeStatusBackFilling.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
		
	ECHO Processing p_EHR_Init_RemoveChartTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_RemoveChartTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_Init_CanInstallTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_CanInstallTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_GetBasicUserInfo.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetBasicUserInfo.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_Init_AddBundlesToChartTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_AddBundlesToChartTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_Init_AddWorkflowsToChartTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_AddWorkflowsToChartTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_TA_Staff.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_Staff.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_TA_DischargeInstruction.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_DischargeInstruction.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_TA_PatientPosition.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_PatientPosition.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_TA_ItemMaster.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ItemMaster.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_TA_BodySite.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_BodySite.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_TA_TransportType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_TransportType.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_TA_CPTCode.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_CPTCode.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_TA_ItemMasterForDressing.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ItemMasterForDressing.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_TA_ItemMasterForSolution.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ItemMasterForSolution.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_TA_LanguageCode.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_LanguageCode.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_TA_ItemMasterForXRay.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ItemMasterForXRay.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_TA_ItemMasterForAnesthesiaMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ItemMasterForAnesthesiaMedication.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_TA_Route.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_Route.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_AddRemoveChartWokflowTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AddRemoveChartWokflowTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_AddRemoveModuleWorkflowTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AddRemoveModuleWorkflowTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_AddModuleToWorkflow.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AddModuleToWorkflow.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_RemoveModuleFromWorkflow.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RemoveModuleFromWorkflow.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_ReorderModules.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ReorderModules.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
		
	ECHO Processing p_EHR_CreateChartFromTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CreateChartFromTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CreateWorkflowFromTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CreateWorkflowFromTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CreateChartsFromVisits.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CreateChartsFromVisits.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_ChartCloseOrReopen.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartCloseOrReopen.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_ProvisionQuestionResponses.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ProvisionQuestionResponses.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_GetQuestionsForModule.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetQuestionsForModule.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetSearchedOperativeReports.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetSearchedOperativeReports.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_UpdateOperativeReports.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_UpdateOperativeReports.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_UnAssignOperativeReport.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_UnAssignOperativeReport.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_GetQuestionResponsesForModule.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetQuestionResponsesForModule.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_SyncSupplyUsedWithPathways.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_SyncSupplyUsedWithPathways.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_InterimOperativeReportSimple.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_InterimOperativeReportSimple.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_ImageCapture.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ImageCapture.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_ChartTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ChartTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_GetWorkflow.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_GetWorkflow.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_PatientLimitation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PatientLimitation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_PatientVitals.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PatientVitals.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_Prep.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Prep.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_PsychosocialStatus.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PsychosocialStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_SkinCondition.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_SkinCondition.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_Workflow.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Workflow.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_WorkflowTemplatesql.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_WorkflowTemplatesql.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_CRUD_WoundClass.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_WoundClass.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_InstrumentTrayTracking.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_InstrumentTrayTracking.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_Init_ChartTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_ChartTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_Init_ChartMaster.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_ChartMaster.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_Init_DBDictionary.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_DBDictionary.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_Init_ModuleTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_ModuleTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_Init_WorkflowTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_WorkflowTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_Init_BundleTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_BundleTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_Init_TRDictionary.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_TRDictionary.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
		
	ECHO Processing p_EHR_GetTableMetadata.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetTableMetadata.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
		
	ECHO Processing p_EHR_DeleteChartDataForTable.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_DeleteChartDataForTable.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_DeleteChartDataForVisit.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_DeleteChartDataForVisit.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_DeleteChartsForChartTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_DeleteChartsForChartTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_RoomTimeIn.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_RoomTimeIn.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_RoomTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_RoomTime.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_LET_DischargeInstructions.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_DischargeInstructions.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_LET_QuestionResponse.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_QuestionResponse.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_EventTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_EventTime.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_RoomTimeFillVitalsAnesthesiaGraph.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_RoomTimeFillVitalsAnesthesiaGraph.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_AirwayManagement.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_AirwayManagement.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
		
	ECHO Processing p_EHR_CRUD_ObserverInformation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ObserverInformation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_CRUD_Dentition.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Dentition.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_CRUD_HeightWeightBMI.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_HeightWeightBMI.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_CRUD_Positioning.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Positioning.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_TourniquetSimple.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_TourniquetSimple.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_IncisionStopTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_IncisionStopTime.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_NPOStatus.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_NPOStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_ProcedureChange.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ProcedureChange.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_CRUD_IVDiscontinued.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_IVDiscontinued.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_CRUD_IncisionStartTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_IncisionStartTime.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_CRUD_ColonDecompression.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ColonDecompression.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_DischargeStatus.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_DischargeStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_CRUD_DischargeStatus.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_DischargeStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
		
	ECHO Processing p_EHR_CRUD_DischargeInstructions.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_DischargeInstructions.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
		
	ECHO Processing p_EHR_TA_Disposition.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_Disposition.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_Thermoregulation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Thermoregulation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
		
	ECHO Processing p_EHR_CRUD_PatientInformation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PatientInformation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_IVInsertion.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_IVInsertion.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_VTERiskAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_VTERiskAssessment.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_LET_Location.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_Location.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_CRUD_LevelOfConsciousness.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_LevelOfConsciousness.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_ProphylacticAntibioticAdministration.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ProphylacticAntibioticAdministration.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CalculateProphylacticAntibioticWarning.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CalculateProphylacticAntibioticWarning.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_MedicationAdministration.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_MedicationAdministration.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_PhysicianOrders.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PhysicianOrders.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_PhysicianOrders2.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PhysicianOrders2.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_IsModulePresent.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_IsModulePresent.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_AnesthesiaOrders.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_AnesthesiaOrders.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_CRUD_AnesthesiaOrders2.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_AnesthesiaOrders2.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%


	ECHO Processing p_EHR_CRUD_VitalsAnesthesiaGraph.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_VitalsAnesthesiaGraph.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%


	ECHO Processing p_EHR_LET_RoomTimeAutoFill.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_RoomTimeAutoFill.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_RoomTimeOut.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_RoomTimeOut.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_InstrumentSterilization.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_InstrumentSterilization.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_TA_SterilizationContainer.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_SterilizationContainer.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_TA_ItemMasterForOrderMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ItemMasterForOrderMedication.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CalculateWorkflowCompletion.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CalculateWorkflowCompletion.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CalculateChartCompletion.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CalculateChartCompletion.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CalculateChartIsDirty.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CalculateChartIsDirty.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CalculateWorkflowIsDirty.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CalculateWorkflowIsDirty.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_VisitAddendum.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_VisitAddendum.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_CancelCase.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_CancelCase.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_PatientValuables.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PatientValuables.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_OxygenTherapySimple.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_OxygenTherapySimple.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_FallRiskAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_FallRiskAssessment.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_LET_FallRiskAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_FallRiskAssessment.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_FireRiskAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_FireRiskAssessment.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_CRUD_AnesthesiaStop.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_AnesthesiaStop.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_AnesthesiaStart.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_AnesthesiaStart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_CRUD_TimeOut.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_TimeOut.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_CRUD_LearningAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_LearningAssessment.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_CRUD_PatientArrivalTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PatientArrivalTime.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_CRUD_PositioningAids.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PositioningAids.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_TA_PositioningAidType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_PositioningAidType.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_CRUD_Note.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Note.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_Discharge.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Discharge.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_CRUD_PostOpExtremityCheck.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PostOpExtremityCheck.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_HomePageSchedule.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_HomePageSchedule.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_CRUD_PatientTransfer.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PatientTransfer.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_AnesthesiaPostOpAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_AnesthesiaPostOpAssessment.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_Explant.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Explant.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_ProcedureInformation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ProcedureInformation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_PostAnesthesiaRecoveryScore.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PostAnesthesiaRecoveryScore.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_Dressing.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Dressing.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_DressingAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_DressingAssessment.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
			
	ECHO Processing p_EHR_CRUD_Solution.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Solution.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_XRay.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_XRay.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_ReturnPatientValuables.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ReturnPatientValuables.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_PatientEducation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PatientEducation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_Questions.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Questions.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_CommunicationLog.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_CommunicationLog.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_CountsDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_CountsDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_PatientSafetyMeasures.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PatientSafetyMeasures.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_Chart.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Chart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_GetSummaryData.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetSummaryData.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_GetCurrentSummaryData.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetCurrentSummaryData.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_GetOrCreateChart.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetOrCreateChart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_TA_ItemMasterForDrainsAndPacks.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ItemMasterForDrainsAndPacks.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GETAllergiesAndOrderMedications.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GETAllergiesAndOrderMedications.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_GETAllergiesAndAdministrationMedications.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GETAllergiesAndAdministrationMedications.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_CRUD_PostAnesthesiaCare.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PostAnesthesiaCare.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_DrainsAndPackingPlacement.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_DrainsAndPackingPlacement.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_BloodProductAdministration.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_BloodProductAdministration.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_FTSearch.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_FTSearch.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_LET_FallRiskAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_FallRiskAssessment.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
		
	ECHO Processing p_EHR_InitSeed.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_InitSeed.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_InitQuestionTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_InitQuestionTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
		
	ECHO Processing p_EHR_Init_DeactivateOldChartVersion.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_DeactivateOldChartVersion.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Init_Charts_Standard.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_Charts_Standard.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_Init_Charts_Demo.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_Charts_Demo.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_Seed_Charts.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Seed_Charts.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_CRUD_ConsciousSedation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ConsciousSedation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_LET_HeightWeightBMI.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_HeightWeightBMI.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_LET_Person.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_Person.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_CRUD_IntakeAndOutputDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_IntakeAndOutputDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_DeleteChartMaster.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_DeleteChartMaster.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_ModuleTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ModuleTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_IVInsertion.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_IVInsertion.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"		
		 	
	ECHO Processing p_EHR_IsRemovableModule.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_IsRemovableModule.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	
	
	ECHO Processing p_EHR_TA_Allergy.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_Allergy.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_TA_Allergen.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_Allergen.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_TA_AllergyReaction.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_AllergyReaction.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_TA_HomeMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_HomeMedication.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_AddAfterModuleToWorkflow.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AddAfterModuleToWorkflow.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing p_EHR_CRUD_Allergy.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Allergy.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_CRUD_HomeMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_HomeMedication.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_GetCharts.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetCharts.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	
	
	ECHO Processing p_EHR_GetChartStatus.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetChartStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_GetCenterUsers.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetCenterUsers.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_LET_AllergyChart.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_AllergyChart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_AllergyChartDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_AllergyChartDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_AllergyModule.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_AllergyModule.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_HomeMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_HomeMedication.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_HomeMedicationDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_HomeMedicationDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_MedicationAdministrationAddSupplies.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_MedicationAdministrationAddSupplies.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_MedicationAdministrationUpdateSupplies.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_MedicationAdministrationUpdateSupplies.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_MedicationAdministrationAdministerAll.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_MedicationAdministrationAdministerAll.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_MedicationAdministrationAdministerSet.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_MedicationAdministrationAdministerSet.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_MedicationAdministrationLoadSet.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_MedicationAdministrationLoadSet.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_OrderSignature.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OrderSignature.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_OrderMedicationSign.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OrderMedicationSign.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"


	ECHO Processing p_EHR_LET_OrderMedicationUpdateAdministration.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OrderMedicationUpdateAdministration.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_LoadAnaesthesiaOrderTemplates.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_LoadAnaesthesiaOrderTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_OrderAnesthesiaSignatureUnsign.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OrderAnesthesiaSignatureUnsign.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_OrderAnesthesiaSignatureSign.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OrderAnesthesiaSignatureSign.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
			
	ECHO Processing p_EHR_LET_OrderPhysicianSignature1Unsign.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OrderPhysicianSignature1Unsign.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_LET_OrderPhysicianSignature2Unsign.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OrderPhysicianSignature2Unsign.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_LET_OrderPhysicianSignature3Unsign.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OrderPhysicianSignature3Unsign.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_LET_OrderPhysicianSignature1.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OrderPhysicianSignature1.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_LET_OrderPhysicianSignature2.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OrderPhysicianSignature2.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_OrderPhysicianSignature3.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OrderPhysicianSignature3.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%
		
	ECHO Processing p_EHR_LET_MedicationAdministrationTotalDose.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_MedicationAdministrationTotalDose.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_CRUD_Diagnosis.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Diagnosis.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_DiagnosisPostOpWriteVisitClinicalICD.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_DiagnosisPostOpWriteVisitClinicalICD.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_DiagnosisDifferent.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_DiagnosisDifferent.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_DiagnosisLoadData.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_DiagnosisLoadData.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_DiagnosisPreOp.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_DiagnosisPreOp.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_DiagnosisPostOp.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_DiagnosisPostOp.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_TA_ICD10ForDiagnosis.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ICD10ForDiagnosis.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_TA_ICD9ForDiagnosis.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ICD9ForDiagnosis.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
		
	ECHO Processing p_EHR_SchedRetainVisit.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_SchedRetainVisit.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_SchedCanCancelVisit.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_SchedCanCancelVisit.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_SchedDetachVisit.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_SchedDetachVisit.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_SchedRestoreVisit.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_SchedRestoreVisit.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_SchedFindDetachedVisit.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_SchedFindDetachedVisit.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_SchedAbandonDetachedVisit.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_SchedAbandonDetachedVisit.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_SchedReattachVisit.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_SchedReattachVisit.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_RemoveWorkflow.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RemoveWorkflow.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_LET_ProcedureLoadData.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_ProcedureLoadData.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_GetWorkflows.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetWorkflows.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing p_EHR_WorkflowCreateEvents.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_WorkflowCreateEvents.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_GetWorkflowTemplates.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetWorkflowTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_AddBundleToChart.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AddBundleToChart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_TA_ItemMasterForEquipmentOther.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ItemMasterForEquipmentOther.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_EquipmentOther.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_EquipmentOther.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Init_Charts_Test.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_Charts_Test.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Init_Charts_HSTStandardLong.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_Charts_HSTStandardLong.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Init_Charts_HSTPain.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_Charts_HSTPain.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Init_Charts_HSTOphthamology.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_Charts_HSTOphthamology.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_WorkflowTemplateRequiresBundle.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_WorkflowTemplateRequiresBundle.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetBundleTemplates.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetBundleTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_Cautery.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Cautery.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_Document.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Document.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 	

	ECHO Processing p_EHR_LET_Document.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_Document.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_DocumentDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_DocumentDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing p_EHR_LET_DocumentReview.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_DocumentReview.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_EquipmentLaserOphthalmic.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_EquipmentLaserOphthalmic.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_InterimOperativeReport.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_InterimOperativeReport.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_PatientHandoff.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PatientHandoff.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_TourniquetComplex.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_TourniquetComplex.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_TourniquetDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_TourniquetDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_TA_ItemMasterForLaserOphthalmic.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ItemMasterForLaserOphthalmic.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_PatientArrivalTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_PatientArrivalTime.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_MedicationReconciliation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_MedicationReconciliation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_TA_Physician.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_Physician.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_MedicationReconciliationSign.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_MedicationReconciliationSign.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_Init_Charts_AustinQuestions.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_Charts_AustinQuestions.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_Init_Charts_AustinPain.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_Charts_AustinPain.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_UnsignAllMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_UnsignAllMedication.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_AllergyUnreviewed.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_AllergyUnreviewed.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetPatientActiveDocuments.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetPatientActiveDocuments.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RoomTimeAutoFillVisitClinical.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RoomTimeAutoFillVisitClinical.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RoomTimeAutoFill.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RoomTimeAutoFill.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RptE63000.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RptE63000.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RptE63001.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RptE63001.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RptE63002.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RptE63002.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RptE63003.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RptE63003.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RptE63004.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RptE63004.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RptE63005.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RptE63005.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RptE63006.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RptE63006.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RptE63007.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RptE63007.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RptE63008.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RptE63008.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RptE63009.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RptE63009.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_RptE63010.sql>> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RptE63010.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetCodeObjects.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetCodeObjects.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetQuestionnaireTemplates.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetQuestionnaireTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GETAllergiesAndReconciliationMedications.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GETAllergiesAndReconciliationMedications.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_UncheckStatusAllMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_UncheckStatusAllMedication.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_ASAClassification.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ASAClassification.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_ASAClassification.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_ASAClassification.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_OperativeReportChooseBundlePhysician.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OperativeReportChooseBundlePhysician.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_OperativeReportUnSign.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OperativeReportUnSign.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_OperativeReportSign.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_OperativeReportSign.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_SupplyUsed.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_SupplyUsed.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_SupplyUsed.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_SupplyUsed.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_TA_SupplyUsedDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_SupplyUsedDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_Staff.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Staff.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_StaffDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_StaffDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_TA_StaffRole.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_StaffRole.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_TA_ItemMasterForPrep.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ItemMasterForPrep.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetAllergiesAndOrderMedicationsForPrep.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetAllergiesAndOrderMedicationsForPrep.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_TA_ItemMasterForImplantLog.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ItemMasterForImplantLog.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetConsentTypes.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetConsentTypes.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetConsentOptions.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetConsentOptions.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_GetCenterConfiguration.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetCenterConfiguration.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_UpdateCenterConfiguration.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_UpdateCenterConfiguration.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_GetUnitsOfMeasure.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetUnitsOfMeasure.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_GetRoutes.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetRoutes.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_AddCategoryToQuestionTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_AddCategoryToQuestionTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_GetQuestionnairesForQuestionTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetQuestionnairesForQuestionTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_DeleteCategoryFromQuestionTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_DeleteCategoryFromQuestionTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_GetFilteredQuestionnaireTemplates.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetFilteredQuestionnaireTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_GetQuestionCategories.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetQuestionCategories.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_SearchQuestionTemplates.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_SearchQuestionTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_UpdateQuestionInQuestionnaireTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_UpdateQuestionInQuestionnaireTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_GetAnesthesiaGraphConfig.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetAnesthesiaGraphConfig.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_DeleteAnesthesiaGraphMedicationConfig.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_DeleteAnesthesiaGraphMedicationConfig.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_AddAnesthesiaMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_AddAnesthesiaMedication.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_DeleteAnesthesiaMedication.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_DeleteAnesthesiaMedication.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing p_EHR_ChartDesigner_GetAllAnesthesiaMedications.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetAllAnesthesiaMedications.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_AddAnesthesiaGas.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_AddAnesthesiaGas.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_DeleteAnesthesiaGas.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_DeleteAnesthesiaGas.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"


	ECHO Processing p_EHR_ChartDesigner_AddAnesthesiaGraphMedicationConfig.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_AddAnesthesiaGraphMedicationConfig.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_DeleteAnesthesiaGraphGasConfig.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_DeleteAnesthesiaGraphGasConfig.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_AddAnesthesiaGraphGasConfig.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_AddAnesthesiaGraphGasConfig.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_AddConsentQuestionnaireTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_AddConsentQuestionnaireTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_DeActivateConsentQuestionnaireTemplate.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_DeActivateConsentQuestionnaireTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_GetConsentQuestionnaireTemplates.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetConsentQuestionnaireTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_IsQuestionnaireTemplateInUse.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_IsQuestionnaireTemplateInUse.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing p_EHR_ChartDesigner_DeleteAnesthesiaGraphModuleConfig.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_DeleteAnesthesiaGraphModuleConfig.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_UpdateModuleTemplateAlias.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_UpdateModuleTemplateAlias.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_InitConsentSignature.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_InitConsentSignature.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_Consent.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Consent.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RefreshChartCompletion.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RefreshChartCompletion.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_PainAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PainAssessment.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ConfirmGCodes.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ConfirmGCodes.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_GCodeSelection.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_GCodeSelection.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_QuestionRhetoricalRefresh.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QuestionRhetoricalRefresh.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_AnesthesiaPhysicalAssessment.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_AnesthesiaPhysicalAssessment.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_VitalsGraphAnesthesiaTypeSelect.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_VitalsGraphAnesthesiaTypeSelect.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_CommunicationLog.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_CommunicationLog.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_HistoryAndPhysicalAttestation.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_HistoryAndPhysicalAttestation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_ImplantLog.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ImplantLog.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_ImplantLogDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_ImplantLogDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_AdminJob.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AdminJob.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CancelCaseWorkflowQualifier.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CancelCaseWorkflowQualifier.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_ConsentPhysicianSignature.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_ConsentPhysicianSignature.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GETChartSummary.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GETChartSummary.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_CancelCase.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_CancelCase.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Init_Charts_AustinStandard.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_Charts_AustinStandard.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Init_Charts_AustinOphth.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Init_Charts_AustinOphth.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_TimeOut.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_TimeOut.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_NoteSimple.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_NoteSimple.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_TransitionChartStatus.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TransitionChartStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_BloodGlucose.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_BloodGlucose.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GSDDMedicationGroup.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GSDDMedicationGroup.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RoomTimeAutoFillStaffDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RoomTimeAutoFillStaffDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_DrainsAndPacks.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_DrainsAndPacks.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_PrepDetail.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_PrepDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_Solution.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_Solution.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_Dressing.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_Dressing.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_FillVisitClinicalTimesFromRoomTimeAndEventTime.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_FillVisitClinicalTimesFromRoomTimeAndEventTime.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_FillVisitClinicalTimesFromDischargeStatus.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_FillVisitClinicalTimesFromDischargeStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_QC_GetModuleTemplates.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_GetModuleTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_GetSavedChartTemplates.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetSavedChartTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_ChartTemplate_DeActivate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_ChartTemplate_DeActivate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_GetSavedChartTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetSavedChartTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_SaveChartTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_SaveChartTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_PublishChartTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_PublishChartTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_AddQuestionTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_AddQuestionTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing p_EHR_ChartDesigner_UpdateQuestionTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_UpdateQuestionTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_DeactivateQuestionTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_DeactivateQuestionTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetQuestionTemplates.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetQuestionTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_ChartTemplate_Init.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_ChartTemplate_Init.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_UpdateQuestionnaireTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_UpdateQuestionnaireTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%
	
	ECHO Processing p_EHR_ChartDesigner_AddQuestionnaireTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_AddQuestionnaireTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetQuestionTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetQuestionTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetQuestionnaireTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetQuestionnaireTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%
	
	ECHO Processing p_EHR_ChartDesigner_GetQuestionTypes.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetQuestionTypes.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetQuestionRhetoricalTypes.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetQuestionRhetoricalTypes.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_AddQuestionToQuestionnaireTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_AddQuestionToQuestionnaireTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetQuestionnaireTemplates.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetQuestionnaireTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetAnesthesiaGases.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetAnesthesiaGases.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetAnesthesiaMedications.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetAnesthesiaMedications.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetChartTemplates.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetChartTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetAreas.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetAreas.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetAreas.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetAreas.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetConsentTypes.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetConsentTypes.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetConsentQuestionnaireTemplateMappingTypes.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetConsentQuestionnaireTemplateMappingTypes.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetModuleTemplates.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetModuleTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_DischargeInstruction.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_DischargeInstruction.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_DischargeInstructionSet.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_DischargeInstructionSet.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetModuleTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetModuleTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_ChartDesigner_GetChartMasterTemplates.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetChartMasterTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing p_EHR_CRUD_Specimens.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Specimens.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_TA_Test.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_Test.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_CRUD_VersedFentanylSummary.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_VersedFentanylSummary.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_LET_PerformedProcedure.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_PerformedProcedure.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_QC_GetQuickChartTemplates.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_GetQuickChartTemplates.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_GetDirtyModulesInWorkflow.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetDirtyModulesInWorkflow.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_RemoveModulesAfterUnableToContactPatient.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RemoveModulesAfterUnableToContactPatient.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_AddChartPDFToDocumentCenter.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AddChartPDFToDocumentCenter.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_LET_ConsentSignature.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_ConsentSignature.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_QC_GetReplayInfo.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_GetReplayInfo.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_LET_MedicationAdministrationDetail.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_MedicationAdministrationDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_FIX_AddHeaderModule.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_FIX_AddHeaderModule.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_TA_UserStaff.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_UserStaff.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_HandOffQuickChart.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_HandOffQuickChart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%

	ECHO Processing p_EHR_LET_UpdateAntibioticGCodes.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_UpdateAntibioticGCodes.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_UpdateEventGCodes.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_UpdateEventGCodes.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_DischargeStatusBackFilling.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_DischargeStatusBackFilling.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetUserPermission.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetUserPermission.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_ScheduledProcedures.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ScheduledProcedures.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_LabPathologyResults.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_LabPathologyResults.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_LabPathDocument.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_LabPathDocument.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_LabPathDocumentReview.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_LabPathDocumentReview.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_ScheduledProcedure.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_ScheduledProcedure.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_SyncSchedProcPathways.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_SyncSchedProcPathways.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_UpdateHPAttestation.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_UpdateHPAttestation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_HistoryAndPhysical.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_HistoryAndPhysical.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_CLOtest.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_CLOtest.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_InHouseLabResults.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_InHouseLabResults.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_OxygenTherapyComplex.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_OxygenTherapyComplex.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_CLOtest.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_CLOtest.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_InHouseLabResultsReview.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_InHouseLabResultsReview.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_DrainsAndPackingRemoval.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_DrainsAndPackingRemoval.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_InjectionInformation.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_InjectionInformation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_NormalizeConsentCompletion.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_NormalizeConsentCompletion.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetLiveEditKeys4ChartScope.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetLiveEditKeys4ChartScope.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetLiveEditKeys4LastestRoomIn.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetLiveEditKeys4LastestRoomIn.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_QC_DeleteQuickCharts.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_DeleteQuickCharts.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_QC_DeleteOrphanQuickCharts.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_DeleteOrphanQuickCharts.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetLatestPDFDocKey.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetLatestPDFDocKey.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_AnesthesiaCare.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_AnesthesiaCare.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_EquipmentLaserOther.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_EquipmentLaserOther.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_PostOpCare.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PostOpCare.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetLabResultsReconciliation.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetLabResultsReconciliation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_ProblemList.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ProblemList.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_RecordProblems.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_RecordProblems.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_OperativeReport.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_OperativeReport.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_RecordProblemsFromQuestion.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_RecordProblemsFromQuestion.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_QuestionResponseUpdate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_QuestionResponseUpdate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_DeleteQuickChart.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_DeleteQuickChart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_UpdateChartStatus.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_UpdateChartStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_SpinalEpiduralAnesthesia.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_SpinalEpiduralAnesthesia.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_AnesthesiaHistory.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_AnesthesiaHistory.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_CreateQuickChartMaster.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_CreateQuickChartMaster.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_TA_AnesthesialogistOrCRNA.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_AnesthesialogistOrCRNA.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_GeneralAnesthesiaInduction.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_GeneralAnesthesiaInduction.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_RegionalAnesthesia.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_RegionalAnesthesia.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_TA_NonDisposableItemMaster.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_NonDisposableItemMaster.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_EndotrachealTubeItemCodeUpdate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_EndotrachealTubeItemCodeUpdate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_UpdateChartToComplete.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_UpdateChartToComplete.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_HPAttestationSignature.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_HPAttestationSignature.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_BlueTriangleKiller.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_BlueTriangleKiller.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_AutoCompleteStaffOutTime.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AutoCompleteStaffOutTime.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing p_EHR_AutoCompleteOrders.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AutoCompleteOrders.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_AutoDeleteBogusOrders.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AutoDeleteBogusOrders.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_PatientSafetyMeasures.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_PatientSafetyMeasures.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_GetUserChartPermission.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetUserChartPermission.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_TA_ItemCodeForSupplyUsedDetail.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_ItemCodeForSupplyUsedDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_QC_ProphylacticAntibioticAdministration.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_ProphylacticAntibioticAdministration.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_QC_PatientEducation.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_PatientEducation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_PIN_UnpinningChart.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_PIN_UnpinningChart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_PIN_PinsInfo.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_PIN_PinsInfo.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_PIN_PinningChart.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_PIN_PinningChart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_CheckOrderMedication.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_CheckOrderMedication.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_Traction.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_Traction.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_SurgicalSiteAssessment.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_SurgicalSiteAssessment.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetWorkflowFunctionKey.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetWorkflowFunctionKey.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_RecordLabResultsFromQuestion.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_RecordLabResultsFromQuestion.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_PIN_PinDelete.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_PIN_PinDelete.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_Dressing.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_Dressing.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_OxygenTherapySimple.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_OxygenTherapySimple.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_Solution.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_Solution.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_AuditLogTFR_WorkflowOperation.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AuditLogTFR_WorkflowOperation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_AuditLogTFR_HandleIdentifyFld.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AuditLogTFR_HandleIdentifyFld.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_AuditLogTFR_HandleInsertAction.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AuditLogTFR_HandleInsertAction.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_AuditLogTFR_CreateXmlBySeq.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AuditLogTFR_CreateXmlBySeq.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_AuditLogTFR_RowOperation.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AuditLogTFR_RowOperation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_GetLiveEditKeys4MonitorCode.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetLiveEditKeys4MonitorCode.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_KillSuperfluousAuditRecords.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_KillSuperfluousAuditRecords.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_PIN_PinReorder.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_PIN_PinReorder.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_MedicationAdministration.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_MedicationAdministration.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_RoomTimeIn.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_RoomTimeIn.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetAllActiveMonitorConfigurations.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetAllActiveMonitorConfigurations.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetMonitorConfigurationChanges.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetMonitorConfigurationChanges.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_EquipmentLaserOther.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_EquipmentLaserOther.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_EquipmentLaserOphthalmic.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_EquipmentLaserOphthalmic.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_TourniquetComplex.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_TourniquetComplex.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_ImplantLog.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_ImplantLog.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_PositioningAid.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_PositioningAid.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_TA_MonitorModule.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_TA_MonitorModule.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_QC_Staff.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_Staff.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetLiveEditKeys4VitalsCollectingCorrections.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetLiveEditKeys4VitalsCollectingCorrections.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_UserPermission.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_UserPermission.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_Task_Generation.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Generation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Task_Validation.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Validation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	
	
	ECHO Processing p_EHR_Task_Validation_IncompleteChart.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Validation_IncompleteChart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_GetUserTasks.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetUserTasks.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetReassignUsers.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetReassignUsers.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_UpdateUserTasks.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_UpdateUserTasks.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Task_Generation_IncompleteChartArea.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Generation_IncompleteChartArea.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Task_Generation_IncompleteChart.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Generation_IncompleteChart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing p_EHR_Task_Generation_Job.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Generation_Job.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing p_EHR_CreateTasksByChart.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CreateTasksByChart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_Task_Update_Job.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Update_Job.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	

	ECHO Processing p_EHR_EnsureMonitorUser.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_EnsureMonitorUser.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"	

	ECHO Processing p_EHR_Task_Generation_Lab2000.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Generation_Lab2000.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Task_Validation_Lab2000.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Validation_Lab2000.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Task_Generation_TriageDoc.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Generation_TriageDoc.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Task_Validation_TriageDoc.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Validation_TriageDoc.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Task_Generation_PhyOrd.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Generation_PhyOrd.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Task_Validation_PhyOrd.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Validation_PhyOrd.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_Task_Generation_AnesOrd.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Generation_AnesOrd.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Task_Validation_AnesOrd.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_Validation_AnesOrd.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Task_DeleteTestData.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_DeleteTestData.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Task_WriteUserTask.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Task_WriteUserTask.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_AllergenMedicationAlias_GetDefaultInactive.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AllergenMedicationAlias_GetDefaultInactive.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_AllergenMedicationAlias_Activate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AllergenMedicationAlias_Activate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_GetPatientLocation.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetPatientLocation.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_MonitorCollectingStatus.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_MonitorCollectingStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_ChartImages.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ChartImages.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_ChartDocuments.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ChartDocuments.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_QuestionsOptional.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_QuestionsOptional.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_QuestionsHistoric.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_QuestionsHistoric.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_ColonoscopyTime.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ColonoscopyTime.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_PreloadResponseForQuestionsHistoric.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_PreloadResponseForQuestionsHistoric.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_PIN_PinsRefresh.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_PIN_PinsRefresh.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_PendMonitorData.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_PendMonitorData.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_DeleteAllMonitorPendingData.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_DeleteAllMonitorPendingData.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_Specimens.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_Specimens.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetModuleStatus.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetModuleStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_UpdateModuleStatus.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_UpdateModuleStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_BloodGlucoseDetail.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_BloodGlucoseDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_OperativeReport.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_OperativeReport.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_AllergenMedicationAlias_Get.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AllergenMedicationAlias_Get.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_AllergenMedicationAlias_Remove.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AllergenMedicationAlias_Remove.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_AllergenMedicationAlias_Update.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AllergenMedicationAlias_Update.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_AllergenMedicationAlias_Create.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_AllergenMedicationAlias_Create.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_DocumentDisplay.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_DocumentDisplay.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
		
	ECHO Processing p_EHR_LET_AnesthesiaStartTimeUpdate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_AnesthesiaStartTimeUpdate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_SupervisingAnesthesiaProviderIDUpdate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_SupervisingAnesthesiaProviderIDUpdate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_RoomTimeAutoFillStaffDetailInsert.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RoomTimeAutoFillStaffDetailInsert.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_PostAnesthesiaAirway.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_PostAnesthesiaAirway.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetWorkflowStatus.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetWorkflowStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_Prep.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_Prep.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_UpdateWorkflowStatus.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_UpdateWorkflowStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_QC_EquipmentOther.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_EquipmentOther.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_QC_DrainsAndPackingPlacement.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_QC_DrainsAndPackingPlacement.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_RegistrationStart.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_RegistrationStart.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_CRUD_RegistrationEnd.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_RegistrationEnd.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_AnesthesiaStopTimeUpdate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_AnesthesiaStopTimeUpdate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_RoomTimeInAutoFillRegistrationEnd.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_RoomTimeInAutoFillRegistrationEnd.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_UpdatePatientLocator.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_UpdatePatientLocator.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_BackFillVisitRegistrationTime.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_BackFillVisitRegistrationTime.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetPrintSetDetail.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetPrintSetDetail.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetPrintSetStatus.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetPrintSetStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_FinalAnesthesiaProviderIDUpdate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_FinalAnesthesiaProviderIDUpdate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_InitialAnesthesiaProviderIDUpdate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_InitialAnesthesiaProviderIDUpdate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_UpdatePrintSetStatus.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_UpdatePrintSetStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_AddAreaToPrintSet.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_AddAreaToPrintSet.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_AddBlocToPrintSet.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_AddBlocToPrintSet.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_AddPrintSet.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_AddPrintSet.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_DeactivatePrintSet.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_DeactivatePrintSet.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_GetPrintset.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetPrintset.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_GetPrintSetBlocs.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetPrintSetBlocs.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_GetPrintSets.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_GetPrintSets.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_ChartDesigner_SearchPrintSetBlocs.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_SearchPrintSetBlocs.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_GetModuleFunctionKey.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetModuleFunctionKey.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetUserTasksInAdminView.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetUserTasksInAdminView.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RefreshSupplyUsedCost.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RefreshSupplyUsedCost.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_AutoFillVitalSignsForHistoryAndPhysical.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_AutoFillVitalSignsForHistoryAndPhysical.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_VitalSignInsert.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_VitalSignInsert.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_VitalSignUpdate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_VitalSignUpdate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_LET_VitalSignDeleteOrStrikeThrough.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_VitalSignDeleteOrStrikeThrough.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_RoomTimeAutoFillStaffInTime.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RoomTimeAutoFillStaffInTime.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_RemoveAfterModuleFromWorkflow.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RemoveAfterModuleFromWorkflow.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_BedsideVisit.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_BedsideVisit.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CRUD_ProgressNotes.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CRUD_ProgressNotes.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_StaffDetail_BackfillTime.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_StaffDetail_BackfillTime.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_StaffDetail_BackfillVisitParticipant.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_StaffDetail_BackfillVisitParticipant.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_LET_StaffDetail_BackfillVisitPhys.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_LET_StaffDetail_BackfillVisitPhys.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_ChartDesigner_DeactivateQuestionnaireTemplate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_ChartDesigner_DeactivateQuestionnaireTemplate.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_CalculateEffectiveUserPermissions.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_CalculateEffectiveUserPermissions.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_RemoveInCompletedModules4UnavailablePatient.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_RemoveInCompletedModules4UnavailablePatient.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_EHR_Incomplete.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Incomplete.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_Missing.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_Missing.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_V_RoomTimeIn.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_V_RoomTimeIn.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_V_DischargeStatus.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_V_DischargeStatus.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_GetQuestionResponse.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_GetQuestionResponse.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_EHR_V_Allergy.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_EHR_V_Allergy.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	rem ************************************************************************************
	rem problematic pathways stored procedures - need to get recompiled after indexed views created
	rem ************************************************************************************

	ECHO Processing p_GetAndDeleteUserProfile.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_GetAndDeleteUserProfile.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_GetAndDeleteEmployeeProfile.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_GetAndDeleteEmployeeProfile.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing p_GetAndDeletePhysicianInfo.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_GetAndDeletePhysicianInfo.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"
	
	ECHO Processing p_SupplyUsedItems_Transaction.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i "%5\Stored Procedures\p_SupplyUsedItems_Transaction.sql" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	rem ************************************************************************************
	rem Triggers (these can call stored procedures, so come after)
	rem ************************************************************************************

	ECHO Processing trg_EHR_Signature.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Triggers\trg_EHR_Signature.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing trg_EHR_Module.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Triggers\trg_EHR_Module.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing trg_EHR_Workflow.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Triggers\trg_EHR_Workflow.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
	
	ECHO Processing trg_EHR_O2DeliveryType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Triggers\trg_EHR_O2DeliveryType.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing trg_EHR_TransportType.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Triggers\trg_EHR_TransportType.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	rem ************************************************************************************
	rem Data
	rem ************************************************************************************

	ECHO Processing dat_EHR_LanguageISO.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Data\dat_EHR_LanguageISO.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	rem ************************************************************************************
	rem Post-Update data fixes.  
	rem ************************************************************************************

	ECHO Processing dat_DataFixes_PostUpdate.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -i %5\Data\dat_DataFixes_PostUpdate.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

:centerLoopTop
		IF [%7]==[] goto centerLoopDone
		ECHO Running for center %7

		ECHO Processing p_EHR_InitSeed %7 >> "%TRACEFILE%" 
		sqlcmd -S %1 -U %2 -P %3 -d %4 -I -Q "exec p_EHR_InitSeed %7" /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
		sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 
			
		SHIFT /7
		goto centerLoopTop
	

:centerLoopDone
	ECHO Processing dat_EHR_LOINC.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Data\dat_EHR_LOINC.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing dat_EHRSystemFunction.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Data\dat_EHRSystemFunction.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing dat_EHRSystemTable.sql >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I -i %5\Data\dat_EHRSystemTable.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%" 
	sqlcmd -S %1 -U %2 -P %3 -d %4 -I /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%" 

	ECHO Processing dat_EHRReportParam.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -i %5\Data\dat_EHRReportParam.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

	ECHO Processing dat_EHRCodeTableMaint.sql >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 -i %5\Data\dat_EHRCodeTableMaint.sql /m 10 /t 1200 /a 4096 >> "%TRACEFILE%"
	sqlcmd -S %1 -U %2 -P %3 -d %4 /Q "CHECKPOINT" /m-1 /t 1200 /a 4096 >> "%CHPFILE%"

ECHO.
ECHO.
ECHO Installation Complete.  
ECHO Run p_EHR_InitSeed for each center using eChart

	goto :eof


:cmdLineHelp
ECHO.
ECHO.
ECHO INVALID command line.  
ECHO	%*
ECHO.
ECHO See HELP below.
ECHO.
ECHO exe_initialization.bat serverName dbUser dbPassword dbName srcCodeDir isUpdate centerN centerM
ECHO. 
ECHO where
ECHO 	serverName 
ECHO			name of your virtual host	
ECHO			i.e. MIKE-BASE-2012
ECHO 	dbUser 
ECHO 		user to access db as			
ECHO			i.e. sa
ECHO 	dbPassword 
ECHO			password for dbuser
ECHO			i.e. hst@9asc
ECHO 	dbName
ECHO			name of the database
ECHO			i.e. HSTASC
ECHO 	srcCodeDir
ECHO			EHR project root location of db files
ECHO			i.e. C:\eChart\Development\eChart\Database
ECHO 	isUpdate
ECHO			if 1, then all tables scripts are run.  If 0, then some table scripts are skipped
ECHO 	centerN
ECHO			Integer CenterID of nth center to set up
ECHO			i.e. 1
ECHO 	centerM
ECHO			Integer CenterID of mth center to set up
ECHO			i.e. 2