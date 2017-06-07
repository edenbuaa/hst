IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_RptE63006') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_RptE63006

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go
-- =======================================================================
-- Purpose:		  exec p_EHR_RptE63006 NULL,NULL,'2010-10-01','2010-10-01',NULL,null,1,1
-- Description:		
-- Description:		add parameter @invgroup	
-- Description:		removed @fromphysicianid and @tophysicianid parameters
-- Description:		ADD @SortParam parameters and add order by
-- =======================================================================
-- exec p_EHR_RptE63006 1,'5/1/2017','5/1/2017',null,null,NULL,0,NULL
-- exec p_EHR_RptE63006 1,'1/1/2017','6/1/2017',null,null,NULL,0,NULL
-- exec p_EHR_RptE63006 1,'1/01/2016','5/31/2017',61,null,null,0,0,0
-- exec p_EHR_RptE63006 1,'1/1/2016','9/13/2016',null,null,null,0,0,1,0
CREATE PROCEDURE [dbo].p_EHR_RptE63006
	@CenterID	int,
	@FromStartDateTime smalldatetime=null,
	@ToStartDateTime smalldatetime=null,
	@PhysicianID varchar(1000)=NULL,
	@UserID varchar(1000)=null,
	@WorkflowArea varchar(1000) = null,
	@DeIdentify bit = 0,
	@ChartStatus char(1) = null

WITH ENCRYPTION

AS 

DECLARE @DefaultAdministrator Varchar(40)

--SELECT @DefaultAdministrator = (SELECT CASE WHEN COUNT(*) > 1 THEN 'Administrator' ELSE MAX(UserID) END FROM t_UserPermission  WHERE FunctionKey = 60114 AND CenterID = @CenterID GROUP BY FunctionKey)
SELECT @DefaultAdministrator = 'Administrator'
SELECT	@FromStartDateTime = dbo.f_rptFromTimeVariable(@FromStartDateTime),
		@ToStartDateTime = dbo.f_rptTimeVariable(@ToStartDateTime)

BEGIN TRY;

