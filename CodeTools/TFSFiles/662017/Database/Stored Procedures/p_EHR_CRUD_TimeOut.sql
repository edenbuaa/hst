IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_TimeOut') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_TimeOut;
GO

-- =============================================================================================================
-- Author:			Darren Lou
-- Create date:		8/6/15
-- Description:		Creates/Reads/Deactivates data row for the Time Out module
--				  
-- Parameters		action:					'T' -> Return list of tables that this proc returns
--
--											'C' -> Create a new record
--
--											'R' -> Reads the moudle data into result set. This can return more 
--													than one table.
--
--											'D' -> Deactivates specified row
--
--					chartKey:				Chart containing this module
--
--					workflowKey:			Workflow containing this module
--
--					moduleKey:				Reference to the instance of the module
--											 that this data backs
--
--					userID:					User ID of responsible user 
--
--					actionDate:				Date row was touched
-- =============================================================================================================
CREATE PROCEDURE p_EHR_CRUD_TimeOut
	@action				CHAR(1)
	,@centerID			INT
	,@chartKey			INT
	,@workflowKey		INT
	,@moduleKey			INT
	,@userID			VARCHAR(60)
	,@actionDate		SMALLDATETIME
WITH ENCRYPTION

AS
	
SET NOCOUNT ON;

DECLARE		@bundleKey				INT
		    ,@moduleTemplateKey		INT

