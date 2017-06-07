IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_DrainsAndPacks') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_DrainsAndPacks
GO
-- =============================================================================================================
-- Author:			Darren / Susan
-- Create date:		05/19/17
-- Description:		
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_DrainsAndPacks
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
				,('t_EHR_DrainsAndPacks','U')
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END
	DECLARE @drainsAndPacksKey INT
	DECLARE @newSourceSupplyUsedDetailKey INT
	DECLARE @hasNewSourceSupplyUsedDetailKey BIT

	-- cursor needs to be static, since we may update into the underlying audit table being read from
	DECLARE audit_cursor CURSOR LOCAL STATIC FOR
	SELECT new_DrainsAndPacksKey
	FROM #v_EHR_DrainsAndPacks_Audit
	WHERE [action] = @Action

	OPEN audit_cursor
	
	FETCH NEXT FROM audit_cursor INTO @drainsAndPacksKey

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @supplyUsedDetailKeyFromSourceTable INT
		DECLARE @DataToMatchSuppliesUsed	AS st_DataToMatchSuppliesUsed;

		--interact with ts081
		DECLARE @DataToBePutToSuppliesUsed	AS st_DataToBePutToSuppliesUsed;
		INSERT @DataToBePutToSuppliesUsed 
		SELECT dp.InvGroup, dp.ItemCode, dp.PrefCardItemKey, dp.DrainOrPackingType, 1, im.DefaultUOM, im.CurrentPrice --using Quantity = 1 if not otherwise available
		FROM   t_EHR_DrainsAndPacks dp
		JOIN   t_ItemMaster im
		ON     dp.ItemCode = im.ItemCode
		AND	   dp.InvGroup = im.InvGroup
		WHERE  dp.DrainsAndPacksKey = @drainsAndPacksKey
	
		INSERT	@DataToMatchSuppliesUsed 
		SELECT	ItemCode, SupplyUsedDetailKey 
		FROM	t_EHR_DrainsAndPacks 
		WHERE	DrainsAndPacksKey = @drainsAndPacksKey
	
		EXEC p_EHR_InteractWithSuppliesUsed @Action, @CenterID, @ChartKey, @WorkflowKey, @ModuleKey, @DataToBePutToSuppliesUsed, @DataToMatchSuppliesUsed, @Now, @UserID,  @hasNewSourceSupplyUsedDetailKey OUTPUT, @newSourceSupplyUsedDetailKey OUTPUT

		IF @hasNewSourceSupplyUsedDetailKey = 1
		BEGIN
			UPDATE	t_EHR_DrainsAndPacks 
			SET		SupplyUsedDetailKey = @newSourceSupplyUsedDetailKey 
			OUTPUT	'U', deleted.*, inserted.* INTO	#t_EHR_DrainsAndPacks_Audit 
			OUTPUT	inserted.* 
			WHERE	DrainsAndPacksKey= @drainsAndPacksKey

			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_DrainsAndPacks', NULL, NULL, 'U')
		END		

		FETCH NEXT FROM audit_cursor INTO @drainsAndPacksKey
	END

	CLOSE audit_cursor
	DEALLOCATE audit_cursor
	
	RETURN	
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH
GO
EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 05/19/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_DrainsAndPacks'
GO	
	
	