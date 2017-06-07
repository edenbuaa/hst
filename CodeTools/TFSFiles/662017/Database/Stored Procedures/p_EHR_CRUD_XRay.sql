IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_XRay') AND TYPE in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_XRay;
GO

-- =============================================================================================================
-- Author:			Andy
-- Create date:		10/09/15
-- Description:		Creates/Reads/Deactivates data row for the XRay module
--				  
-- Parameters		action:					'T' -> Return list of tables that this proc returns
--
--											'C' -> Create a new record
--
--											'R' -> Reads the moudle data into result set. This can return more 
--													than one table.
--
--											'D' -> Deactivates specified row
--
--					chartKey:				Chart containing this module
--
--					workflowKey:			Workflow containing this module
--
--					moduleKey:				Reference to the instance of the module
--											 that this data backs
--
--					userID:					User ID of responsible user 
--
--					actionDate:				Date row was touched
-- =============================================================================================================
CREATE PROCEDURE p_EHR_CRUD_XRay
	 @action			CHAR(1)
	,@centerID			INT
	,@chartKey			INT
	,@workflowKey		INT
	,@moduleKey			INT
	,@userID			VARCHAR(60)
	,@actionDate		SMALLDATETIME
WITH ENCRYPTION

AS
	
SET NOCOUNT ON;						

