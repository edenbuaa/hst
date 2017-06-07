IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_AnesthesiaStopTimeUpdate') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_LET_AnesthesiaStopTimeUpdate;
GO

-- =============================================================================================================
-- Author:			Andy
-- Create date:		1/11/17
-- Description:		Auto fill anesthesia stop time for ts030				  
-- Edit date:		3/9/17 by Susan
-- Changed:			Fix a bug, should format t_VisitParticipant.EndTime field as '1/1/1900 HH:mm'
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_AnesthesiaStopTimeUpdate
	@ChartKey			INT
	,@WorkflowKey		INT
	,@ModuleKey			INT
	,@anesTimeEnd		SMALLDATETIME
	,@Now				SMALLDATETIME
	,@UserID			VARCHAR(60)
--WITH ENCRYPTION

AS

SET NOCOUNT ON;

BEGIN TRY
		DECLARE @StaffModuleKey INT
		SELECT @StaffModuleKey = ModuleKey FROM t_EHR_Module m JOIN t_EHR_ModuleTemplate mt
		ON m.ModuleTemplateKey = mt.ModuleTemplateKey
		WHERE m.ChartKey = @ChartKey
		AND m.WorkflowKey = @WorkflowKey
		AND mt.ModuleDesignID = '030'

		DECLARE @StaffDetail TABLE(
			ChartKey				INT NOT NULL,
			WorkflowKey				INT NOT NULL,
			StaffDetailKey			INT NOT NULL,
			VisitParticipantKey		INT NULL,
			StaffID					INT NULL,
			EmployeeType			CHAR(8) NULL,
			InTime					SMALLDATETIME NULL,
			OutTime					SMALLDATETIME NULL,
			Duration				INT NULL)

		INSERT INTO @StaffDetail
		SELECT	Chartkey,
				WorkflowKey,
				StaffDetailKey,
				VisitParticipantKey,
				StaffID,
				EmployeeType,
				InTime,
				OutTime,
				Duration 
		FROM	t_EHR_StaffDetail
		WHERE	ChartKey = @ChartKey
		AND		WorkflowKey = @WorkflowKey
		AND		Status IN ('A')
		AND		OutTime IS NULL
		AND		VisitParticipantKey IS NOT NULL

		IF @anesTimeEnd IS NOT NULL
		BEGIN
			UPDATE t_EHR_StaffDetail SET OutTime = @anesTimeEnd, Duration = DATEDIFF(MINUTE, InTime, @anesTimeEnd) OUTPUT 'U', deleted.*, inserted.* INTO #t_EHR_StaffDetail_Audit
			OUTPUT inserted.*
			WHERE ChartKey = @ChartKey AND WorkflowKey = @WorkflowKey AND ModuleKey = @StaffModuleKey AND Status IN ('A') AND OutTime IS NULL

			--to do: Some fields about complete(Complete, CompletionMethod, CompetionDate, CompletedBy) in t_EHR_Module should be updated if auto-filling get ts030 completed
			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'U')

			UPDATE	t_VisitParticipant 
			SET		EndTime = '1/1/1900 ' + CONVERT(CHAR(5),@anesTimeEnd, 108)
					, TimeOnPatient = ISNULL(DATEDIFF(MINUTE, CONVERT(CHAR(5),BeginTime, 108), CONVERT(CHAR(5),@anesTimeEnd, 108)),0)
			FROM	t_VisitParticipant vp INNER JOIN @StaffDetail sd ON vp.VisitParticipantKey = sd.VisitParticipantKey
			WHERE	EndTime IS NULL
		END
	RETURN
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH;
GO

EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 3/9/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_AnesthesiaStopTimeUpdate'
GO