IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_QC_EquipmentLaserOther') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_QC_EquipmentLaserOther;
GO

-- =============================================================================================================
-- Author:			Darren Lou
-- Create date:		09/22/2016
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
CREATE PROCEDURE p_EHR_QC_EquipmentLaserOther
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
	INSERT INTO t_EHR_QC_LaserOther(  QuickChartKey
										, ModuleTemplateKey
										, ModuleOrder
										, PrecautionsObservedPerPolicy 
										, PreTestPerPolicy)
	SELECT	@quickChartKey
			, @ModuleTemplateKey
			, 1
			, PrecautionsObservedPerPolicy
			, PreTestPerPolicy
	FROM	t_EHR_LaserOther
	WHERE	ChartKey = @chartKey 
	AND     ModuleKey = @moduleKey
	AND		[Status] = 'A' 	



	INSERT INTO t_EHR_QC_LaserOtherDetail(  QuickChartKey
										, ModuleTemplateKey
										, ModuleOrder
										, LaserOtherDetailKey
										, Laser

										--,RentedLaser
										--,RentedLaserSerialNumber
										,BodySiteKey
										,BodySiteName
										,Frequency
		                                ,FrequencyUnit
										,ItemEquipKey
										,IdentificationNumber

										, InvGroup 
										, ItemCode
										, SerialNumber
										--, BodySide
										, [Power]
										, PowerUnit
										, Duration
										, DurationUnit)
	SELECT	@quickChartKey
			, @ModuleTemplateKey
			, 1
			, LaserOtherDetailKey
			, Laser

			--,RentedLaser
			--,RentedLaserSerialNumber
			,BodySiteKey
			,BodySiteName
			,Frequency
		    ,FrequencyUnit
			,ItemEquipKey
			,IdentificationNumber

			, InvGroup 
			, ItemCode
			, SerialNumber
			--, BodySide
			, [Power]
			, PowerUnit
			, Duration
			, DurationUnit
	FROM	t_EHR_LaserOtherDetail
	WHERE	ChartKey = @chartKey 
	AND     ModuleKey = @moduleKey
	AND		[Status] = 'A' 	

		--create QC for notes from t_ehr_module
	--INSERT INTO t_EHR_QC_Module(QuickChartKey,ModuleTemplateKey,ModuleKey,Notes)
	--SELECT @quickChartKey,@ModuleTemplateKey,@moduleKey,Notes
	--FROM t_EHR_Module
	--WHERE ChartKey = @chartKey
	--AND		ModuleKey = @moduleKey

END--'C' action

IF @action = 'A'
BEGIN
	--step 1. update target data table
	--for grid, delete the target data before we inserted data
	UPDATE	t 
	SET  PrecautionsObservedPerPolicy = t1.PrecautionsObservedPerPolicy
			, PreTestPerPolicy = t1.PreTestPerPolicy
			, ChangeBy = @userID
			, ChangeDate = @now
	OUTPUT 'U', deleted.*, inserted.* 
	INTO	#t_EHR_LaserOther_Audit  
	OUTPUT	inserted.* 	
	FROM	t_EHR_LaserOther t
	JOIN	t_EHR_QC_LaserOther t1 
	ON		t1.QuickChartKey=@quickChartKey 
	AND		t1.ModuleTemplateKey=@ModuleTemplateKey 	
	AND     t.ModuleKey = @moduleKey
	AND		t.[Status] = 'A' 

	INSERT INTO #UpdateLog 
	VALUES (@ModuleKey, @WorkflowKey, 't_EHR_LaserOther', NULL, NULL, 'U')

	DECLARE @deleteDetailKey INT
	DECLARE delete_data_cursor CURSOR LOCAL FOR
	SELECT LaserOtherDetailKey 
	FROM t_EHR_LaserOtherDetail 
	WHERE [ChartKey] = @ChartKey 
	AND   ModuleKey = @moduleKey
	AND		[Status] = 'A' 	

	OPEN delete_data_cursor
	FETCH NEXT FROM delete_data_cursor INTO @deleteDetailKey
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE	t_EHR_LaserOtherDetail 
		SET		[Status]='I'
				, DeactivateDate = @Now
				, DeactivateBy = @UserID 
				OUTPUT 'D', deleted.*, inserted.* 
				INTO	#v_EHR_LaserOtherDetail_Audit 	
				OUTPUT inserted.* 
		WHERE	LaserOtherDetailKey = @deleteDetailKey

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 'v_EHR_LaserOtherDetail', NULL, NULL, 'U')

		FETCH NEXT FROM delete_data_cursor INTO @deleteDetailKey
	END
	CLOSE delete_data_cursor
	DEALLOCATE delete_data_cursor
	
	--for grid with trigger
	--we insert data from qc table in a loop scope
	DECLARE @detailKey	INT	
	DECLARE insert_data_cursor CURSOR LOCAL FOR 
	SELECT	LaserOtherDetailKey 
	FROM	t_EHR_QC_LaserOtherDetail 
	WHERE	QuickChartKey = @quickChartKey 
	AND		ModuleTemplateKey = @ModuleTemplateKey

    OPEN insert_data_cursor 
    FETCH NEXT FROM insert_data_cursor INTO  @detailKey
    WHILE @@FETCH_STATUS = 0 
    BEGIN 
	 --
		 INSERT INTO t_EHR_LaserOtherDetail(ChartKey
										, WorkflowKey
										, ModuleKey
										, Laser
										--,RentedLaser
										--,RentedLaserSerialNumber
										,BodySiteKey
										,BodySiteName
										,Frequency
		                                ,FrequencyUnit
										,ItemEquipKey
										,IdentificationNumber

										, InvGroup
										, ItemCode
										, SerialNumber
										--, BodySide
										, [Power]
										, PowerUnit
										, Duration
										, DurationUnit
										, CreateDate
										, CreateBy) 
		OUTPUT 'I', inserted.*, inserted.*  
		INTO	#v_EHR_LaserOtherDetail_Audit 		 
		OUTPUT  inserted.*
		SELECT	@ChartKey
				, @workflowKey
				, @moduleKey
				, Laser

				--,RentedLaser
				--,RentedLaserSerialNumber
				,BodySiteKey
				,BodySiteName
				,Frequency
		        ,FrequencyUnit
				,ItemEquipKey
				,IdentificationNumber
				, InvGroup
				, ItemCode			
				, SerialNumber
				--, BodySide
				, [Power]
				, PowerUnit
				, Duration
				, DurationUnit
				, @Now
				, @UserID 
		FROM	t_EHR_QC_LaserOtherDetail 
		WHERE	QuickChartKey=@quickChartKey		
		AND		ModuleTemplateKey=@ModuleTemplateKey
		AND		LaserOtherDetailKey = @detailKey	
		

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 'v_EHR_LaserOtherDetail', NULL, NULL, 'I')
		--exec lET trigger as you want

		FETCH NEXT FROM insert_data_cursor INTO  @detailKey
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
     ,@value = N'Rev Date: 09/22/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_QC_EquipmentLaserOther'
GO