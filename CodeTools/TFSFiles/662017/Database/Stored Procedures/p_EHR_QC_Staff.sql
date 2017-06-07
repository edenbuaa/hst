IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_QC_Staff') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_QC_Staff;
GO

-- =============================================================================================================
-- Author:			Peter fan
-- Create date:		07/27/2016
-- Description:		create or apply the quick chart by manual model
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
-- Edit date:		3/13/17 by Susan Su
-- Changed:			1. Add @action='T' section to tell framework this QC proc will attach exteral tables
--					2. Fix mantis #1044, need to call LET proc when deletion and inserting
-- =============================================================================================================
CREATE PROCEDURE p_EHR_QC_Staff
	 @action			varchar(1)
	,@chartKey			INT
	,@workflowKey	    int			
	,@centerID			INT
	,@moduleKey			INT
	,@quickChartKey		INT			--used by 'C' or 'A'	
	,@now				DATETIME
	,@userID			VARCHAR(60)
WITH ENCRYPTION

AS
	
BEGIN
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

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
IF @action = 'T'
BEGIN
	SELECT	TableName
			,ExternalTable -- to indicate if the table is external 
	FROM	(
			VALUES	('t_VisitParticipant',1)
					,('t_VisitPhysician',1)
			)
	AS ExternalTableList (TableName,ExternalTable)
	RETURN;
END

IF @action = 'C'
BEGIN
	
	--fill data to qc from the current valid data
	INSERT INTO t_EHR_QC_StaffDetail (  QuickChartKey
										, ModuleTemplateKey
										, ModuleOrder
										, StaffIDType
										, StaffID
										, StaffName
										, EmployeeType
										, PhysicianRole
										--, Notes	-- not quickchartable
										, UseRoomIn
										, StaffDetailKey)
	SELECT	@quickChartKey
			, @ModuleTemplateKey
			, 1
			, StaffIDType
			, StaffID
			, StaffName
			, EmployeeType
			, PhysicianRole
			, UseRoomIn
			, StaffDetailKey 
	FROM	t_EHR_StaffDetail
	WHERE	[ChartKey] = @ChartKey 
	AND		[Status] = 'A' 
	AND		[WorkflowKey] = @WorkflowKey 
	AND		[ModuleKey] = @ModuleKey
	ORDER BY StaffDetailKey

END--'C' action

IF @action = 'A'
BEGIN
	--step 1. update target data table
	--for grid, delete the target data before we inserted data
	UPDATE	t_EHR_StaffDetail 
	SET		[Status]='I'
			, DeactivateDate = @Now
			, DeactivateBy = @UserID 
			OUTPUT 'D', deleted.*, inserted.* 
			INTO #t_EHR_StaffDetail_Audit 
			OUTPUT inserted.* 
	WHERE	[ChartKey] = @ChartKey 
	AND		[Status] = 'A' 
	AND		[WorkflowKey] = @WorkflowKey 
	AND		[ModuleKey] = @ModuleKey
	INSERT INTO #UpdateLog 
	VALUES (@ModuleKey, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'U')

	--re-insert the data from qc
	-- if there not LET trigger to exec , we insert a batch.
	INSERT INTO t_EHR_StaffDetail ( StaffIDType
									, StaffID
									, StaffName
									, EmployeeType
									, PhysicianRole
									, UseRoomIn
									, ChartKey
									, Status
									, WorkflowKey
									, ModuleKey
									, CreateDate
									, CreateBy) 
	OUTPUT 'I', inserted.*, inserted.*  
	INTO	#t_EHR_StaffDetail_Audit 
	OUTPUT	inserted.* 
	SELECT	StaffIDType
			, StaffID
			, StaffName
			, EmployeeType
			, PhysicianRole
			, UseRoomIn
			, @ChartKey
			, 'A'
			, @WorkflowKey
			, @ModuleKey
			, @Now
			, @UserID 
	FROM	t_EHR_QC_StaffDetail 
	WHERE	QuickChartKey=@quickChartKey		--be cautious of the quickchartkey is  @applyQuickChartKey
	AND		ModuleTemplateKey=@ModuleTemplateKey	
	INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_StaffDetail', NULL, 't_EHR_StaffDetail', 'I')

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
     ,@value = N'Rev Date: 3/13/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_QC_Staff'
GO