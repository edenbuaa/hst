IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_Solution') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_Solution
GO
-- =============================================================================================================
-- Author:			Darren/Susan
-- Create date:		05/19/17
-- Description:		
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_Solution
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
				,('t_EHR_Solution','U')
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END
	DECLARE @solutionKey INT
	DECLARE @newSourceSupplyUsedDetailKey INT
	DECLARE @hasNewSourceSupplyUsedDetailKey BIT

	DECLARE audit_cursor CURSOR LOCAL STATIC FOR
	SELECT new_SolutionKey
	FROM #t_EHR_Solution_Audit
	WHERE [action] = @Action

	OPEN audit_cursor

	FETCH NEXT FROM audit_cursor INTO @solutionKey

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--interact with ts081
		DECLARE @DataToBePutToSuppliesUsed	AS st_DataToBePutToSuppliesUsed;
		DECLARE @DataToMatchSuppliesUsed	AS st_DataToMatchSuppliesUsed;

		INSERT @DataToBePutToSuppliesUsed 
		SELECT s.InvGroup, s.ItemCode, s.PrefCardItemKey, s.Solution, s.Quantity, s.UOM, im.CurrentPrice
		FROM   t_EHR_Solution s
		JOIN   t_ItemMaster im
		ON     s.ItemCode = im.ItemCode
		AND	   s.InvGroup = im.InvGroup
		WHERE  s.SolutionKey = @solutionKey
	
		INSERT	@DataToMatchSuppliesUsed 
		SELECT	ItemCode, SupplyUsedDetailKey 
		FROM	t_EHR_Solution 
		WHERE	SolutionKey = @solutionKey
	
		EXEC p_EHR_InteractWithSuppliesUsed @Action, @CenterID, @ChartKey, @WorkflowKey, @ModuleKey, @DataToBePutToSuppliesUsed, @DataToMatchSuppliesUsed, @Now, @UserID,  @hasNewSourceSupplyUsedDetailKey OUTPUT, @newSourceSupplyUsedDetailKey OUTPUT

		IF @hasNewSourceSupplyUsedDetailKey = 1
		BEGIN
			UPDATE	t_EHR_Solution 
			SET		SupplyUsedDetailKey = @newSourceSupplyUsedDetailKey 
			OUTPUT	'U', deleted.*, inserted.* INTO	#t_EHR_Solution_Audit 
			OUTPUT	inserted.* 
			WHERE	SolutionKey= @solutionKey

			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Solution', NULL, NULL, 'U')
		END		

		FETCH NEXT FROM audit_cursor INTO @solutionKey
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
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_Solution'
GO	
	
	