WITH 
		ChartCompletionInfo 
		(
			VisitKey,
			AdmitDate,
			PatientID,
			VisitNumber,
			PatientName,
			ChartKey,
			ChartStatus,
			ChartComplete,
			AreaKey,
			AreaName,
			WorkflowComplete,
			WorkflowPercent,
			AssignedCount,
			AdminCount,
			--UserListCreateBy,
			--WorkflowCreateBy,
			--v_EHR_UserStaffID,
			ResponsibleUserID,
			WorkflowKey,
			RowNo,
			WorkflowResponsibleUser,
			PreOpCom,
			Registration,
			PreOp,
			IntraOp,
			PACU,
			PostOp,
			Anesthesia,
			Physician,
			TwentyThreeHr,
			PostOpCom,
			OpReport,
			LabResults,
			HnP,
			HnPDate
		)
		AS
		(
			SELECT	t_Visit.VisitKey,
			t_Visit.AdmitDate,
			CASE WHEN @DeIdentify = 1 THEN NULL ELSE t_Person.PatientID END AS PatientID ,
			CASE WHEN @DeIdentify = 1 THEN NULL ELSE t_Visit.VisitNumber END AS VisitNumber,
			CASE WHEN @DeIdentify = 1 THEN NULL ELSE t_Person.LastName + ', ' + t_Person.FirstName + ' ' + t_Person.MI END AS PatientName,
			--t_VisitService.ServiceDescription,
			--v_EHR_Physician.PhysicianID,
			--v_EHR_Physician.UserID AS PhysicianUserID,
			--v_EHR_Physician.LastName + ', ' + v_EHR_Physician.FirstName  AS PhysicianName,
			--AnesthesiaProvider.AnesID AS AnesProviderID,
			--AnesthesiaProvider.AnesUserID,		
			t_EHR_Chart.ChartKey,
			t_EHR_Chart.ChartStatus,
			t_EHR_Chart.Complete AS ChartComplete,
			t_EHR_Workflow.AreaKey,
			t_EHR_Area.AreaName AS AreaName,
			t_EHR_Workflow.Complete AS WorkFlowComplete,
			t_EHR_Workflow.CompletionPercent AS WorkflowPercent,
			--CommLog.CreateBy AS CommLogUserID,
			--RoomIn.CreateBy AS RoomInUserID,
			--CASE WHEN t_EHR_Workflow.AreaKey = 8 THEN 'P' ELSE ISNULL(AnesthesiaProvider.AnesIDType,v_EHR_UserStaff.StaffIDType) END AS StaffIDType,
			--ISNULL(AnesthesiaProvider.AnesID,v_EHR_UserStaff.StaffID) AS StaffID,
			--t_EHR_Workflow.CreateBy AS WorkflowCreateBy,
			--UserList.CreateBy AS UserListCreateBy,
			AssignedTask.AssignedCount AS AssignedCount,
			AssignedTask.AdminCount AS AdminCount,
			--AssignedTask.TaskAssignedUser AS TaskAssignedUser,
			--v_EHR_UserStaff.UserID,
			ISNULL(CASE WHEN ISNULL(AssignedTask.AssignedCount,0) > 1 THEN 'Administrator' 
						--WHEN ISNULL(AssignedTask.AdminCount,0) >= 1 THEN 'Administrator' 
						ELSE AssignedTask.TaskAssignedUser END, 
					ISNULL(CASE	WHEN t_EHR_Workflow.Areakey = 5 THEN AnesthesiaProvider.AnesUserID
								WHEN t_EHR_Workflow.Areakey = 8 THEN v_EHR_Physician.UserID
								WHEN t_EHR_Workflow.AreaKey = 12 THEN CommLog.CreateBy
								WHEN t_EHR_Workflow.AreaKey = 13 THEN CommLog.CreateBy
								WHEN t_EHR_Workflow.AreaKey IN (3,4,6,7,11) THEN v_EHR_UserStaff.UserID ELSE '' END,@DefaultAdministrator)) AS ResponsibleUserID,  -- this is the one to use on the report
			t_EHR_Workflow.WorkflowKey,
			ROWNo		=	ROW_NUMBER() OVER(PARTITION BY t_EHR_Workflow.WorkFlowKey ORDER BY t_EHR_Workflow.WorkFlowKey ASC),
			ISNULL(CASE	WHEN t_EHR_Workflow.Areakey = 5 THEN AnesthesiaProvider.AnesUserID
					WHEN t_EHR_Workflow.Areakey = 8 THEN v_EHR_Physician.UserID
					WHEN t_EHR_Workflow.AreaKey = 12 THEN CommLog.CreateBy
					WHEN t_EHR_Workflow.AreaKey = 13 THEN CommLog.CreateBy
					WHEN t_EHR_Workflow.AreaKey IN (3,4,6,7,11) THEN v_EHR_UserStaff.UserID ELSE '' END,CASE WHEN ISNULL(AssignedTask.AssignedCount,0) > 1 THEN 'Administrator' 
					ELSE ISNULL(AssignedTask.TaskAssignedUser,@DefaultAdministrator) END) AS WorkflowResponsibleUser,
		
			CASE	WHEN t_EHR_Workflow.AreaKey = 12 THEN 
					CASE	WHEN t_EHR_Workflow.Complete = 1 THEN '100%'
							WHEN t_EHR_Workflow.CompletionPercent = 0 THEN '0% - none'
							WHEN t_EHR_Workflow.Complete = 0 THEN Convert(varchar(3),t_EHR_Workflow.CompletionPercent) + '% - ' + 
								ISNULL(CASE WHEN ISNULL(AssignedTask.AssignedCount,0) > 1 THEN 'Administrator' 
											--WHEN ISNULL(AssignedTask.AdminCount,0) >= 1 THEN 'Administrator' 
											ELSE AssignedTask.TaskAssignedUser END, 
									ISNULL(CommLog.CreateBy,@DefaultAdministrator))
											END
					ELSE '' END AS PreOpCom,
			CASE	WHEN t_EHR_Workflow.AreaKey = 11 THEN 
					CASE	WHEN t_EHR_Workflow.Complete = 1 THEN '100%'
							WHEN t_EHR_Workflow.CompletionPercent = 0 THEN '0% - none'
							WHEN t_EHR_Workflow.Complete = 0 THEN Convert(varchar(3),t_EHR_Workflow.CompletionPercent) + '% - ' + 
								ISNULL(CASE WHEN ISNULL(AssignedTask.AssignedCount,0) > 1 THEN 'Administrator' 
											--WHEN ISNULL(AssignedTask.AdminCount,0) >= 1 THEN 'Administrator' 
											ELSE AssignedTask.TaskAssignedUser END, 
									ISNULL(v_EHR_UserStaff.UserID,@DefaultAdministrator))
											END
					ELSE '' END AS Registration,
			CASE	WHEN t_EHR_Workflow.AreaKey = 3 THEN 
					CASE	WHEN t_EHR_Workflow.Complete = 1 THEN '100%'
							WHEN t_EHR_Workflow.CompletionPercent = 0 THEN '0% - none'
							WHEN t_EHR_Workflow.Complete = 0 THEN Convert(varchar(3),t_EHR_Workflow.CompletionPercent) + '% - ' + 
								ISNULL(CASE WHEN ISNULL(AssignedTask.AssignedCount,0) > 1 THEN 'Administrator' 
											--WHEN ISNULL(AssignedTask.AdminCount,0) >= 1 THEN 'Administrator' 
											ELSE AssignedTask.TaskAssignedUser END, 
									ISNULL(v_EHR_UserStaff.UserID,@DefaultAdministrator))
											END
					ELSE '' END AS PreOp,
			CASE	WHEN t_EHR_Workflow.AreaKey = 4 THEN 
					CASE	WHEN t_EHR_Workflow.Complete = 1 THEN '100%'
							WHEN t_EHR_Workflow.CompletionPercent = 0 THEN '0% - none'
							WHEN t_EHR_Workflow.Complete = 0 THEN Convert(varchar(3),t_EHR_Workflow.CompletionPercent) + '% - ' + 
								ISNULL(CASE WHEN ISNULL(AssignedTask.AssignedCount,0) > 1 THEN 'Administrator' 
											--WHEN ISNULL(AssignedTask.AdminCount,0) >= 1 THEN 'Administrator' 
											ELSE AssignedTask.TaskAssignedUser END, 
									ISNULL(v_EHR_UserStaff.UserID,@DefaultAdministrator))
											END
					ELSE '' END AS IntraOp,
			CASE	WHEN t_EHR_Workflow.AreaKey = 6 THEN 
					CASE	WHEN t_EHR_Workflow.Complete = 1 THEN '100%'
							WHEN t_EHR_Workflow.CompletionPercent = 0 THEN '0% - none'
							WHEN t_EHR_Workflow.Complete = 0 THEN Convert(varchar(3),t_EHR_Workflow.CompletionPercent) + '% - ' + 
								ISNULL(CASE WHEN ISNULL(AssignedTask.AssignedCount,0) > 1 THEN 'Administrator' 
											--WHEN ISNULL(AssignedTask.AdminCount,0) >= 1 THEN 'Administrator' 
											ELSE AssignedTask.TaskAssignedUser END, 
									ISNULL(v_EHR_UserStaff.UserID,@DefaultAdministrator))
											END
					ELSE '' END AS PACU,
			CASE	WHEN t_EHR_Workflow.AreaKey = 7 THEN 
					CASE	WHEN t_EHR_Workflow.Complete = 1 THEN '100%'
							WHEN t_EHR_Workflow.CompletionPercent = 0 THEN '0% - none'
							WHEN t_EHR_Workflow.Complete = 0 THEN Convert(varchar(3),t_EHR_Workflow.CompletionPercent) + '% - ' + 
								ISNULL(CASE WHEN ISNULL(AssignedTask.AssignedCount,0) > 1 THEN 'Administrator' 
											--WHEN ISNULL(AssignedTask.AdminCount,0) >= 1 THEN 'Administrator' 
											ELSE AssignedTask.TaskAssignedUser END, 
									ISNULL(v_EHR_UserStaff.UserID,@DefaultAdministrator))
											END
					ELSE '' END AS PostOp,
			CASE	WHEN t_EHR_Workflow.AreaKey = 5 THEN 
					CASE	WHEN t_EHR_Workflow.Complete = 1 THEN '100%'
							WHEN t_EHR_Workflow.CompletionPercent = 0 THEN '0% - none'
							WHEN t_EHR_Workflow.Complete = 0 THEN Convert(varchar(3),t_EHR_Workflow.CompletionPercent) + '% - ' + 
								ISNULL(CASE WHEN ISNULL(AssignedTask.AssignedCount,0) > 1 THEN 'Administrator' 
											--WHEN ISNULL(AssignedTask.AdminCount,0) >= 1 THEN 'Administrator' 
											ELSE AssignedTask.TaskAssignedUser END, 
									ISNULL(AnesthesiaProvider.AnesUserID,@DefaultAdministrator))
											END
					ELSE '' END AS Anesthesia,
			CASE	WHEN t_EHR_Workflow.AreaKey = 8 THEN 
					CASE	WHEN t_EHR_Workflow.Complete = 1 THEN '100%'
							WHEN t_EHR_Workflow.CompletionPercent = 0 THEN '0% - none'
							WHEN t_EHR_Workflow.Complete = 0 THEN Convert(varchar(3),t_EHR_Workflow.CompletionPercent) + '% - ' + 
								ISNULL(CASE WHEN ISNULL(AssignedTask.AssignedCount,0) > 1 THEN 'Administrator' 
											--WHEN ISNULL(AssignedTask.AdminCount,0) >= 1 THEN 'Administrator' 
											ELSE AssignedTask.TaskAssignedUser END, 
									ISNULL(v_EHR_Physician.UserID,@DefaultAdministrator))
											END
					ELSE '' END AS Physician,
			CASE	WHEN t_EHR_Workflow.AreaKey = 9 THEN 
					CASE	WHEN t_EHR_Workflow.Complete = 1 THEN '100%'
							WHEN t_EHR_Workflow.CompletionPercent = 0 THEN '0% - none'
							WHEN t_EHR_Workflow.Complete = 0 THEN Convert(varchar(3),t_EHR_Workflow.CompletionPercent) + '% - ' + 
								ISNULL(CASE WHEN ISNULL(AssignedTask.AssignedCount,0) > 1 THEN 'Administrator' 
											--WHEN ISNULL(AssignedTask.AdminCount,0) >= 1 THEN 'Administrator' 
											ELSE AssignedTask.TaskAssignedUser END, 
									ISNULL(v_EHR_UserStaff.UserID,@DefaultAdministrator))
											END
					ELSE '' END AS TwentyThreeHr,
			CASE	WHEN t_EHR_Workflow.AreaKey = 13 THEN 
					CASE	WHEN t_EHR_Workflow.Complete = 1 THEN '100%'
							WHEN t_EHR_Workflow.CompletionPercent = 0 THEN '0% - none'
							WHEN t_EHR_Workflow.Complete = 0 THEN Convert(varchar(3),t_EHR_Workflow.CompletionPercent) + '% - ' + 
								ISNULL(CASE WHEN ISNULL(AssignedTask.AssignedCount,0) > 1 THEN 'Administrator' 
											--WHEN ISNULL(AssignedTask.AdminCount,0) >= 1 THEN 'Administrator' 
											ELSE AssignedTask.TaskAssignedUser END, 
									ISNULL(CommLog.CreateBy,@DefaultAdministrator))
											END
					ELSE '' END AS PostOpcom,
			CASE	WHEN t_PatientDocument.PatientDocKey IS NULL THEN 'None'
					WHEN t_EHR_OperativeReportDocumentDetail.PatientDocKey IS NULL THEN 'Report Pending'
					WHEN t_EHR_OperativeReportDocumentDetail.Signed = 0 THEN 'Signature Pending'
					WHEN t_EHR_OperativeReportDocumentDetail.Signed = 1 THEN 'Complete' END,
					--ELSE 'Need more info' END,
			CASE	WHEN LabResults.ChartKey IS NULL THEN 'N/A'
					WHEN LabResults.ResultChartKey IS NULL THEN 'Complete' -- there is not an entry in t_EHR_LabPathMissingResultDetail
					--WHEN t_EHR_LabPathDocument.MissingResults = 0 THEN ''
					ELSE 'Missing Results' END,
			CASE	WHEN HnPDoc.PatientDocKey IS NULL THEN 'No'
					ELSE 'Yes' END,
			HnPDoc.DocumentDate AS HnPDate
					
	FROM	t_Visit
	JOIN	t_Person
	ON		t_Person.PersonKey = t_Visit.PersonKey
	JOIN	t_VisitService
	ON		t_VisitService.VisitKey = t_Visit.VisitKey
	AND		t_VisitService.centerID = @CenterID 
	AND		t_VisitService.PrimaryProcedure = 1
	JOIN	t_VisitPhysician
	ON		t_VisitPhysician.VisitServiceKey = t_VisitService.VisitServiceKey
	AND		t_VisitPhysician.PhysicianRole = 1
	JOIN	v_EHR_Physician
	ON		v_EHR_Physician.PhysicianID = t_VisitPhysician.PhysicianID
	AND		v_EHR_Physician.CenterID = @CenterID

	JOIN	t_EHR_Chart
	ON		t_EHR_Chart.VisitKey = t_Visit.VisitKey
	AND		t_EHR_Chart.Status = 'A'

	JOIN	t_EHR_Workflow
	ON		t_EHR_Workflow.ChartKey = t_EHR_Chart.ChartKey
	AND		t_EHR_Workflow.Status = 'A'
	AND		t_EHR_Workflow.AreaKey IN (3,4,5,6,7,8,11,12,13)

	LEFT JOIN	t_EHR_RoomTime RoomIn
	ON			RoomIn.WorkflowKey = t_EHR_Workflow.WorkflowKey
	AND			RoomIn.Status = 'A'
	AND			RoomIn.InOut = 'IN'
	AND			RoomIn.StaffID IS NOT NULL
	AND			RoomIn.CreateDate = (SELECT MAX(CreateDate) FROM t_EHR_RoomTime a
														WHERE a.WorkflowKey = RoomIn.WorkflowKey
														AND	a.InOut = 'IN'
														AND a.Status = 'A')

	LEFT JOIN (SELECT t_EHR_Task.WorkflowKey,COUNT(t_EHR_TaskAssignment.TaskKey) AS AssignedCount, MAX(t_EHR_TaskAssignment.UserID) AS TaskAssignedUser, COUNT(t_UserPermission.UserID) AS AdminCount
				FROM		t_EHR_Task
				LEFT JOIN	t_EHR_TaskAssignment
				ON			t_EHR_TaskAssignment.TaskKey = t_EHR_Task.TaskKey
				AND			t_EHR_TaskAssignment.Status = 'A'
				AND			t_EHR_TaskAssignment.CreateDate = (SELECT MAX(CreateDate) FROM t_EHR_TaskAssignment a
																WHERE a.TaskKey = t_EHR_TaskAssignment.TaskKey
																AND	  a.Status = 'A')
				LEFT JOIN	t_UserPermission
				ON			t_UserPermission.UserID = t_EHR_TaskAssignment.UserID
				AND			t_UserPermission.FunctionKey = 60114
				AND			t_UserPermission.CenterID = @CenterID
				WHERE t_EHR_Task.Status = 'A'
				GROUP BY t_EHR_Task.WorkflowKey
				)AssignedTask
	ON		AssignedTask.WorkflowKey = t_EHR_Workflow.WorkflowKey

	JOIN	t_EHR_Area
	ON		t_EHR_Area.AreaKey = t_EHR_Workflow.AreaKey

	LEFT JOIN (SELECT ChartKey, InitialAnesthesiaProviderName AS AnesName,
								InitialAnesthesiaProviderID AS AnesID,
								InitialAnesthesiaProviderIDType AS AnesIDType,v_EHR_Physician.UserID AS AnesUserID

				FROM t_EHR_Anesthesia
				JOIN	v_EHR_Physician
				ON		v_EHR_Physician.PhysicianID = InitialAnesthesiaProviderID
				AND	v_EHR_Physician.CenterID = @CenterID
				WHERE t_EHR_Anesthesia.Status = 'A') AnesthesiaProvider
	ON		AnesthesiaProvider.ChartKey = t_EHR_Chart.ChartKey
	AND		t_EHR_Workflow.AreaKey = 5

	LEFT JOIN (SELECT	t_EHR_CommunicationLog.WorkflowKey, t_EHR_CommunicationLog.CreateBy 
				FROM	t_EHR_CommunicationLog
				JOIN	v_EHR_UserStaff
				ON		v_EHR_UserStaff.UserID = t_EHR_CommunicationLog.CreateBy
				AND		v_EHR_UserStaff.StaffIDType <> 'P'
				AND		v_EHR_UserStaff.CenterID = @CenterID
				WHERE	t_EHR_CommunicationLog.Status = 'A'
				AND		t_EHR_CommunicationLog.CreateDate = (	SELECT MAX(CreateDate) 
																FROM t_EHR_CommunicationLog a
																JOIN	v_EHR_UserStaff
																ON		v_EHR_UserStaff.UserID = t_EHR_CommunicationLog.CreateBy
																AND		v_EHR_UserStaff.StaffIDType <> 'P'
																AND		v_EHR_UserStaff.CenterID = @CenterID
																WHERE a.WorkflowKey = t_EHR_CommunicationLog.WorkflowKey
																AND a.Status = 'A')
				)CommLog
	ON			CommLog.WorkflowKey = t_EHR_Workflow.WorkflowKey

	LEFT JOIN	v_EHR_UserStaff
	ON			v_EHR_UserStaff.StaffID = RoomIn.StaffID
	AND			v_EHR_UserStaff.StaffIDType = RoomIn.StaffIDType
	AND			v_EHR_UserStaff.CenterID = @CenterID

	/*
	LEFT JOIN (SELECT	t_EHR_AuditLog.AuditLogKey AS AuditLogKey,
						t_EHR_AuditLog.CreateBy AS CreateBy, 
						v_EHR_UserStaff.StaffIDType AS StaffIDType, 
						v_EHR_UserStaff.StaffID AS StaffID,
						t_EHR_AuditLog.ChartKey, 
						t_EHR_Workflow.WorkflowKey 
						--,coalesce(NULLIF(RTRIM(v_EHR_UserStaff.StaffName),''), NULLIF(RTRIM(dbo.f_EHR_GetFullName(t_UserProfile.FirstName, null, t_UserProfile.LastName)),'') , t_EHR_AuditLog.createby) AS UserName
				FROM	t_EHR_AuditLog 
				JOIN	t_EHR_Chart 
				ON		t_EHR_Chart.ChartKey = t_EHR_AuditLog.ChartKey
				JOIN	t_Visit
				ON		t_Visit.VisitKey = t_EHR_Chart.VisitKey
				JOIN	t_EHR_Workflow 
				ON      t_EHR_Workflow.WorkflowKey = t_EHR_AuditLog.WorkflowKey
				AND		t_EHR_Workflow.AreaKey = 11 -- Registration
				LEFT JOIN	t_UserProfile 
				ON			t_UserProfile.UserID = t_EHR_AuditLog.CreateBy
				LEFT JOIN v_EHR_UserStaff 
				ON        v_EHR_UserStaff.UserID = t_EHR_AuditLog.createby
				AND		  v_EHR_UserStaff.CenterID = t_EHR_AuditLog.CenterID
				WHERE	--dbo.f_EHR_NormalizeDate(t_EHR_AuditLog.CreateDate) = dbo.f_EHR_NormalizeDate(t_Visit.AdmitDate)
						t_EHR_AuditLog.Action = 'R'
				AND		t_EHR_AuditLog.CreateDate = (SELECT MAX(CreateDate) FROM t_EHR_AuditLog a
														WHERE	a.WorkflowKey = t_EHR_AuditLog.WorkflowKey
														AND		a.Action = 'R')
				) UserList
	ON	UserList.WorkFlowKey = t_EHR_Workflow.WorkflowKey
	*/

	LEFT JOIN	t_PatientDocument
	ON			t_PatientDocument.VisitKey = t_Visit.VisitKey
	AND			t_PatientDocument.DocumentType = 'Op Report'

	LEFT JOIN	t_EHR_OperativeReportDocumentDetail
	ON			t_EHR_OperativeReportDocumentDetail.PatientDocKey = t_PatientDocument.PatientDocKey

	LEFT JOIN	(	SELECT t_EHR_Specimen.ChartKey, MIN(t_EHR_LabPathMissingResultDetail.ChartKey) AS ResultChartKey
					FROM	t_EHR_Specimen
					LEFT JOIN	t_EHR_LabPathMissingResultDetail
					ON		t_EHR_LabPathMissingResultDetail.ChartKey = t_EHR_Specimen.ChartKey
					GROUP BY t_EHR_Specimen.ChartKey
				) LabResults
	ON			LabResults.ChartKey = t_EHR_Chart.ChartKey
	LEFT JOIN	(SELECT VisitKey, PatientDocKey,DocumentDate
					FROM	(	SELECT t_PatientDocument.VisitKey,t_PatientDocument.PatientDocKey,t_PatientDocument.DocumentDate,
										ROWNo	=	ROW_NUMBER() OVER(PARTITION BY t_PatientDocument.VisitKey ORDER BY DocumentDate, CreateDate DESC)
								FROM	t_PatientDocument
								WHERE	DocumentType = 'H&P'
								AND		CenterId = @CenterID
								) HnPInfo
					WHERE HnPInfo.RowNo = 1
				)HnPDoc
	ON	HnPDoc.VisitKey = t_Visit.VisitKey

	/*
	LEFT JOIN	t_EHR_Specimen
	ON			t_EHR_Specimen.ChartKey = t_EHR_Chart.ChartKey 
	AND			t_EHR_Specimen.ModuleKey = (SELECT MAX(ModuleKey) 
											FROM t_EHR_Specimen a
											WHERE a.ChartKey = t_EHR_Specimen.ChartKey)

	LEFT JOIN	t_EHR_LabPathDocument
	ON			t_EHR_LabPathDocument.ChartKey = t_EHR_Chart.ChartKey 
	*/
	WHERE 	t_Visit.AdmitDate >= @FromStartDateTime 
			AND t_Visit.AdmitDate <= @ToStartDateTime	
			AND	t_Visit.CenterID=@CenterID 	
			AND	1 = CASE WHEN @ChartStatus IS NULL THEN 1
						WHEN t_EHR_Chart.ChartStatus = @ChartStatus THEN 1 --closed
						WHEN @ChartStatus= '1' AND t_EHR_Chart.Complete = 1 THEN 1 
						WHEN @ChartStatus= '0' AND t_EHR_Chart.Complete = 0 THEN 1 ELSE 0 END 
			AND 1= CASE WHEN @PhysicianID IS NULL THEN 1 
						WHEN t_VisitPhysician.PhysicianID IN (SELECT Param FROM dbo.f_ReturnParamTable(@PhysicianID,',',''))  THEN 1 ELSE 0 END
			AND 1= CASE WHEN @WorkflowArea IS NULL THEN 1 WHEN t_EHR_Workflow.AreaKey IN (SELECT Param FROM dbo.f_ReturnParamTable(@WorkflowArea,',','')) THEN 1 ELSE 0 END
			--AND t_EHR_Chart.ChartKey = 5019
						    
			--ORDER BY t_EHR_Workflow.WorkflowKey, t_EHR_CommunicationLog.CreateBy
			)
