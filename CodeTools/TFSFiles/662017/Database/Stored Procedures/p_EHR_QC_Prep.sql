IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_QC_Prep') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_QC_Prep;
GO

-- =============================================================================================================
-- Author:			Darren Lou
-- Create date:		12/20/2016
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
CREATE PROCEDURE p_EHR_QC_Prep
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
	INSERT INTO t_EHR_QC_Prep(  QuickChartKey
								, ModuleTemplateKey
								, ModuleOrder
								, ChartKey 
								, WorkflowKey
								, ModuleKey
								, ShaveNone
								, ShaveDipilatory
								, ShaveClippers
								, ShaveRazor
								, ShavePerformedAtHome
								, ShavePerformedByStaff
								, ShaveByIDType
								, ShaveByID
								, ShaveByName
								, PrepDriedCompletely)
	SELECT	@quickChartKey
			, @ModuleTemplateKey
			, 1
			, ChartKey 
			, WorkflowKey
			, ModuleKey
			, ShaveNone
			, ShaveDipilatory
			, ShaveClippers
			, ShaveRazor
			, ShavePerformedAtHome
			, ShavePerformedByStaff
			, ShaveByIDType
			, ShaveByID
			, ShaveByName
			, PrepDriedCompletely
	FROM	t_EHR_Prep
	WHERE	[ChartKey] = @chartKey 
	AND     [ModuleKey] = @moduleKey
	AND     [WorkflowKey] = @workflowKey
	AND		[Status] = 'A' 	

	INSERT INTO t_EHR_QC_PrepDetail(  QuickChartKey
										, ModuleTemplateKey
										, ModuleOrder
										, ChartKey 
										, WorkflowKey
										, ModuleKey
										, PrepDetailKey
										, InvGroup
										, ItemCode
										, PrepSolution
										, BodySiteKey
										, BodySiteName
										, PerformedByID
										, PerformedByIDType
										, PerformedByName
										, PrefCardItemKey
										, Notes)
	SELECT	@quickChartKey
			, @ModuleTemplateKey
			, 1
			, ChartKey 
			, WorkflowKey
			, ModuleKey
			, PrepDetailKey
			, InvGroup
			, ItemCode
			, PrepSolution
			, BodySiteKey
			, BodySiteName 
			, PerformedByID
			, PerformedByIDType
			, PerformedByName
			, PrefCardItemKey
			, Notes
	FROM	t_EHR_PrepDetail
	WHERE	[ChartKey] = @chartKey 
	AND     [ModuleKey] = @moduleKey
	AND     [WorkflowKey] = @workflowKey
	AND		[Status] = 'A' 	

END--'C' action

IF @action = 'A'
BEGIN
	--step 1. update target data table
	--for grid, delete the target data before we inserted data
	UPDATE	t_EHR_Prep 
	SET		ShaveNone = t1.ShaveNone
			, ShaveDipilatory = t1.ShaveDipilatory
			, ShaveClippers = t1.ShaveClippers
			, ShaveRazor	= t1.ShaveRazor
			, PrepDriedCompletely = t1.PrepDriedCompletely
			, ShavePerformedAtHome = t1.ShavePerformedAtHome
			, ShavePerformedByStaff = t1.ShavePerformedByStaff
			, ShaveByIDType = t1.ShaveByIDType
			, ShaveByID = t1.ShaveByID
			, ShaveByName = t1.ShaveByName
			, ChangeBy = @userID
			, ChangeDate = @now
	OUTPUT 'U', deleted.*, inserted.* 
	INTO	#t_EHR_Prep_Audit  
	OUTPUT	inserted.* 	
	FROM	t_EHR_Prep t
	JOIN	t_EHR_QC_Prep t1 
	ON		t1.QuickChartKey=@quickChartKey 
	AND		t1.ModuleTemplateKey=@ModuleTemplateKey 	
	AND     t.ChartKey = @chartKey
	AND     t.ModuleKey = @moduleKey
	AND		t.[Status] = 'A' 

	INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Prep', NULL, NULL, 'U')

	DECLARE @deletedKey INT
	DECLARE delete_data_cursor CURSOR LOCAL FOR
	SELECT PrepDetailKey 
	FROM t_EHR_PrepDetail 
	WHERE [ChartKey] = @ChartKey 
	AND     [ModuleKey] = @moduleKey
	AND		[Status] = 'A' 	

	OPEN delete_data_cursor
	FETCH NEXT FROM delete_data_cursor INTO @deletedKey
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE	t_EHR_PrepDetail 
		SET		[Status]='I'
				, DeactivateDate = @Now
				, DeactivateBy = @UserID 
				OUTPUT 'D', deleted.*, inserted.* 
				INTO	#t_EHR_PrepDetail_Audit 	
				OUTPUT inserted.* 
		WHERE	PrepDetailKey = @deletedKey

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 't_EHR_PrepDetail', NULL, NULL, 'U')

		FETCH NEXT FROM delete_data_cursor INTO @deletedKey
	END
	CLOSE delete_data_cursor
	DEALLOCATE delete_data_cursor
	
	--for grid with trigger
	--we insert data from qc table in a loop scope
	DECLARE @prepDetailKey	INT	
	DECLARE insert_data_cursor CURSOR LOCAL FOR 
	SELECT	PrepDetailKey 
	FROM	t_EHR_QC_PrepDetail 
	WHERE	QuickChartKey = @quickChartKey 
	AND		ModuleTemplateKey = @ModuleTemplateKey

    OPEN insert_data_cursor 
    FETCH NEXT FROM insert_data_cursor INTO  @prepDetailKey
    WHILE @@FETCH_STATUS = 0 
    BEGIN 
	 --
		 INSERT INTO t_EHR_PrepDetail (	ChartKey
										,WorkflowKey
										,ModuleKey
										,InvGroup
										,ItemCode
										,PrepSolution
										,BodySiteKey
										,BodySiteName
										,PerformedByID
										,PerformedByIDType
										,PerformedByName
										,Notes
										,CreateDate
										,CreateBy) 
		OUTPUT 'I', inserted.*, inserted.*  
		INTO	#t_EHR_PrepDetail_Audit 		 
		OUTPUT  inserted.*
		SELECT	@ChartKey
				, @workflowKey
				, @moduleKey
				, InvGroup
				, ItemCode			
				, PrepSolution
				, BodySiteKey
				, BodySiteName
				, PerformedByID
				, PerformedByIDType
				, PerformedByName
				, Notes
				, @Now
				, @UserID 
		FROM	t_EHR_QC_PrepDetail
		WHERE	QuickChartKey=@quickChartKey		
		AND		ModuleTemplateKey=@ModuleTemplateKey
		AND		PrepDetailKey = @prepDetailKey	
		

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 't_EHR_PrepDetail', NULL, NULL, 'I')
		--exec lET trigger as you want

		FETCH NEXT FROM insert_data_cursor INTO  @prepDetailKey
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
     ,@value = N'Rev Date: 12/20/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_QC_Prep'
GO