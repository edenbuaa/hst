IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_QC_Specimens') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_QC_Specimens;
GO

-- =============================================================================================================
-- Author:			Andy Jia
-- Create date:		10/31/2016
-- Description:		create or apply the quick chart by Specimens model
--				  
-- Parameters		chartKey:				key from t_EHR_Chart to get module templates for.
--
--					workflowKey:			workflow key to get module templates for
--
--					CenterID				id of center to get module templates for
--
--					QuickChartKey			the quickchartkey from quickchartmaster when 'C' action; the quickchartkey will be used to apply when 'A' action
--
--					WorkstationTime:		Timestamp taken on user's device, not necessarily trustworthy,
--											so we double-store it for auditing purposes with the server date/time
--
--					UserID:					User ID of responsible user 

-- =============================================================================================================
CREATE PROCEDURE p_EHR_QC_Specimens
	 @action			VARCHAR(1)
	,@chartKey			INT
	,@workflowKey	    INT			
	,@centerID			INT
	,@moduleKey			INT
	,@quickChartKey		INT			--used by 'C' or 'A'	
	,@now				DATETIME
	,@userID			VARCHAR(60)
--WITH ENCRYPTION

AS
	
BEGIN
SET NOCOUNT ON;

DECLARE @ModuleTemplateKey int
DECLARE @BundleKey int
DECLARE @AuditLogSequence BIGINT

SELECT	@BundleKey = BundleKey 
FROM	t_EHR_Workflow 
WHERE	ChartKey = @chartKey 
AND		WorkflowKey = @workflowKey

SELECT @ModuleTemplateKey = ModuleTemplateKey 
FROM	t_EHR_Module
WHERE	ModuleKey = @moduleKey

BEGIN TRY
IF @action = 'C'
BEGIN
	
	--fill data to qc from the current valid data
	INSERT INTO t_EHR_QC_Module(QuickChartKey, ModuleKey ,ModuleTemplateKey, ModuleOrder , NA)
	SELECT @quickChartKey , @moduleKey , @ModuleTemplateKey , 1, NA
	FROM   t_EHR_Module
	WHERE  ModuleKey = @moduleKey
	AND	   Status = 'A'
	AND	   WorkflowKey = @workflowKey


END--'C' action

IF @action = 'A'
BEGIN
	--step 1. update target data table
	-- find the correspond QC module
	DECLARE @MNA BIT = NULL
	SELECT  @MNA = m.NA
	FROM	t_EHR_QC_Module m
	JOIN	t_EHR_ModuleTemplate mt
	ON		mt.ModuleTemplateKey = m.ModuleTemplateKey
	WHERE	m.QuickChartKey = @quickChartKey
	AND		mt.ModuleTemplateKey = @ModuleTemplateKey
	AND		mt.ModuleDesignID = '035'

	-- protects against module not present in template, but is in workflow
	IF @MNA IS NOT NULL
	BEGIN
		UPDATE t_EHR_Module
		SET		NA = @MNA
		WHERE	ModuleKey = @moduleKey

		SELECT * FROM t_EHR_Module WHERE ModuleKey=@moduleKey
		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Module', NULL, NULL, 'U')	
	END
	
END --'A' action

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
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_QC_Specimens'
GO