IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_Dressing') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_Dressing
GO
-- =============================================================================================================
-- Author:			Darren / Susan
-- Create date:		05/19/17
-- Description:		
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_Dressing
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
				,('t_EHR_DressingDetail','U')
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END

	DECLARE @dressingKey INT
	DECLARE @newSourceSupplyUsedDetailKey INT
	DECLARE @hasNewSourceSupplyUsedDetailKey BIT

	-- cursor needs to be static, since we may update into the underlying audit table being read from
	DECLARE audit_cursor CURSOR LOCAL STATIC FOR
	SELECT new_DressingDetailKey
	FROM #t_EHR_DressingDetail_Audit
	WHERE [action] = @Action

	OPEN audit_cursor
	
	FETCH NEXT FROM audit_cursor INTO @dressingKey 

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--interact with ts081
		DECLARE @DataToBePutToSuppliesUsed	AS st_DataToBePutToSuppliesUsed;
		DECLARE @DataToMatchSuppliesUsed	AS st_DataToMatchSuppliesUsed;

		INSERT @DataToBePutToSuppliesUsed 
		SELECT dd.InvGroup, dd.ItemCode, dd.PrefCardItemKey, dd.DressingName, dd.Quantity, dd.UOM, im.CurrentPrice
		FROM   t_EHR_DressingDetail dd
		JOIN   t_ItemMaster im
		ON     dd.ItemCode = im.ItemCode
		AND	   dd.InvGroup = im.InvGroup
		WHERE  dd.DressingDetailKey = @dressingKey
	
		INSERT	@DataToMatchSuppliesUsed 
		SELECT	ItemCode, SupplyUsedDetailKey 
		FROM	t_EHR_DressingDetail 
		WHERE	DressingDetailKey = @dressingKey
	
		EXEC p_EHR_InteractWithSuppliesUsed @Action, @CenterID, @ChartKey, @WorkflowKey, @ModuleKey, @DataToBePutToSuppliesUsed, @DataToMatchSuppliesUsed, @Now, @UserID,  @hasNewSourceSupplyUsedDetailKey OUTPUT, @newSourceSupplyUsedDetailKey OUTPUT

		IF @hasNewSourceSupplyUsedDetailKey = 1
		BEGIN
			UPDATE	t_EHR_DressingDetail 
			SET		SupplyUsedDetailKey = @newSourceSupplyUsedDetailKey 
			OUTPUT	'U', deleted.*, inserted.* INTO	#t_EHR_DressingDetail_Audit 
			OUTPUT	inserted.* 
			WHERE	DressingDetailKey= @dressingKey

			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_DressingDetail', NULL, NULL, 'U')
		END		

		IF EXISTS (SELECT 1 FROM t_EHR_DressingDetail WHERE DressingDetailKey = @dressingKey AND ServiceCode IS NULL)
		BEGIN
			DECLARE @ServiceCode CHAR(8)
			SELECT @ServiceCode = ServiceCode
			FROM	t_VisitService vs 
			INNER JOIN t_EHR_Chart c 
			ON 		c.VisitKey = vs.VisitKey
			WHERE	c.ChartKey = @chartKey
			AND		vs.PrimaryProcedure = 1

			UPDATE t_EHR_DressingDetail SET ServiceCode = @ServiceCode 
			OUTPUT	'U', deleted.*, inserted.* INTO	#t_EHR_DressingDetail_Audit 
			OUTPUT	inserted.* 
			WHERE DressingDetailKey = @dressingKey
					
			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_DressingDetail', NULL, NULL, 'U')
		END


		FETCH NEXT FROM audit_cursor INTO @dressingKey 
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
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_Dressing'
GO	
	
	