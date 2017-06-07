IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_QC_GetModuleTemplates') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_QC_GetModuleTemplates;
GO

-- =============================================================================================================
-- Author:			Susan T
-- Create date:		5/9/2016
-- Description:		Get unique (no dups) module templates for the given workflow.
--				  
-- Parameters		chartKey:				key from t_EHR_Chart to get module templates for.
--
--					workflowKey:			workflow key to get module templates for
--
--					CenterID				id of center to get module templates for
--
--					WorkstationTime:		Timestamp taken on user's device, not necessarily trustworthy,
--											so we double-store it for auditing purposes with the server date/time
--
--					UserID:					User ID of responsible user 

-- =============================================================================================================
CREATE PROCEDURE p_EHR_QC_GetModuleTemplates
	@chartKey			INT
	,@workflowKey	    int			
	,@CenterID			INT
	,@workstationTime	DATETIME
	,@userID			VARCHAR(60)
--WITH ENCRYPTION

AS
	
BEGIN
SET NOCOUNT ON;


BEGIN TRY
	SELECT * FROM	dbo.f_EHR_QC_GetModuleTemplates(@workflowKey, @CenterID, @workstationTime, @userID)	ORDER BY ModuleOrder asc			
	RETURN;
END TRY
BEGIN CATCH
		EXEC p_RethrowError;

		RETURN -1;
END CATCH;

END

GO

EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 5/9/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_QC_GetModuleTemplates'
GO