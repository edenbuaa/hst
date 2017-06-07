IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_QC_MedicationAdministration') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_QC_MedicationAdministration;
GO

-- =============================================================================================================
-- Author:			Darren Lou
-- Create date:		09/13/2016
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
CREATE PROCEDURE p_EHR_QC_MedicationAdministration
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
	INSERT INTO t_EHR_QC_MedicationAdministrationDetail(  QuickChartKey
										, ModuleTemplateKey
										, ModuleOrder
										, MedicationAdministrationDetailKey
										, MedicationName 
										, MedicationID
										, MedicationIDType
										, RouteKey
										, [Route]
										, AdministeredByID
										, AdministeredByIDType
										, AdministeredByName
										, BodySiteKey
										, BodySite)
	SELECT	@quickChartKey
			, @ModuleTemplateKey
			, 1
			, MedicationAdministrationDetailKey
			, MedicationName 
			, MedicationID
			, MedicationIDType
			, RouteKey
			, [Route]
			, AdministeredByID
			, AdministeredByIDType
			, AdministeredByName
			, BodySiteKey
			, BodySite
	FROM	t_EHR_MedicationAdministrationDetail
	WHERE	[ChartKey] = @chartKey 
	AND     [ModuleKey] = @moduleKey
	AND     OrderMedicationKey IS NOT NULL
	AND     ProphylacticAntibiotic = 0
	AND		[Status] = 'A' 	

END--'C' action

IF @action = 'A'
BEGIN
	--step 1. update target data table
	--for grid, delete the target data before we inserted data

	DECLARE @deletedMADetailKey INT
	DECLARE delete_data_cursor CURSOR LOCAL FOR
	SELECT  MedicationAdministrationDetailKey 
	FROM    t_EHR_MedicationAdministrationDetail 
	WHERE   [ChartKey] = @chartKey 
	AND     [ModuleKey] = @moduleKey
	AND		[Status] = 'A' 	

	OPEN delete_data_cursor
	FETCH NEXT FROM delete_data_cursor INTO @deletedMADetailKey
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE	t_EHR_MedicationAdministrationDetail 
		SET		[Status]='I'
				, DeactivateDate = @Now
				, DeactivateBy = @UserID 
				OUTPUT 'D', deleted.*, inserted.* 
				INTO	#t_EHR_MedicationAdministrationDetail_Audit 	
				OUTPUT inserted.* 
		WHERE	MedicationAdministrationDetailKey = @deletedMADetailKey

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 't_EHR_MedicationAdministrationDetail', NULL, NULL, 'U')

		FETCH NEXT FROM delete_data_cursor INTO @deletedMADetailKey
	END
	CLOSE delete_data_cursor
	DEALLOCATE delete_data_cursor
	
	--for grid with trigger
	--we insert data from qc table in a loop scope
	DECLARE @mADetailKey	INT	
	DECLARE insert_data_cursor CURSOR LOCAL FOR 
	SELECT	MedicationAdministrationDetailKey 
	FROM	t_EHR_QC_MedicationAdministrationDetail 
	WHERE	QuickChartKey = @quickChartKey 
	AND		ModuleTemplateKey = @ModuleTemplateKey

    OPEN insert_data_cursor 
    FETCH NEXT FROM insert_data_cursor INTO  @mADetailKey
    WHILE @@FETCH_STATUS = 0 
    BEGIN 
	 --
		 INSERT INTO t_EHR_MedicationAdministrationDetail(ChartKey
										, WorkflowKey
										, ModuleKey
										, MedicationName 
										, MedicationID
										, MedicationIDType
										, RouteKey
										, [Route]
										, AdministeredByID
										, AdministeredByIDType
										, AdministeredByName
										, BodySiteKey
										, BodySite
										, CreateDate
										, CreateBy) 
		OUTPUT 'I', inserted.*, inserted.*  
		INTO	#t_EHR_MedicationAdministrationDetail_Audit 		 
		OUTPUT  inserted.*
		SELECT	@ChartKey
				, @workflowKey
				, @moduleKey
				, MedicationName 
				, MedicationID	
				, MedicationIDType
				, RouteKey
				, [Route]
				, AdministeredByID
				, AdministeredByIDType
				, AdministeredByName
				, BodySiteKey
				, BodySite
				, @Now
				, @UserID 
		FROM	t_EHR_QC_MedicationAdministrationDetail 
		WHERE	QuickChartKey=@quickChartKey		
		AND		ModuleTemplateKey=@ModuleTemplateKey
		AND		MedicationAdministrationDetailKey = @mADetailKey	
		

		INSERT INTO #UpdateLog 
		VALUES (@ModuleKey, @WorkflowKey, 't_EHR_MedicationAdministrationDetail', NULL, NULL, 'I')
		--exec lET trigger as you want

	    EXEC p_EHR_LET_MedicationAdministrationDetail 'I', @centerID, @chartKey, @workflowKey, @moduleKey, @bundleKey, null, @now, @userID
	
		FETCH NEXT FROM insert_data_cursor INTO  @mADetailKey
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
     ,@value = N'Rev Date: 09/13/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_QC_MedicationAdministration'
GO