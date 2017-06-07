IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_BedsideVisit') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_BedsideVisit;
GO

-- =============================================================================================================
-- Author:			Darren Lou
-- Create date:		3/4/16
-- Description:		Creates/Reads/Deactivates data rows for the Prep module
--				  
-- Parameters		Action:					'C' -> Create a new record
--
--											'R' -> Reads the module data into result set. This can return more 
--													than one table.
--
--											'D' -> Deactivates specified row
--
--					ChartKey:				Chart containing this module
--
--					WorkflowKey:			Workflow containing this module
--
--					ModuleKey:				Reference to the instance of the module
--											 that this data backs
--
--					userID:					User ID of responsible user 
--
--					actionDate:				Date action requested
-- =============================================================================================================
CREATE PROCEDURE p_EHR_CRUD_BedsideVisit
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

BEGIN TRY
	IF @action = 'T'
		SELECT	*
		FROM(VALUES

			('t_EHR_BedsideVisitDetail',	NULL, 0)
			)
		AS	temp (TableName, ResultName, SingleRow)

	
	ELSE IF @action = 'R' OR @action = 'A'
	BEGIN		
		SELECT  * 
		FROM	t_EHR_BedsideVisitDetail
		WHERE	ChartKey  = @chartKey
		AND		((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))
	END

	ELSE IF @action = 'V'
	BEGIN
		DECLARE @moduleNA		TINYINT;

		SELECT  @moduleNA = NA
		FROM	t_EHR_Module
		WHERE	moduleKey  = @moduleKey
		AND		Status = 'A'

		IF @moduleNA=0 and NOT EXISTS
		(	SELECT	1
			FROM	t_EHR_BedsideVisitDetail 
			WHERE	ChartKey=@chartKey
			AND		Status='A'
			
		)
		EXEC p_EHR_Incomplete @moduleKey, 't_EHR_BedsideVisitDetail', 'Must select N/A or enter at least one set of data for Bedside Visit.';

		RETURN;
	END	-- Deactivate

	-- Deactivate
	IF @action = 'D'
		UPDATE	t_EHR_BedsideVisitDetail
		SET		Status = 'I'
				,DeactivateDate = @actionDate
				,DeactivateBy = @userID
		WHERE	ChartKey = @chartKey
				
	RETURN
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH;

GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'Rev Date: 11/25/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_BedsideVisit'
GO
