IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_EndotrachealTubeItemCodeUpdate') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_EndotrachealTubeItemCodeUpdate
GO
-- =============================================================================================================
-- Author:			Darren
-- Create date:		8/11/16
-- Description:		
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_EndotrachealTubeItemCodeUpdate
	@Action			CHAR(1)
	,@CenterID		INT
	,@ChartKey		INT
	,@WorkflowKey	INT
	,@ModuleKey		INT
	,@BundleKey		INT
	,@UIDictionaryKey	INT
	,@Now			SMALLDATETIME
	,@UserID		VARCHAR(60)
AS
BEGIN TRY
	IF @Action = 'T'
	BEGIN
		SELECT	TableName
				,Operation 
		FROM	(
				VALUES ('t_EHR_SupplyUsedDetail','U')
				,('t_EHR_SupplyUsedDetail','I')
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END
	DECLARE @areaKey INT, @supplyUsedModuleKey INT, @scheduledProcedureKey INT, @itemCode INT, @supplyUsedDetailKey INT
	, @hasCorrespondingSupplyUsedDetail BIT, @supplyKey INT, @insertedSupplyUsedDetailKey INT
	

	SELECT @supplyUsedModuleKey = m.ModuleKey
	FROM t_EHR_Module m
	JOIN t_EHR_ModuleTemplate mt
	ON m.ModuleTemplateKey = mt.ModuleTemplateKey
	WHERE mt.CenterID = @CenterID
	AND m.ChartKey = @ChartKey
	AND m.WorkflowKey = @WorkflowKey
	AND mt.ModuleDesignID = '081'

	IF @supplyUsedModuleKey IS NULL
		RETURN

	SELECT @areaKey = AreaKey
	FROM   t_EHR_Workflow
	WHERE  WorkflowKey = @workflowKey

	SELECT	@scheduledProcedureKey = sp.ScheduledProcedureKey
	FROM	t_EHR_Chart c
	JOIN	t_Visit v
	ON		v.VisitKey = c.VisitKey
	JOIN	t_VisitService vs -- make sure there is a procedure/service
	ON		vs.VisitKey = v.VisitKey
	JOIN    t_EHR_ScheduledProcedure sp
	ON		vs.VisitServiceKey = sp.VisitServiceKey
	WHERE	c.ChartKey = @chartKey
	AND		vs.PrimaryProcedure = 1 -- the primary procedure

	SELECT @itemCode = new_EndotrachealTubeItemCode, @supplyUsedDetailKey = new_EndotrachealTubeSupplyUsedDetailKey, @BundleKey = new_BundleKey FROM #t_EHR_Anesthesia_Audit

	SET @hasCorrespondingSupplyUsedDetail = 0
	IF @supplyUsedDetailKey IS NOT NULL AND EXISTS (SELECT * FROM t_EHR_SupplyUsedDetail WHERE SupplyUsedDetailKey = @supplyUsedDetailKey AND Status = 'A')
	BEGIN
		SET @hasCorrespondingSupplyUsedDetail = 1
		SELECT @supplyKey = SupplyKey FROM t_EHR_SupplyUsedDetail WHERE SupplyUsedDetailKey = @supplyUsedDetailKey
	END

	IF @itemCode IS NOT NULL AND (@supplyUsedDetailKey IS NULL OR @hasCorrespondingSupplyUsedDetail = 0)
	BEGIN
		INSERT t_EHR_SupplyUsedDetail (ChartKey, WorkflowKey, ModuleKey, InvGroup, ItemCode, SupplyDescription, AreaKey, Quantity, UnitOfMeasure, CurrentPrice, ScheduledProcedureKey, CreateDate, CreateBy)
		OUTPUT 'I', inserted.*, inserted.* INTO #t_EHR_SupplyUsedDetail_Audit OUTPUT inserted.*
		SELECT @ChartKey, @WorkflowKey, @supplyUsedModuleKey, new_EndotrachealTubeInvGroup, new_EndotrachealTubeItemCode, new_EndotrachealTubeDescription, @areaKey, 1, im.DefaultUOM, im.CurrentPrice, @scheduledProcedureKey, @Now, @UserID
		FROM #t_EHR_Anesthesia_Audit aa
		JOIN t_ItemMaster im
		ON aa.new_EndotrachealTubeInvGroup = im.InvGroup
		AND aa.new_EndotrachealTubeItemCode = im.ItemCode


		SET @insertedSupplyUsedDetailKey = @@IDENTITY

		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_SupplyUsedDetail', NULL, NULL, 'I')

		UPDATE t_EHR_Anesthesia SET EndotrachealTubeSupplyUsedDetailKey = @insertedSupplyUsedDetailKey OUTPUT	'U', deleted.*, inserted.* INTO	#t_EHR_Anesthesia_Audit OUTPUT inserted.* WHERE BundleKey = @BundleKey 
	END
	ELSE IF @itemCode IS NOT NULL AND @hasCorrespondingSupplyUsedDetail = 1 AND @supplyKey IS NULL
	BEGIN
		UPDATE sud SET sud.InvGroup = aa.new_EndotrachealTubeInvGroup, sud.ItemCode = aa.new_EndotrachealTubeItemCode, sud.SupplyDescription = aa.new_EndotrachealTubeDescription
		,sud.ChangeDate = @Now, sud.ChangeBy = @UserID OUTPUT 'U', deleted.*, inserted.* INTO #t_EHR_SupplyUsedDetail_Audit OUTPUT inserted.*
		FROM t_EHR_SupplyUsedDetail sud JOIN #t_EHR_Anesthesia_Audit aa ON sud.SupplyUsedDetailKey = aa.new_EndotrachealTubeSupplyUsedDetailKey

		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_SupplyUsedDetail', NULL, NULL, 'U')
	END
	ELSE IF @itemCode IS NULL AND @hasCorrespondingSupplyUsedDetail = 1 AND @supplyKey IS NULL
	BEGIN
		UPDATE sud SET sud.Status = 'I', sud.ChangeDate = @Now, sud.ChangeBy = @UserID , sud.DeactivateDate = @Now, sud.DeactivateBy = @UserID OUTPUT 'U', deleted.*, inserted.* INTO #t_EHR_SupplyUsedDetail_Audit
		OUTPUT inserted.*
		FROM t_EHR_SupplyUsedDetail sud JOIN #t_EHR_Anesthesia_Audit aa ON sud.SupplyUsedDetailKey = aa.new_EndotrachealTubeSupplyUsedDetailKey

		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_SupplyUsedDetail', NULL, NULL, 'U')
	END

	
	RETURN
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH
GO
EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 8/13/1615'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_EndotrachealTubeItemCodeUpdate'
GO	
	
	