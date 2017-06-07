IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_ImplantLogDetail') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_ImplantLogDetail
GO
-- =============================================================================================================
-- Author:			Darren
-- Create date:		03/14/16
-- Description:		
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_ImplantLogDetail
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
				,('t_EHR_ImplantLogDetail','U')
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END
	DECLARE @implantLogDetailKey INT
	DECLARE @visitKey INT
	DECLARE @physicianID INT

	DECLARE @newSourceImplantDetailKey INT
	DECLARE @hasNewSourceImplantDetailKey BIT

	DECLARE @newSourceSupplyUsedDetailKey INT
	DECLARE @hasNewSourceSupplyUsedDetailKey BIT

	SELECT @visitKey = VisitKey FROM t_EHR_Chart WHERE ChartKey = @chartKey;

	SELECT	@physicianID = vp.PhysicianID
			FROM	t_EHR_Chart c
			JOIN	t_Visit v
			ON		v.VisitKey = c.VisitKey
			JOIN	t_VisitService vs -- make sure there is a procedure/service
			ON		vs.VisitKey = v.VisitKey
			JOIN	t_VisitPhysician vp -- make sure there is a physician for the procedure/service
			ON		vp.VisitKey = vs.VisitKey
			AND		vp.VisitServiceKey = vs.VisitServiceKey
			JOIN	t_PhysicianPrefCard pc
			ON		pc.CenterID = vp.CenterID
			AND		pc.PhysicianID = vp.PhysicianID
			AND		pc.ServiceCode = vs.ServiceCode
			WHERE	c.ChartKey = @ChartKey
			AND		vs.PrimaryProcedure = 1 -- the primary procedure
			AND		vp.PrimaryRole = 1 -- the primary physician



	-- cursor needs to be static, since we may update into the underlying audit table being read from
	DECLARE audit_cursor CURSOR LOCAL STATIC FOR
	SELECT new_ImplantLogDetailKey
	FROM #v_EHR_ImplantLogDetail_Audit
	WHERE [action] = @Action

	OPEN audit_cursor

	FETCH NEXT FROM audit_cursor INTO @implantLogDetailKey

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--interact with pathways (t_VisitImplant)
		DECLARE @DataToBePutToVisitImplant	AS st_DataToBePutToVisitImplant;
		INSERT @DataToBePutToVisitImplant 
			SELECT ImplantType, InvGroup, ItemCode, LEFT(ISNULL(ItemDescription, [Description]), 50), Manufacturer, LotNumber, SerialNumber, ImplantSize, [ExpireDate], Notes, ISNULL(BodySide, ''), CatalogNumber, ImplantKey
			FROM   t_EHR_ImplantLogDetail
			WHERE  ImplantLogDetailKey = @implantLogDetailKey		
		EXEC p_EHR_InteractWithVisitImplant @Action, @CenterID, @visitKey, @physicianID,  @DataToBePutToVisitImplant, @Now, @UserID,  @hasNewSourceImplantDetailKey OUTPUT, @newSourceImplantDetailKey OUTPUT

		IF @hasNewSourceImplantDetailKey = 1
		BEGIN
			UPDATE	t_EHR_ImplantLogDetail 
			SET		ImplantKey = @newSourceImplantDetailKey 
			OUTPUT	'U', deleted.*, inserted.* INTO	#t_EHR_ImplantLogDetail_Audit 
			OUTPUT	inserted.* 
			WHERE	ImplantLogDetailKey= @implantLogDetailKey

			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_ImplantLogDetail', NULL, NULL, 'U')
		END		


		--interact with ts081
		DECLARE @DataToBePutToSuppliesUsed	AS st_DataToBePutToSuppliesUsed;
			INSERT @DataToBePutToSuppliesUsed 
			SELECT InvGroup, ItemCode, PrefCardItemKey, ItemDescription, Quantity, UnitOfMeasure, CurrentPrice
			FROM   t_EHR_ImplantLogDetail
			WHERE  ImplantLogDetailKey = @implantLogDetailKey

		DECLARE @DataToMatchSuppliesUsed	AS st_DataToMatchSuppliesUsed;
			INSERT	@DataToMatchSuppliesUsed 
			SELECT	ItemCode, SupplyUsedDetailKey 
			FROM	t_EHR_ImplantLogDetail 
			WHERE	ImplantLogDetailKey = @implantLogDetailKey

		EXEC p_EHR_InteractWithSuppliesUsed @Action, @CenterID, @ChartKey, @WorkflowKey, @ModuleKey,  @DataToBePutToSuppliesUsed, @DataToMatchSuppliesUsed, @Now, @UserID,  @hasNewSourceSupplyUsedDetailKey OUTPUT, @newSourceSupplyUsedDetailKey OUTPUT

		IF @hasNewSourceSupplyUsedDetailKey = 1
		BEGIN
			UPDATE	t_EHR_ImplantLogDetail 
			SET		SupplyUsedDetailKey = @newSourceSupplyUsedDetailKey 
			OUTPUT	'U', deleted.*, inserted.* INTO	#t_EHR_ImplantLogDetail_Audit 
			OUTPUT	inserted.* 
			WHERE	ImplantLogDetailKey= @implantLogDetailKey

			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_ImplantLogDetail', NULL, NULL, 'U')
		END		

		FETCH NEXT FROM audit_cursor INTO @implantLogDetailKey
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
     ,@value = N'Rev Date: 11/13/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_ImplantLogDetail'
GO	
	
	