--SELECT * FROM ChartCompletionInfo
SELECT	ChartKey,
		RowNo,
		MAX(AdmitDate) AS AdmitDate,
		MAX(PatientID) AS PatientID,
		MAX(VisitNumber) AS VisitNumber,
		MAX(PatientName) AS PatientName,
		MAX(ChartStatus) AS ChartStatus,
		MAX(CASE WHEN ChartComplete = 1 THEN 1 ELSE 0 END) AS ChartComplete,
		--MAX(AreaKey) AS AreaKey,
		--MAX(AreaName) AS AreaName,
		--MAX(CASE WHEN WorkflowComplete = 1 THEN 1 ELSE 0 END) AS WorkFlowComplete,
		--MAX(WorkflowPercent) AS WorkflowPercent,
		--MAX(WorkflowResponsibleUser) AS WorkflowResponsibleUser,
		CASE WHEN MAX(PreopCom) = '' THEN 'N/A' ELSE MAX(PreopCom) END AS PreOpCom,
		CASE WHEN MAX(Registration) = '' THEN 'N/A' ELSE MAX(Registration) END AS Registration,
		CASE WHEN MAX(PreOp) = '' THEN 'N/A' ELSE MAX(PreOp) END AS PreOp,
		CASE WHEN MAX(IntraOp) = '' THEN 'N/A' ELSE MAX(IntraOp) END AS IntraOp,
		CASE WHEN MAX(PACU) = '' THEN 'N/A' ELSE MAX(PACU) END AS PACU,
		CASE WHEN MAX(PostOp) = '' THEN 'N/A' ELSE MAX(PostOp) END AS PostOp,
		CASE WHEN MAX(Anesthesia) = '' THEN 'N/A' ELSE MAX(Anesthesia) END AS Anesthesia,
		CASE WHEN MAX(Physician) = '' THEN 'N/A' ELSE MAX(Physician) END AS Physician,
		CASE WHEN MAX(TwentyThreeHr) = '' THEN 'N/A' ELSE MAX(TwentyThreeHr) END AS TwentyThreeHr,
		CASE WHEN MAX(PostOpCom) = '' THEN 'N/A' ELSE MAX(PostOpCom) END AS PostOpCom,
		MAX(OpReport) AS OpReport,
		MAX(LabResults) AS LabResults,
		MAX(HnP) AS HnP,
		MAX(HnPDate) AS HnPDate
		
