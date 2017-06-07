IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_QC_Solution') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_QC_Solution;
GO

-- =============================================================================================================
-- Author:			Darren Lou
-- Create date:		09/07/2016
-- Description:		create or apply the quick chart by manual mode
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
CREATE PROCEDURE p_EHR_QC_Solution
	 @action			varchar(1)
	,@chartKey			INT
	,@workflowKey	    int			
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
	INSERT INTO t_EHR_QC_Solution(  QuickChartKey
										, ModuleTemplateKey
										, ModuleOrder
										, SolutionKey 
										, InvGroup
										, ItemCode
										, Solution
										, UOM
										, Quantity
										, RouteKey
										, [Route])
	SELECT	@quickChartKey
			, @ModuleTemplateKey
			, 1
			, SolutionKey
			, InvGroup
			, ItemCode
			, Solution
			, UOM
			, Quantity
			, RouteKey
			, [Route]
			 
	FROM	t_EHR_Solution
	WHERE	[ChartKey] = @chartKey 
	AND     [ModuleKey] = @moduleKey
	AND     [PrefCardItemKey] IS NOT NULL
	AND		[Status] = 'A' 	

END--'C' action

IF @action = 'A'
BEGIN
	--step 1. update target data table
	--for grid, delete the target data before we inserted data

	DECLARE @deletedSolutionKey INT
	DECLARE delete_data_cursor CURSOR LOCAL FOR
	SELECT SolutionKey 
	FROM t_EHR_Solution 
	WHERE [ChartKey] = @ChartKey 
	AND     [ModuleKey] = @moduleKey
	AND		[Status] = 'A' 	

	OPEN delete_data_cursor
	FETCH NEXT FROM delete_data_cursor INTO @deletedSolutionKey
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE	t_EHR_Solution 
		SET		[Status]='I'
				, DeactivateDate = @Now
				, DeactivateBy = @UserID 
				OUTPUT 'D', deleted.*, inserted.* 
				INTO	#t_EHR_Solution_Audit 	
				OUTPUT inserted.* 
		WHERE	SolutionKey = @deletedSolutionKey

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Solution', NULL, NULL, 'U')

		FETCH NEXT FROM delete_data_cursor INTO @deletedSolutionKey
	END
	CLOSE delete_data_cursor
	DEALLOCATE delete_data_cursor
	
	--for grid with trigger
	--we insert data from qc table in a loop scope
	DECLARE @solutionKey	INT	
	DECLARE insert_data_cursor CURSOR LOCAL FOR 
	SELECT	SolutionKey 
	FROM	t_EHR_QC_Solution 
	WHERE	QuickChartKey = @quickChartKey 
	AND		ModuleTemplateKey = @ModuleTemplateKey

    OPEN insert_data_cursor 
    FETCH NEXT FROM insert_data_cursor INTO  @solutionKey
    WHILE @@FETCH_STATUS = 0 
    BEGIN 
	 --
		 INSERT INTO t_EHR_Solution (	ChartKey
										,WorkflowKey
										,ModuleKey
										,InvGroup
										, ItemCode
										, Solution
										, UOM
										, Quantity
										, RouteKey
										, [Route]
										, CreateDate
										, CreateBy) 
		OUTPUT 'I', inserted.*, inserted.*  
		INTO	#t_EHR_Solution_Audit 		 
		OUTPUT  inserted.*
		SELECT	@ChartKey
				, @workflowKey
				, @moduleKey
				, InvGroup
				, ItemCode			
				, Solution
				, UOM	
				, Quantity
				, RouteKey
				, [Route]		
				, @Now
				, @UserID 
		FROM	t_EHR_QC_Solution 
		WHERE	QuickChartKey=@quickChartKey		
		AND		ModuleTemplateKey=@ModuleTemplateKey
		AND		SolutionKey = @solutionKey	
		

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Solution', NULL, NULL, 'I')

		FETCH NEXT FROM insert_data_cursor INTO  @solutionKey
	 END 
	CLOSE insert_data_cursor 
    DEALLOCATE insert_data_cursor 
	
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
     ,@value = N'Rev Date: 09/07/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_QC_Solution'
GO