BEGIN TRY		
	SELECT		@bundleKey	= BundleKey
				,@moduleTemplateKey = ModuleTemplateKey
	FROM		t_EHR_Module 
	WHERE		ModuleKey = @moduleKey

	IF @action = 'T'
		SELECT	*
		FROM(VALUES
			('v_EHR_WorkflowRoomTime',	   NULL, 1)
			,('v_EHR_BundleEventTime',	   NULL, 1)
			,('t_EHR_EventTime',		   NULL, 1)
			,('t_EHR_TimeOut',			   NULL, 1)
			)
		AS	temp (TableName, ResultName, SingleRow)

	-- Create a new row for this module
	ELSE IF @action = 'C'
		BEGIN
			-- Data is module-scoped.
			IF NOT EXISTS	(	SELECT	* 
								FROM	t_EHR_EventTime 
								WHERE	ChartKey		  = @chartKey 
								AND		ModuleKey		  = @moduleKey
								AND		ModuleTemplateKey = @moduleTemplateKey
							)
				INSERT t_EHR_EventTime (ChartKey,ModuleKey,ModuleTemplateKey,CreateBy)
				VALUES				   (@chartKey,@moduleKey,@moduleTemplateKey, @userID)
			IF NOT EXISTS (		SELECT  *
								FROM    t_EHR_TimeOut
								WHERE   ModuleKey = @moduleKey
						  )
				INSERT t_EHR_TimeOut    (ChartKey, ModuleKey, WorkflowKey, CreateBy) 
				VALUES					(@chartKey, @moduleKey, @workflowKey, @userID)
		END
	ELSE IF @action = 'R' OR @action = 'A'
		BEGIN
			-- For a non-grid record, status will be 
			--  'A', even if module is removed, until the chart is closed.  During 
			--  close, status will be set to 'I' if the module was removed from all workflows.
			--  If chart is reopened, then PreCloseStatus will be used to reverse the closing .
			--
			-- When retreiving data from closed charts, Status could be 'I' if module was
			--  removed from chart. but in this case the module's status would be 'I' too,  

			SELECT  * 
			FROM	v_EHR_WorkflowRoomTime
			WHERE	ChartKey  = @chartKey
			AND		WorkflowKey = @workflowKey

			SELECT  * 
			FROM	v_EHR_BundleEventTime
			WHERE	BundleKey  = @bundleKey

			SELECT  * 
			FROM    t_EHR_EventTime
			WHERE   ChartKey = @chartKey
			AND     ModuleKey = @moduleKey
			AND     ModuleTemplateKey = @moduleTemplateKey		--module-scoped

			SELECT  *
			FROM	t_EHR_TimeOut
			WHERE	ChartKey = @chartKey
			AND		ModuleKey = @moduleKey
			AND		((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))

		END

	ELSE IF @action = 'V'
	BEGIN
		DECLARE @EventTime					DATETIME
				,@RoomInTime				SMALLDATETIME
				,@IncisionStartTime			DATETIME
				,@ProcedureStartTime			DATETIME
				,@AllTeamMembersKnown		BIT
				,@ConsentSigned				BIT
				,@PatientConfirmed			BIT
				,@ProcedureConfirmed		BIT
				,@SiteConfirmed				BIT
				,@SideConfirmed				TINYINT
				,@AnesthesiaPlanConfirmed	BIT
				,@ImplantConfirmed			TINYINT

		SELECT  @RoomInTime = RoomTimeIn
		FROM	v_EHR_WorkflowRoomTime
		WHERE	ChartKey  = @chartKey
		AND		WorkflowKey = @workflowKey

		SELECT  @IncisionStartTime = IncisionStartTime
				,@ProcedureStartTime = ProcedureStartTime
		FROM	v_EHR_BundleEventTime
		WHERE	BundleKey  = @bundleKey

		SELECT  @EventTime = EventTime
		FROM    t_EHR_EventTime
		WHERE   ChartKey = @chartKey
		AND     ModuleKey = @moduleKey
		AND     ModuleTemplateKey = @moduleTemplateKey		--module-scoped

		SELECT  @AllTeamMembersKnown = AllTeamMembersKnown
				,@ConsentSigned = ConsentSigned
				,@PatientConfirmed = PatientConfirmed
				,@ProcedureConfirmed = ProcedureConfirmed
				,@SiteConfirmed = SiteConfirmed
				,@SideConfirmed = SideConfirmed
				,@AnesthesiaPlanConfirmed = AnesthesiaPlanConfirmed
				,@ImplantConfirmed = ImplantConfirmed
		FROM	t_EHR_TimeOut
		WHERE	ChartKey = @chartKey
		AND		ModuleKey = @moduleKey
		AND     Status = 'A'

		IF @EventTime IS NULL
			EXEC p_EHR_Missing @moduleKey, 'TimeOutTime'

		IF @EventTime IS NOT NULL
		BEGIN
			IF @EventTime IS NOT NULL AND @RoomInTime IS NOT NULL AND @EventTime < @RoomInTime
				EXEC p_EHR_Incomplete @moduleKey, 'TimeOutTime', 'Time Out Time must be greater than the Room In Time'

			IF @IncisionStartTime IS NOT NULL AND @ProcedureStartTime IS NULL AND @EventTime > @IncisionStartTime
				EXEC p_EHR_Incomplete @moduleKey, 'TimeOutTime', 'Time Out Time must not be later than the Incision Start Time'
			ELSE IF @IncisionStartTime IS NULL AND @ProcedureStartTime IS NOT NULL AND @EventTime > @ProcedureStartTime
				EXEC p_EHR_Incomplete @moduleKey, 'TimeOutTime', 'Time Out Time must not be later than the Procedure Start Time'
			ELSE IF @IncisionStartTime IS NOT NULL AND @ProcedureStartTime IS NOT NULL
			BEGIN
				IF (@IncisionStartTime > @ProcedureStartTime AND @EventTime > @IncisionStartTime) OR (@IncisionStartTime < @ProcedureStartTime AND @EventTime > @ProcedureStartTime)
					EXEC p_EHR_Incomplete @moduleKey, 'TimeOutTime', 'Time Out Time must not be later than the Incision Start Time or Procedure Start Time'
			END
		END
		
		IF @AllTeamMembersKnown = 0
			EXEC p_EHR_Incomplete @moduleKey, 'AllTeamMembersKnown', 'All team members known by name must be checked'

		IF @ConsentSigned = 0
			EXEC p_EHR_Incomplete @moduleKey, 'ConsentSigned', 'Consent signed must be checked'
		
		IF @PatientConfirmed = 0
			EXEC p_EHR_Incomplete @moduleKey, 'PatientConfirmed', 'Patient must be checked'
		
		IF @ProcedureConfirmed = 0
			EXEC p_EHR_Incomplete @moduleKey, 'ProcedureConfirmed', 'Procedure must be checked'

		IF @SiteConfirmed = 0
			EXEC p_EHR_Incomplete @moduleKey, 'SiteConfirmed', 'Site must be checked'

		IF @SideConfirmed IS NULL
			EXEC p_EHR_Incomplete @moduleKey, 'SideConfirmed', 'Side choice must be selected'
		
		IF @AnesthesiaPlanConfirmed = 0
			EXEC p_EHR_Incomplete @moduleKey, 'AnesthesiaPlanConfirmed', 'Anesthesia plan must be checked'
		
		IF @ImplantConfirmed IS NULL
			EXEC p_EHR_Incomplete @moduleKey, 'ImplantConfirmed', 'Implant choice must be selected'



	END

	ELSE IF @action = 'D'
		BEGIN
			UPDATE	t_EHR_EventTime
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			WHERE   ChartKey = @chartKey
			AND     ModuleKey = @moduleKey
			AND     ModuleTemplateKey = @moduleTemplateKey

			UPDATE  t_EHR_TimeOut
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			WHERE   ChartKey = @chartKey
			AND		ModuleKey = @moduleKey
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
     ,@value = N'Rev Date: 8/6/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_TimeOut'
GO
