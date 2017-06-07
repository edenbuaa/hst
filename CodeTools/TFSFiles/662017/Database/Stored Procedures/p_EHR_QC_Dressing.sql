IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_QC_Dressing') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_QC_Dressing;
GO

-- =============================================================================================================
-- Author:			Darren Lou
-- Create date:		09/08/2016
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
CREATE PROCEDURE p_EHR_QC_Dressing
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
	INSERT INTO t_EHR_QC_Dressing(  QuickChartKey
										, ModuleTemplateKey
										, ModuleOrder
										, TapePaper 
										, TapePlastic
										, TapeSilk
										, TapeCloth
										, TapeOther
										, TapeOtherNote)
	SELECT	@quickChartKey
			, @ModuleTemplateKey
			, 1
			, TapePaper
			, TapePlastic
			, TapeSilk
			, TapeCloth
			, TapeOther
			, TapeOtherNote
	FROM	t_EHR_Dressing
	WHERE	[ChartKey] = @chartKey 
	AND		[Status] = 'A' 	

	INSERT INTO t_EHR_QC_DressingDetail(  QuickChartKey
										, ModuleTemplateKey
										, ModuleOrder
										, DressingDetailKey
										, InvGroup 
										, ItemCode
										, ServiceCode
										, DressingName
										, BodySiteKey
										, BodySiteName
										, UOM
										, Quantity)
	SELECT	@quickChartKey
			, @ModuleTemplateKey
			, 1
			, DressingDetailKey
			, InvGroup 
			, ItemCode
			, ServiceCode
			, DressingName
			, BodySiteKey
			, BodySiteName
			, UOM
			, Quantity
	FROM	t_EHR_DressingDetail
	WHERE	[ChartKey] = @chartKey 
	AND		[Status] = 'A' 		

END--'C' action

IF @action = 'A'
BEGIN
	--step 1. update target data table
	--for grid, delete the target data before we inserted data
	UPDATE	t_EHR_Dressing 
	SET  TapePaper = t1.TapePaper
			, TapePlastic = t1.TapePlastic
			, TapeSilk = t1.TapeSilk
			, TapeCloth	= t1.TapeCloth
			, TapeOther = t1.TapeOther
			, TapeOtherNote	= t1.TapeOtherNote
			, ChangeBy = @userID
			, ChangeDate = @now
	OUTPUT 'U', deleted.*, inserted.* 
	INTO	#t_EHR_Dressing_Audit  
	OUTPUT	inserted.* 	
	FROM		t_EHR_Dressing t
	JOIN	t_EHR_QC_Dressing t1 
	ON		t1.QuickChartKey=@quickChartKey 
	AND			t1.ModuleTemplateKey=@ModuleTemplateKey 	
	AND         t.ChartKey = @chartKey
	--AND         t.ModuleKey = @moduleKey
	AND			t.[Status] = 'A' 

	INSERT INTO #UpdateLog 
	VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Dressing', NULL, NULL, 'U')

	DECLARE @deletedDessingDetailKey INT
	DECLARE delete_data_cursor CURSOR LOCAL FOR
	SELECT DressingDetailKey 
	FROM t_EHR_DressingDetail 
	WHERE [ChartKey] = @ChartKey 
	AND		[Status] = 'A' 	

	OPEN delete_data_cursor
	FETCH NEXT FROM delete_data_cursor INTO @deletedDessingDetailKey
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE	t_EHR_DressingDetail 
		SET		[Status]='I'
				, DeactivateDate = @Now
				, DeactivateBy = @UserID 
				OUTPUT 'D', deleted.*, inserted.* 
				INTO	#t_EHR_DressingDetail_Audit 	
				OUTPUT inserted.* 
		WHERE	DressingDetailKey = @deletedDessingDetailKey

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 't_EHR_DressingDetail', NULL, NULL, 'U')

		FETCH NEXT FROM delete_data_cursor INTO @deletedDessingDetailKey
	END
	CLOSE delete_data_cursor
	DEALLOCATE delete_data_cursor
	
	--for grid with trigger
	--we insert data from qc table in a loop scope
	DECLARE @dressingDetailKey	INT	
	DECLARE insert_data_cursor CURSOR LOCAL FOR 
	SELECT	DressingDetailKey 
	FROM	t_EHR_QC_DressingDetail 
	WHERE	QuickChartKey = @quickChartKey 
	AND		ModuleTemplateKey = @ModuleTemplateKey

    OPEN insert_data_cursor 
    FETCH NEXT FROM insert_data_cursor INTO  @dressingDetailKey
    WHILE @@FETCH_STATUS = 0 
    BEGIN 
	 --
		 INSERT INTO t_EHR_DressingDetail(ChartKey
										,InvGroup
										, ItemCode
										, ServiceCode
										, DressingName
										, UOM
										, Quantity
										, BodySiteKey
										, BodySiteName
										, Notes
										, CreateDate
										, CreateBy) 
		OUTPUT 'I', inserted.*, inserted.*  
		INTO	#t_EHR_DressingDetail_Audit 		 
		OUTPUT  inserted.*
		SELECT	@ChartKey
				, InvGroup
				, ItemCode			
				, ServiceCode
				, DressingName
				, UOM
				, Quantity	
				, BodySiteKey
				, BodySiteName
				, Notes
				, @Now
				, @UserID 
		FROM	t_EHR_QC_DressingDetail 
		WHERE	QuickChartKey=@quickChartKey		
		AND		ModuleTemplateKey=@ModuleTemplateKey
		AND		DressingDetailKey = @dressingDetailKey	
		

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 't_EHR_DressingDetail', NULL, NULL, 'I')

		FETCH NEXT FROM insert_data_cursor INTO  @dressingDetailKey
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
     ,@value = N'Rev Date: 09/08/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_QC_Dressing'
GO