BEGIN TRY			
	IF @action = 'T'
	
		SELECT	*
		FROM(VALUES
			('t_ItemEquipment',					NULL, 0)
			,('t_EHR_XRayDetail',				NULL, 0)
			,('t_EHR_XRay',						NULL, 1)
			,('t_EHR_BodySite',					'LeftOrRightBodySite', 0))
		AS	temp (TableName, ResultName, SingleRow)

	-- Create a new row for this module
	ELSE IF @action = 'C'
		BEGIN
			--IF NOT EXISTS(SELECT 1 FROM t_EHR_XRay WHERE ChartKey = @chartkey AND [Status] = 'A')	
				INSERT t_EHR_XRay (ChartKey, WorkflowKey, ModuleKey, CreateBy, CreateDate)
				VALUES (@chartKey, @workflowKey, @moduleKey, @userID, @actionDate)

			INSERT t_EHR_XRayDetail(ChartKey, WorkflowKey, ModuleKey, InvGroup, ItemCode, EquipmentType, CreateBy, CreateDate,IdentificationNumber,ItemEquipKey,SerialNumber)
            	SELECT DISTINCT @chartKey
								, @workflowKey
								, @moduleKey
								, im.InvGroup
								, im.ItemCode
									,CASE
										WHEN ISNULL(im.PrefCardDesc, '')  <> '' THEN im.PrefCardDesc
										WHEN ISNULL(im.[Description], '') <> '' THEN im.[Description]
										ELSE ''
									 END ,
								  @userID,
								  @actionDate, 
						case when count(ie.IdentificationNumber) over(PARTITION BY im.invGroup,im.itemCode)>1 then '' else ie.IdentificationNumber end IdentificationNumber,
						case when count(ie.ItemEquipKey) over(PARTITION BY im.invGroup,im.itemCode)>1 then null else ie.ItemEquipKey end ItemEquipKey,
						case when count(ie.SerialNumber) over(PARTITION BY im.invGroup,im.itemCode)>1 then '' else ie.SerialNumber end SerialNumber
				FROM	f_EHR_MergePrefCard_Equipment(196,1646, 1) feq
				JOIN	t_ItemMaster im
				ON		im.InvGroup = feq.InvGroup
				AND		im.ItemCode = feq.ItemCode
				left join t_ItemEquipment ie
				ON		ie.InvGroup = feq.InvGroup
				AND		ie.ItemCode = feq.ItemCode
				WHERE	feq.EHREquipmentCategoryKey = 6		-- 'X-Ray'

		END
	ELSE IF @action = 'R' OR @action = 'A'
		BEGIN
			SELECT DISTINCT ie.ItemEquipKey,ie.InvGroup,ie.ItemCode
				   ,ie.IdentificationNumber, ie.SerialNumber
			FROM	t_ItemEquipment ie INNER JOIN t_ItemMaster im ON ie.InvGroup = im.InvGroup AND ie.ItemCode = im.ItemCode
					INNER JOIN t_InvConfiguration ic ON ie.InvGroup = ic.InvGroup
					INNER JOIN t_EHR_EquipmentCategory ec ON im.EHREquipmentCategoryKey = ec.EHREquipmentCategoryKey
			WHERE	ec.EHREquipmentCategoryName = 'X-Ray'
			AND		ic.CenterID = @centerID 
			AND		IdentificationNumber IS NOT NULL

			SELECT *
			FROM [dbo].[t_EHR_XRayDetail]
			WHERE	ModuleKey = @moduleKey 
			AND		((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))

			SELECT	*				
			FROM	t_EHR_XRay 
			WHERE	ModuleKey = @moduleKey 
			AND		((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))

			SELECT CenterID, BodySite, BodySiteKey
			FROM   t_EHR_BodySite
			WHERE  CenterID = @centerID
			AND    BodySide in ('L', 'R', 'N', 'B')
			AND    Status = 'A'
		END
	ELSE IF @action = 'V'
	BEGIN
		IF dbo.f_EHR_IsModuleNA(@moduleKey) = 1
			RETURN

		DECLARE @PrecautionsObserved BIT
		
		SELECT	@PrecautionsObserved = PrecautionsObserved 
		FROM	t_EHR_XRay 
		WHERE	ChartKey = @chartKey 
		AND		WorkflowKey = @workflowKey 
		AND		ModuleKey = @moduleKey 
		AND		[Status] = 'A'
		
		IF @PrecautionsObserved = 0 
			EXEC p_EHR_Incomplete @moduleKey, 'PrecautionsObserved', 'Must check ''X-ray precautions observed per policy '' '

		IF NOT EXISTS(	SELECT  *
						FROM	t_EHR_XRayDetail
						WHERE	ChartKey  = @chartKey
						AND		WorkflowKey = @workflowKey
						AND		ModuleKey = @moduleKey
						AND		[Status] = 'A')
			EXEC p_EHR_Incomplete @moduleKey, 't_EHR_XRayDetail', 'Must have at least one X-ray record'

		IF EXISTS(SELECT * FROM t_EHR_XRayDetail 
		WHERE (ExposureTime IS NULL OR ExposureTime = '') 
		AND ModuleKey = @moduleKey 
		AND [Status]='A')
			EXEC p_EHR_Incomplete @moduleKey, 'ExposureTime', 'Must enter Exposure Time for the X-ray data'

	END
	ELSE IF @action = 'D'
		BEGIN
			-- this data is Chart Scoped.  It is non-grid. The clustered index is on ChartKey + Status.
			-- SUBSTRING(CONVERT(VARCHAR(5),[ExposureTime]),0,6) AS ExposureTime
			-- Because data for this module is not in a grid, there is no UI that will allow someone to deactivate 
			--  the record. So this code will never be used.  But does no harm to leave code here.
			--
			-- If we were to deactivate a record, we could query by the clustered index for maximum efficiency.
			UPDATE	t_EHR_XRay 
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			FROM	t_EHR_XRay 
			WHERE	ModuleKey = @moduleKey 
			AND		Status IN ('A','D')

			UPDATE	t_EHR_XRayDetail 
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			FROM	t_EHR_XRayDetail 
			WHERE	ModuleKey = @moduleKey 
			AND		Status IN ('A','D')
	    END	
	RETURN
END TRY
BEGIN CATCH

	EXEC p_RethrowError;

	RETURN -1;
END CATCH;

GO

EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 3/29/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_XRay'
GO