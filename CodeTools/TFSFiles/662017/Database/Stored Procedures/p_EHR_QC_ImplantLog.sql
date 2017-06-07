IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_QC_ImplantLog') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_QC_ImplantLog;
GO

-- =============================================================================================================
-- Author:			Darren Lou
-- Create date:		09/21/2016
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
CREATE PROCEDURE p_EHR_QC_ImplantLog
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
IF @action = 'T'
BEGIN
	SELECT	TableName
			,ExternalTable 
	FROM	(
			VALUES ('t_EHR_SupplyUsedDetail',1)
			)
	AS ExternalTableList (TableName,ExternalTable)

	RETURN;
END
IF @action = 'C'
BEGIN
	
	--fill data to qc from the current valid data
	INSERT INTO t_EHR_QC_ImplantLogDetail(  QuickChartKey
										, ModuleTemplateKey
										, ModuleOrder
										, ImplantLogDetailKey 
										, InvGroup
										, ItemCode
										, ItemDescription
										, Quantity
										, BodySiteKey)
	SELECT	@quickChartKey
			, @ModuleTemplateKey
			, 1
			, ImplantLogDetailKey
			, InvGroup
			, ItemCode
			, ItemDescription
			, Quantity
			, BodySiteKey
			 
	FROM	t_EHR_ImplantLogDetail
	WHERE	ChartKey = @chartKey 
	AND     ModuleKey = @moduleKey
	AND     ItemCode IS NOT NULL
	AND		[Status] = 'A' 	

END--'C' action

IF @action = 'A'
BEGIN
	--step 1. update target data table
	--for grid, delete the target data before we inserted data

	DECLARE @deletedImplantLogDetailKey INT
	DECLARE delete_data_cursor CURSOR LOCAL FOR
	SELECT ImplantLogDetailKey 
	FROM t_EHR_ImplantLogDetail 
	WHERE [ChartKey] = @ChartKey 
	AND     [ModuleKey] = @moduleKey
	AND		[Status] = 'A' 	

	OPEN delete_data_cursor
	FETCH NEXT FROM delete_data_cursor INTO @deletedImplantLogDetailKey
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE	t_EHR_ImplantLogDetail 
		SET		[Status]='I'
				, DeactivateDate = @Now
				, DeactivateBy = @UserID 
				OUTPUT 'D', deleted.*, inserted.* 
				INTO	#v_EHR_ImplantLogDetail_Audit 	
				OUTPUT inserted.* 
		WHERE	ImplantLogDetailKey = @deletedImplantLogDetailKey

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 'v_EHR_ImplantLogDetail', NULL, NULL, 'U')

		FETCH NEXT FROM delete_data_cursor INTO @deletedImplantLogDetailKey
	END
	CLOSE delete_data_cursor
	DEALLOCATE delete_data_cursor
	
	--for grid with trigger
	--we insert data from qc table in a loop scope
	DECLARE @implantLogDetailKey	INT	
	DECLARE insert_data_cursor CURSOR LOCAL FOR 
	SELECT	ImplantLogDetailKey 
	FROM	t_EHR_QC_ImplantLogDetail 
	WHERE	QuickChartKey = @quickChartKey 
	AND		ModuleTemplateKey = @ModuleTemplateKey

    OPEN insert_data_cursor 
    FETCH NEXT FROM insert_data_cursor INTO  @implantLogDetailKey
    WHILE @@FETCH_STATUS = 0 
    BEGIN 
	 --
		 INSERT INTO t_EHR_ImplantLogDetail (ChartKey
										,WorkflowKey
										,ModuleKey
										,InvGroup
										, ItemCode
										, ItemDescription
										, Quantity
										, BodySiteKey
										, CreateDate
										, CreateBy) 
		OUTPUT 'I', inserted.*, inserted.*  
		INTO	#v_EHR_ImplantLogDetail_Audit 		 
		OUTPUT  inserted.*
		SELECT	@ChartKey
				, @workflowKey
				, @moduleKey
				, InvGroup
				, ItemCode			
				, ItemDescription
				, Quantity
				, BodySiteKey
				, @Now
				, @UserID 
		FROM	t_EHR_QC_ImplantLogDetail 
		WHERE	QuickChartKey=@quickChartKey		
		AND		ModuleTemplateKey=@ModuleTemplateKey
		AND		ImplantLogDetailKey = @implantLogDetailKey	
		

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 'v_EHR_ImplantLogDetail', NULL, NULL, 'I')
		--exec lET trigger as you want

		FETCH NEXT FROM insert_data_cursor INTO  @implantLogDetailKey
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
     ,@value = N'Rev Date: 09/21/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_QC_ImplantLog'
GO