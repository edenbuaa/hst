IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_V_Allergy') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_V_Allergy;
GO

-- =============================================================================================================
-- Create date:		5/30/17
-- Description:		validates DischargeStatus BLOC data (CRUD V action)		
--					To validate, run this proc and then check if table #Incomplete has entries for this module	
--					Assumes existence of a #Incomplete table -- this proc for use by CRUD 'V' and LET procs	  
-- =============================================================================================================
CREATE PROCEDURE p_EHR_V_Allergy
	@centerID			INT
	,@chartKey			INT
	,@workflowKey		INT
	,@moduleKey			INT
--WITH ENCRYPTION

AS
	
SET NOCOUNT ON;

BEGIN TRY
		IF  EXISTS
		(	SELECT	1
			FROM	t_EHR_AllergyChart
			WHERE	ChartKey=@chartKey
			AND		Status='A'
			AND		NKA = 1	
		)
			RETURN;		 -- complete, if marked "No Known Allergies"

		IF  NOT EXISTS
		(	SELECT	1
			FROM	t_EHR_AllergyChartDetail
			WHERE	ChartKey=@chartKey
			AND		Status='A'
		)
		BEGIN
			EXEC p_EHR_Incomplete @moduleKey, 't_EHR_AllergyChartDetail', 'Record must either have one listed allergy or be marked as having No Known Allergies';
			RETURN		-- no since warning about review before anything to review exists
		END

		IF  NOT EXISTS
		(	SELECT	1
			FROM	t_EHR_AllergyModule
			WHERE	ChartKey=@chartKey
			AND		ModuleKey=@moduleKey
			AND		Status='A'
			AND		Reviewed = 1
		)
			EXEC p_EHR_Incomplete @moduleKey, 't_EHR_AllergyModule', 'Allergies must be Reviewed';

				
	RETURN
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH;
GO

EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 5/30/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_V_Allergy'
GO
