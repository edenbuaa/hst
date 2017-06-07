IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_IntakeAndOutputDetail') AND TYPE in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_IntakeAndOutputDetail;
GO

-- =============================================================================================================
-- Author:			Floare
-- Create date:		11/12/15
-- Description:		Creates/Reads/Deactivates data row for the AnesthesiaPostOpAssessment module
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
CREATE PROCEDURE p_EHR_CRUD_IntakeAndOutputDetail
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

BEGIN TRY
	IF @action = 'V'
	BEGIN
		DECLARE @na BIT
		DECLARE @foundValidRow BIT

		SET @na = dbo.f_EHR_IsModuleNA(@moduleKey)

		IF EXISTS(	SELECT *  
					FROM	t_EHR_IntakeAndOutputDetail
					WHERE	ChartKey = @chartKey
					AND		[Status] = 'A')
			SET		@foundValidRow = 1
		ELSE
			SET		@foundValidRow = 0

		IF ISNULL(@na, 0) = 0 AND @foundValidRow = 0
			EXEC p_EHR_Incomplete @moduleKey, 'v_EHR_IntakeAndOutputDetail', 'Must select N/A or have at least record for Intake and Output'
	END
	IF @action = 'T'
		SELECT	*
		FROM(VALUES
			  ('v_EHR_IntakeAndOutputDetail',NULL, 0)
			 ,('v_EHR_WorkflowArea',         NULL, 1)
			)
		AS	temp (TableName, ResultName, SingleRow)
	--there is no C action for this module.
	--ELSE IF @action = 'C'
		--BEGIN
		--	PRINT('DO NOTHING')
		--END
	ELSE IF @action = 'R' OR @action = 'A'
		BEGIN
			SELECT	*
			FROM	V_EHR_IntakeAndOutputDetail 
			WHERE	ChartKey  = @chartKey
			AND		((@action='R' AND [Status] IN ('A', 'D')) OR (@action='A'))
			ORDER BY IntakeOutputDateTime DESC

			SELECT AreaKey, AreaName,WorkflowKey
			FROM   v_EHR_WorkflowArea
			WHERE  WorkflowKey = @workflowKey
		END
	ELSE IF @action = 'D'
		BEGIN
			-- this data is Chart Scoped.  It is non-grid. The clustered index is on ChartKey + BundleKey + Status.
			--
			-- Because data for this module is not in a grid, there is no UI that will allow someone to deactivate 
			--  the record. So this code will never be used.  But does no harm to leave code here.
			--
			-- If we were to deactivate a record, we could query by the clustered index for maximum efficiency.
			UPDATE	t_EHR_IntakeAndOutputDetail 
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			WHERE	ChartKey = @chartKey 
			AND		Status IN ('A','D')
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
     ,@value = N'Rev Date: 11/12/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_IntakeAndOutputDetail'
GO
