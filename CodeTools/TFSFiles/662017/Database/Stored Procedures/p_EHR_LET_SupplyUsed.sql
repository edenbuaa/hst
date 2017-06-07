IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_SupplyUsed') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_LET_SupplyUsed;
GO

-- =============================================================================================================
-- Author:			Peter
-- Create date:		02/26/16
-- Description:		confirm and update t_supplyused.				  
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_SupplyUsed
	@Action				CHAR(1)		-- 'T' returns a list of tables that might be affected. 'E' is for execute
	,@CenterID			INT
	,@ChartKey			INT
	,@WorkflowKey		INT
	,@ModuleKey			INT
	,@BundleKey			INT
	,@UIDictionaryKey	INT
	,@Now				SMALLDATETIME
	,@UserID			VARCHAR(60)
WITH ENCRYPTION

AS
	
SET NOCOUNT ON;

BEGIN TRY
	IF @Action = 'T'
	BEGIN
		SELECT	TableName				
				,Operation
		FROM	(
				VALUES 
				('t_EHR_SupplyUsedDetail', 'U')						   				  
				,('t_EHR_SupplyUsed', 'U')	
				
				)
		AS AffectedTableList (TableName, Operation)

		RETURN;
	END
	--for update
	IF @Action ='U'
	BEGIN
		-- !important, we need to update the cost field before comfirm finished.		
		EXEC p_EHR_SyncSupplyUsedWithPathways 'M', @ChartKey, @WorkflowKey, @ModuleKey, @UserID, @Now

		DECLARE @confirmingCount		Int
				,@postToSingleLocation	bit
				,@priVisitServiceKey	int
				,@visitKey				int;

		SELECT	@confirmingCount = COUNT(*)
		FROM	t_EHR_SupplyUsedDetail
		WHERE	SupplyKey IS NULL
		AND		ChartKey = @ChartKey 
		AND		WorkflowKey = @WorkflowKey
		AND		[Status] IN ('A','D');
	
		IF @confirmingCount = 0
			RETURN;	
		
		SELECT	@postToSingleLocation = PostToSingleLocation
		FROM	t_InvConfiguration
		WHERE	CenterID = @CenterID;

		SELECT	@priVisitServiceKey = vs.VisitServiceKey
				,@visitKey = c.VisitKey
		FROM	t_EHR_Chart c
		JOIN	t_VisitService vs
		ON		c.VisitKey = vs.VisitKey
		WHERE	c.ChartKey = @ChartKey
		AND		vs.PrimaryProcedure = 1
		
		CREATE  TABLE #temptb   
		(  
			[id] int identity(1,1),  
			[VisitKey] int,  
			[VisitServiceKey] int,  
			[CenterID] int,  
			[PrefCardItemKey] int,  
			[PrefCardGroup] int,  
			[InvGroup] int,  
		[ItemCode] int, 
			[UOM]	char(12),
			[Quantity] int,
			[OrginalPrice] money,
			[ChangeBy] varchar(60) ,
			[SupplyUsedDetailKey] INT,
			[RevenueCode] char(6),
			[PatientCharge] money,
			[HCPCS] varchar(10),
			[Location] int
		)  

		--autofill temp
		INSERT INTO	#temptb
		(   
			[VisitKey] ,  
			[VisitServiceKey] ,  
			[CenterID] ,  
			[PrefCardItemKey] ,  
			[InvGroup] ,  
			[ItemCode] ,  
			[UOM],
			[Quantity],
			[OrginalPrice],				--convert by currentprice
			[SupplyUsedDetailKey] ,
			[RevenueCode],
			[PatientCharge],				--convert by markup price
			[Location],
			[HCPCS]
		)
		SELECT		@visitKey
					,ISNULL(spt.VisitServiceKey,@priVisitServiceKey)
					,@CenterID
					,dt.PrefCardItemKey
					,dt.InvGroup
					,dt.ItemCode
					,dt.UnitOfMeasure UOM
					,dt.Quantity
					,OrginalPrice	=	CASE 
											WHEN uom.ConvFactor <> 0 
												THEN (dt.Quantity * Round(dt.CurrentPrice * uom.ConvFactor,2))
											WHEN (uom.ConvFactor = 0 and uom.ConvFactorDenominator > 0) 
												THEN (dt.Quantity * Round( dt.CurrentPrice * uom.ConvFactorNumerator / uom.ConvFactorDenominator,2))
											ELSE  
												0.00
										END 
					,dt.SupplyUsedDetailKey
					,im.RevenueCode
					,PatientCharge	=	CASE 
											WHEN uom.ConvFactor <> 0 
												THEN (dt.Quantity * Round(im.MarkUpPrice * uom.ConvFactor,2))
											WHEN uom.ConvFactor = 0 and uom.ConvFactorDenominator > 0
												THEN (dt.Quantity * Round( im.MarkUpPrice * uom.ConvFactorNumerator / uom.ConvFactorDenominator,2))
											ELSE  
												0.00
										END
					,LocationKey	=	CASE	WHEN @postToSingleLocation = 1	THEN NULL	ELSE ppci.ItemLocation	END
					,im.HCPCS
		FROM	t_EHR_SupplyUsedDetail dt			

		LEFT JOIN	t_EHR_ScheduledProcedure spt
		ON		 spt.ScheduledProcedureKey = dt.ScheduledProcedureKey

		LEFT JOIN	t_PhysicianPrefCardItem ppci
		ON			ppci.PrefCardItemKey = dt.PrefCardItemKey

		JOIN		t_ItemMaster im
		ON		   im.InvGroup = dt.InvGroup
		AND		   im.ItemCode = dt.ItemCode

		LEFT JOIN  t_UOM  uom
		ON         uom.InvGroup = dt.InvGroup
		AND		   uom.UOM = dt.UnitOfMeasure

		WHERE	dt.SupplyKey IS NULL
		AND		dt.ChartKey = @ChartKey 
		AND     dt.WorkflowKey = @WorkflowKey
		AND			dt.[Status] IN ('A','D'); 

		IF @postToSingleLocation = 0
		BEGIN
			--fill the location field
			WITH itemLoc
			AS(
				SELECT		il.InvGroup
							,il.ItemCode
							,LocationKey = MIN(il.LocationKey)
				FROM		t_ItemLocation il
				JOIN		#temptb tmp
				ON			il.InvGroup = tmp.InvGroup
				AND			il.ItemCode = tmp.ItemCode
				JOIN		t_InventoryLocation l
				ON			l.LocationKey = il.LocationKey
				WHERE		l.LocationCode <> 'DFLTLoc'
				GROUP BY	il.InvGroup
							,il.ItemCode
			)
			UPDATE	#temptb
			SET		Location = il.LocationKey
			FROM	#temptb tmp
			JOIN	itemLoc il
			ON		tmp.InvGroup = il.InvGroup
			AND		tmp.ItemCode = il.ItemCode
			WHERE	tmp.Location IS NULL
		END;

		--loop the confirming record
		DECLARE		@curr INT = 1;						

		WHILE @curr <= @confirmingCount
		BEGIN
			INSERT INTO t_SupplyUsed 
					(	[VisitKey], 
						[VisitServiceKey], 
						[CenterID], 						
						[PrefCardItemKey], 
						[InvGroup], 
						[ItemCode],
						[UOM],
						[Quantity],
						[OriginalPrice],
						[RevenueCode],
						[PatientCharge],				--convert by markup price
						[HCPCS],
						[Location]
						,CreateBy
						,CreateDate
					)
			SELECT	VisitKey,
					VisitServiceKey, 
					CenterID,
					PrefCardItemKey,
					InvGroup,
					ItemCode,
					UOM,
					(CASE 
						WHEN Quantity IS NULL THEN 0
						ELSE Quantity
					END) as Quantity,
					(CASE 
						WHEN OrginalPrice IS NULL THEN 0
						ELSE OrginalPrice
					END) as OrginalPrice,
					RevenueCode,
					(CASE 
						WHEN PatientCharge IS NULL THEN 0
						ELSE PatientCharge
					END) as PatientCharge,
					HCPCS,
					Location
					,@UserID
					,@Now
			FROM	#temptb 
			WHERE	id = @curr 

			--update t_ehr_supplyusedDetail using the backfill supplykey
			UPDATE t_EHR_SupplyUsedDetail 
			SET SupplyKey = @@IDENTITY
			OUTPUT 'U' ,deleted.*,inserted.*
			INTO  #t_EHR_SupplyUsedDetail_Audit
			OUTPUT	inserted.*
			WHERE SupplyUsedDetailKey
			IN ( SELECT SupplyUsedDetailKey 
					FROM #temptb
					WHERE id = @curr
				)				
			
			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_SupplyUsedDetail', NULL, NULL, 'U')

			-- update flag used by pathways to signal that supplies have been entered
			UPDATE	t_Visit
			SET		SupplyUseEntered = 1
			FROM	t_Visit v
			WHERE	v.VisitKey = @visitKey
			AND		v.SupplyUseEntered = 0

			SELECT @curr = @curr + 1
		END
						
		DROP TABLE #temptb;			


		UPDATE t_EHR_SupplyUsed 
		SET SuppliesConfirmed = 1
		OUTPUT 'U' ,deleted.*,inserted.*
		INTO  #t_EHR_SupplyUsed_Audit
		OUTPUT inserted.*
		WHERE ChartKey = @ChartKey
		AND	  WorkflowKey = @WorkflowKey
		AND   [Status] IN ('A','D');
						
		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_SupplyUsed', NULL, NULL, 'U');

		-- added By Mike: we will give people the choice of automating the task of going to the supplies used form and tapping the button.
		DECLARE @autoProcessSuppliesUsed BIT = 0;

		SELECT	@autoProcessSuppliesUsed = AutoProcessSuppliesUsed
		FROM	t_EHR_CenterConfiguration
		WHERE	CenterID = @centerID;

		IF @autoProcessSuppliesUsed = 1
		BEGIN
			DECLARE	@personKey INT
					,@patientID INT
					,@visitNumber INT
					,@accountingYear SMALLINT
					,@accountingPeriod TINYINT
					,@charUserID CHAR(40);

			SELECT	@personKey = PersonKey
			FROM	t_EHR_Chart 
			WHERE	ChartKey = @ChartKey;

			SELECT	@visitNumber = VisitNumber 
			FROM	t_Visit 
			WHERE	VisitKey = @visitKey;

			SELECT	@patientID = PatientID
			FROM	t_Person 
			WHERE	PersonKey = @personKey;

			SELECT	@accountingPeriod = CurrentPeriod
					,@accountingYear = CurrentPeriodYear
			FROM	t_CenterConfiguration
			WHERE	CenterID = @CenterID;

			SET	@charUserID = CAST(@UserID AS CHAR(40));

			EXEC p_SupplyUsedItems_Transaction	@centerID
												,@patientID
												,@visitNumber
												,@visitKey
												,@accountingYear
												,@accountingPeriod
												,@charUserID
												,@Now
												,0; -- we don't want any resultset coming back
		END


	END -- end action = 'U'

	RETURN
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH;
GO

EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 3/22/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_SupplyUsed'
GO
