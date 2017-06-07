IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_Traction') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_Traction;
GO

-- =============================================================================================================
-- Author:			Andy Jia
-- Create date:		8/29/16
-- Description:		Creates/Reads/Deactivates data row for the Traction module
--				  
-- Parameters		Action:					'C' -> Create a new record
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
--					actionDate:				Date action was requested
-- =============================================================================================================
CREATE PROCEDURE p_EHR_CRUD_Traction
	 @action			CHAR(1)
	,@centerID			INT
	,@chartKey			INT
	,@workflowKey		INT
	,@moduleKey			INT
	,@userID			VARCHAR(60)
	,@actionDate		SMALLDATETIME
WITH ENCRYPTION

AS
	
SET NOCOUNT ON;
DECLARE @paddingAppliedPerPolicy BIT

BEGIN TRY
	IF @action = 'T'
		SELECT	*
		FROM(VALUES
			('t_EHR_Traction',					NULL, 1)
			,('t_EHR_TractionDetail',			NULL, 0)
			)
		AS	temp (TableName, ResultName, SingleRow);

	ELSE IF @action = 'R' OR @action = 'A'
	BEGIN
		SELECT	*
		FROM	t_EHR_Traction
		WHERE	ChartKey  = @chartKey
		AND		((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))
		AND     ModuleKey = @moduleKey

		SELECT	*
		FROM	t_EHR_TractionDetail
		WHERE	((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))
		AND		ChartKey  = @chartKey
		AND		ModuleKey = @moduleKey
	END
	-- Create a new row for this module
	ELSE IF @action = 'C'
	BEGIN
		-- yes, Module scoped, so always create
		INSERT t_EHR_Traction (ChartKey, WorkflowKey, ModuleKey, CreateBy)
		VALUES (@chartKey, @workflowKey, @moduleKey, @userID)
	END
	ELSE IF @action = 'D'
	BEGIN
	-- should never be called - only chart closing proc will set to I, if module was removed from chart.
	-- module scoped, so let's use clustered index for table
		UPDATE	t_EHR_Traction
		SET		Status = 'I'
				,DeactivateDate = @actionDate
				,DeactivateBy = @userID
		WHERE	ChartKey  = @chartKey
		AND		Status IN ('A', 'D')
		AND     ModuleKey = @moduleKey

		UPDATE	t_EHR_TractionDetail
		SET		Status = 'I'
				,DeactivateDate = @actionDate
				,DeactivateBy = @userID
		WHERE	ChartKey  = @chartKey
		AND		Status IN ('A', 'D')
		AND     ModuleKey = @moduleKey
	END
	ELSE IF @action = 'V'
	BEGIN
		IF  dbo.f_EHR_IsModuleNA(@moduleKey) = 1
			RETURN
		
		SELECT	@paddingAppliedPerPolicy = PaddingAppliedPerPolicy
		FROM	t_EHR_Traction
		WHERE	ChartKey  = @chartKey
		AND		[Status] = 'A'
		AND     ModuleKey = @moduleKey

		IF @paddingAppliedPerPolicy = 0
			EXEC p_EHR_Incomplete @moduleKey, 'PaddingAppliedPerPolicy', '"Padding applied per policy and all pressure points examined pre and post traction" must be checked'

		IF NOT EXISTS(	SELECT	*
						FROM	t_EHR_TractionDetail
						WHERE	[Status] = 'A'
						AND		ChartKey  = @chartKey
						AND		ModuleKey = @moduleKey)
			EXEC p_EHR_Incomplete @moduleKey, 't_EHR_TractionDetail', 'Record must contain at least one set of traction detail'

		-- It's better logic?
		--IF EXISTS(SELECT	* 
		--		FROM	t_EHR_TractionDetail
		--		WHERE	ChartKey  = @chartKey
		--		AND		[Status] = 'A'
		--		AND     ModuleKey = @moduleKey
		--		AND		EndTime IS NULL)
		--	EXEC p_EHR_Incomplete @moduleKey, 'EndTime', 'End Time is required'

		--IF EXISTS(SELECT	* 
		--		FROM	t_EHR_TractionDetail
		--		WHERE	ChartKey  = @chartKey
		--		AND		[Status] = 'A'
		--		AND     ModuleKey = @moduleKey
		--		AND		PostTractionNeurovascularStatus IS NULL)
		--	EXEC p_EHR_Incomplete @moduleKey, 'PostTractionNeurovascularStatus', 'Post-traction Neurovascular Status is required'

		-- Do we need the following logic?  
		
		DECLARE @endTime DateTime, @postTractionNeurovascularStatus TINYINT
		DECLARE grid_cursor CURSOR  
			FOR SELECT	EndTime,  PostTractionNeurovascularStatus 
				FROM	t_EHR_TractionDetail
				WHERE	ChartKey  = @chartKey
				AND		[Status] = 'A'
				AND     ModuleKey = @moduleKey
				AND		(EndTime IS NULL OR PostTractionNeurovascularStatus IS NULL)
		OPEN grid_cursor  
		FETCH NEXT FROM grid_cursor INTO  @endTime, @postTractionNeurovascularStatus

		WHILE @@FETCH_STATUS = 0  
		BEGIN
			IF @endTime IS NULL
				EXEC p_EHR_Incomplete @moduleKey, 'EndTime', 'End Time is required'
				
			IF @postTractionNeurovascularStatus IS NULL
				EXEC p_EHR_Incomplete @moduleKey, 'PostTractionNeurovascularStatus', 'Post-traction Neurovascular Status is required'

			FETCH NEXT FROM grid_cursor INTO  @endTime, @postTractionNeurovascularStatus
		END

		CLOSE grid_cursor  
		DEALLOCATE grid_cursor 
              
	END

	RETURN;
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH;

GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'Rev Date: 8/29/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_Traction'
GO