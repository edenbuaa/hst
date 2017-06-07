IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_QC_TourniquetComplex') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_QC_TourniquetComplex;
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
CREATE PROCEDURE p_EHR_QC_TourniquetComplex
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

SELECT @ModuleTemplateKey = ModuleTemplateKey 
FROM	t_EHR_Module
WHERE	ModuleKey = @moduleKey

BEGIN TRY
IF @action = 'C'
BEGIN
	
	--fill data to qc from the current valid data
	INSERT INTO t_EHR_QC_Tourniquet(  QuickChartKey
										, ModuleTemplateKey
										, ModuleOrder
										, PretestComplete 
										, PaddingUnderCuff
										, PressureLimitApproved)
	SELECT	@quickChartKey
			, @ModuleTemplateKey
			, 1
			, PretestComplete
			, PaddingUnderCuff
			, PressureLimitApproved
			 
	FROM	t_EHR_Tourniquet
	WHERE	ChartKey = @chartKey 
	AND     ModuleKey = @moduleKey
	AND		[Status] = 'A' 	

	INSERT INTO t_EHR_QC_TourniquetDetail(  QuickChartKey
										, ModuleTemplateKey
										, ModuleOrder
										, TourniquetDetailKey 
										, EquipmentType
										, ItemEquipKey
										, IdentificationNumber
										, SerialNumber
										, BodySiteKey
										, BodySiteName
										, BodySide
										, Pressure)
	SELECT	@quickChartKey
			, @ModuleTemplateKey
			, 1
			, TourniquetDetailKey
			, EquipmentType
			, ItemEquipKey
			, IdentificationNumber
			, SerialNumber
			, BodySiteKey
			, BodySiteName
			, BodySide
			, Pressure
			 
	FROM	t_EHR_TourniquetDetail
	WHERE	ChartKey = @chartKey 
	AND     ModuleKey = @moduleKey
	AND     ISNULL(SerialNumber, '') <> ''
	AND		[Status] = 'A'

END--'C' action

IF @action = 'A'
BEGIN
	--step 1. update target data table
	--for grid, delete the target data before we inserted data
	UPDATE	t_EHR_Tourniquet 
	SET  PretestComplete = t1.PretestComplete
			, PaddingUnderCuff = t1.PaddingUnderCuff
			, PressureLimitApproved = t1.PressureLimitApproved
			, ChangeBy = @userID
			, ChangeDate = @now

	OUTPUT 'U', deleted.*, inserted.* 
	INTO	#t_EHR_Tourniquet_Audit  
	OUTPUT	inserted.* 	
	FROM		t_EHR_Tourniquet t
	JOIN	t_EHR_QC_Tourniquet t1 
	ON		t1.QuickChartKey=@quickChartKey 
	AND			t1.ModuleTemplateKey=@ModuleTemplateKey 	
	AND         t.ModuleKey = @moduleKey
	AND			t.[Status] = 'A' 

	INSERT INTO #UpdateLog 
	VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Tourniquet', NULL, NULL, 'U')


	DECLARE @deletedTourniquetDetailKey INT
	DECLARE delete_data_cursor CURSOR LOCAL FOR
	SELECT TourniquetDetailKey 
	FROM t_EHR_TourniquetDetail 
	WHERE [ChartKey] = @ChartKey 
	AND     [ModuleKey] = @moduleKey
	AND		[Status] = 'A' 	

	OPEN delete_data_cursor
	FETCH NEXT FROM delete_data_cursor INTO @deletedTourniquetDetailKey
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE	t_EHR_TourniquetDetail 
		SET		[Status]='I'
				, DeactivateDate = @Now
				, DeactivateBy = @UserID 
				OUTPUT 'D', deleted.*, inserted.* 
				INTO	#v_EHR_TourniquetDetail_Audit 	
				OUTPUT inserted.* 
		WHERE	TourniquetDetailKey = @deletedTourniquetDetailKey

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 'v_EHR_TourniquetDetail', NULL, NULL, 'U')

		FETCH NEXT FROM delete_data_cursor INTO @deletedTourniquetDetailKey
	END
	CLOSE delete_data_cursor
	DEALLOCATE delete_data_cursor
	
	--for grid with trigger
	--we insert data from qc table in a loop scope
	DECLARE @tourniquetDetailKey	INT	
	DECLARE insert_data_cursor CURSOR LOCAL FOR 
	SELECT	TourniquetDetailKey 
	FROM	t_EHR_QC_TourniquetDetail 
	WHERE	QuickChartKey = @quickChartKey 
	AND		ModuleTemplateKey = @ModuleTemplateKey

    OPEN insert_data_cursor 
    FETCH NEXT FROM insert_data_cursor INTO  @tourniquetDetailKey
    WHILE @@FETCH_STATUS = 0 
    BEGIN 
	 --
		 INSERT INTO t_EHR_TourniquetDetail (ChartKey
										, WorkflowKey
										, ModuleKey
										, EquipmentType
										, ItemEquipKey
										, IdentificationNumber
										, SerialNumber
										, BodySiteKey
										, BodySiteName
										, BodySide
										, Pressure
										, CreateDate
										, CreateBy) 
		OUTPUT 'I', inserted.*, inserted.*  
		INTO	#v_EHR_TourniquetDetail_Audit 		 
		OUTPUT  inserted.*
		SELECT	@ChartKey
				, @workflowKey
				, @moduleKey
				, EquipmentType
				, ItemEquipKey
				, IdentificationNumber
				, SerialNumber
				, BodySiteKey
				, BodySiteName
				, BodySide
				, Pressure
				, @Now
				, @UserID 
		FROM	t_EHR_QC_TourniquetDetail 
		WHERE	QuickChartKey=@quickChartKey		
		AND		ModuleTemplateKey=@ModuleTemplateKey
		AND		TourniquetDetailKey = @tourniquetDetailKey	
		

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 'v_EHR_TourniquetDetail', NULL, NULL, 'I')
		--exec lET trigger as you want

	
		FETCH NEXT FROM insert_data_cursor INTO  @tourniquetDetailKey
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
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_QC_TourniquetComplex'
GO