FROM ChartCompletionInfo
WHERE 1= CASE WHEN @UserID IS NULL THEN 1 WHEN ResponsibleUserID IN (SELECT Param FROM dbo.f_ReturnParamTable(@UserID,',','')) THEN 1 ELSE 0 END
GROUP BY ChartKey, RowNo
ORDER BY dbo.f_EHR_NormalizeDate(MAX(AdmitDate)),MAX(PatientName)

END TRY
BEGIN CATCH
	EXEC p_RethrowError;
	--DROP TABLE @TranTemp
	RETURN -1;
END CATCH;
GO

GO
EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Date: 5/22/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_RptE63006'
GO


/*
 
SELECT * FROM t_EHR_ModuleTemplate WHERE CenterID = 1 ORDER By ModuleTemplateName

SELECT * FROM t_EHR_Module WHERE ChartKey = 5021 AND ModuleTemplateKey = 251

SELECT * FROM t_EHR_Workflow WHERE WorkflowKey = 31193

SELECT * FROM t_EHR_RoomTime WHERE WorkflowKey in (SELECT WorkflowKey FROM t_EHR_Workflow WHERE AreaKey = 9)


exec p_EHR_RptE63006 1,'4/12/2017','4/30/2017',null,null,NULL,0,NULL

SELECT * FROM t_EHR_CommunicationLog WHERE ChartKey = 5021

SELECT * FROM v_EHR_UserStaff

SELECT * FROM t_EHR_Task WHERE ChartKey = 5021 AND Status = 'A'
SELECT * FROM t_EHR_TaskAssignment WHERE TaskKey IN (SELECT TaskKey FROM t_EHR_Task WHERE ChartKey = 5021 AND Status = 'A') ORDER BY TaskKey


 
SELECT * FROM t_EHR_ModuleTemplate WHERE CenterID = 1 ORDER By ModuleTemplateName

SELECT * FROM t_EHR_Module WHERE ChartKey = 5021 AND ModuleTemplateKey = 251

SELECT * FROM t_EHR_Workflow WHERE WorkflowKey = 31176

SELECT * FROM t_EHR_RoomTime WHERE WorkflowKey in (SELECT WorkflowKey FROM t_EHR_Workflow WHERE AreaKey = 9)


exec p_EHR_RptE63006 1,'4/12/2017','4/30/2017',null,null,NULL,0,NULL

SELECT * FROM t_EHR_CommunicationLog WHERE ChartKey = 5021

SELECT * FROM v_EHR_UserStaff

SELECT * FROM t_EHR_Task WHERE ChartKey = 5019 AND Status = 'A'
SELECT * FROM t_EHR_TaskAssignment WHERE TaskKey = 1431
SELECT * FROM t_EHR_TaskAssignment WHERE TaskKey IN (SELECT TaskKey FROM t_EHR_Task WHERE ChartKey = 5019 AND Status = 'A') ORDER BY TaskKey
*/