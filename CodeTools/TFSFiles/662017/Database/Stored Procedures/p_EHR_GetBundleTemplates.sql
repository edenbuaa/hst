IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_GetBundleTemplates') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_GetBundleTemplates;
GO
-- =============================================================================================================
-- Author:			Bill Teng
-- Create date:		1/22/16
-- Description:		Get all bundle templates by Center
--				  
-- Parameters		
--					@centerID
-- =============================================================================================================
CREATE PROCEDURE p_EHR_GetBundleTemplates
	@centerID				INT
--WITH ENCRYPTION
AS
BEGIN

	SET NOCOUNT ON;
		
	BEGIN TRY
		
		SELECT	BundleTemplateKey AS BundleKey
				,BundleTemplateDescription AS BundleTemplateName
		FROM 	t_EHR_BundleTemplate
		WHERE 	CenterID = @centerID
		AND		[Status] = 'A'
							
 		RETURN;
	END TRY
	BEGIN CATCH
		EXEC p_RethrowError;

		RETURN -1;
	END CATCH;

END

GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'Rev Date: 1/22/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_GetBundleTemplates'
GO
