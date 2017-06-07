IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_RoomTimeInAutoFillRegistrationEnd') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_LET_RoomTimeInAutoFillRegistrationEnd;
GO

-- =============================================================================================================
-- Create date:		1/12/17
-- Description:		Updates prior Registration End Time (ts124)		
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_RoomTimeInAutoFillRegistrationEnd
	@Action				CHAR(1)
	,@CenterID			INT
	,@ChartKey			INT
	,@WorkflowKey		INT
	,@ModuleKey			INT
	,@BundleKey			INT
	,@UIDictionaryKey	INT
	,@Now				SMALLDATETIME
	,@UserID			VARCHAR(60)
-- WITH ENCRYPTION

AS
	
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

BEGIN TRY
	IF @Action = 'T'
	BEGIN
		SELECT	TableName				
				,Operation
		FROM	(
				VALUES ('t_EHR_RoomTime', 			'U')
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END

	-- query t_EHR_RoomTime to get the In/Out field, and workflow key. we need to know the Area.
	DECLARE 
			@roomTime			SMALLDATETIME
			,@moduleDesignId    CHAR(3)
			,@workflowOrder			INT
			,@registrationEndModuleKey INT
			,@registrationEndTime SMALLDATETIME
			,@registrationEndWorkflowKey INT

	IF @ModuleKey IS NULL
		RAISERROR('Required parameter (ModuleKey) is missing', 16, 1)

	SELECT @roomTime = RoomTime FROM t_EHR_RoomTime WHERE ModuleKey = @ModuleKey

	IF @roomTime IS NULL
		RETURN

	SELECT @moduleDesignId = dbo.f_EHR_GetModuleDesignIDFromRoomTime(@ModuleKey)

	IF @moduleDesignId = '011'
	BEGIN
		SELECT	@workflowOrder = WorkflowOrder
		FROM	t_EHR_Workflow
		WHERE	workflowKey = @WorkflowKey

		SELECT TOP 1 @registrationEndModuleKey = rt.ModuleKey
					,@registrationEndTime = rt.RoomTime
					,@registrationEndWorkflowKey = rt.WorkflowKey
		FROM   t_EHR_RoomTime rt
		JOIN   t_EHR_Module m
		ON     rt.ModuleKey = m.ModuleKey
		AND    rt.ChartKey = @ChartKey
		AND    m.Status = 'A'
		JOIN   t_EHR_ModuleTemplate mt
		ON     mt.ModuleTemplateKey = m.ModuleTemplateKey
		AND    mt.ModuleDesignID = '124'
		JOIN   t_EHR_Workflow wf
		ON     wf.WorkflowKey = rt.WorkflowKey
		AND    wf.WorkflowOrder < @workflowOrder
		ORDER BY wf.WorkflowOrder DESC

		IF @registrationEndModuleKey IS NULL OR @registrationEndTime IS NOT NULL
			RETURN

		UPDATE	t_EHR_RoomTime
		SET		RoomTime = @roomTime
				,ChangeDate = @Now
				,ChangeBy = @UserID
		OUTPUT	'U', deleted.*, inserted.*
		INTO	#t_EHR_RoomTime_Audit
		OUTPUT	inserted.*
		WHERE   ModuleKey = @registrationEndModuleKey	

		INSERT INTO #UpdateLog VALUES (@registrationEndModuleKey, @registrationEndWorkflowKey, 't_EHR_RoomTime', NULL, NULL, 'U')

		--EXEC p_EHR_BackFillVisitRegistrationTime @registrationEndModuleKey, @Now, @UserID
		EXEC p_EHR_BackFillVisitRegistrationTime @CenterID, @ChartKey, @WorkflowKey, @registrationEndModuleKey, @Now, @UserID
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
     ,@value = N'Rev Date: 1/12/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_RoomTimeInAutoFillRegistrationEnd'
GO