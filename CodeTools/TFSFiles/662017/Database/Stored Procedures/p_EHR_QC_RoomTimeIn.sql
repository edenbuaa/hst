IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_QC_RoomTimeIn') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_QC_RoomTimeIn;
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
--					WorkstationTime:		Timestamp taken on user's device, not necessarily trustworthy,
--											so we double-store it for auditing purposes with the server date/time
--
--					UserID:					User ID of responsible user 

-- =============================================================================================================
CREATE PROCEDURE p_EHR_QC_RoomTimeIn
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
	
	INSERT INTO t_EHR_QC_RoomTime ( QuickChartKey
									, ModuleTemplateKey
									, ModuleOrder
									, Location
									, TransportType
									, StaffIDType
									, StaffID
									, StaffName
									, ModuleKey)
	SELECT @quickChartKey
			, md.ModuleTemplateKey
			, 1
			, Location
			, TransportType
			, StaffIDType
			, StaffID
			, StaffName
			, rt.ModuleKey 
	FROM	t_EHR_RoomTime rt
	JOIN	t_EHR_Module md
	ON		rt.ModuleKey = md.ModuleKey
	WHERE	rt.ModuleKey = @ModuleKey
END--'C' action

IF @action = 'A'
BEGIN
	--step 1. update target data table
	UPDATE	t_EHR_RoomTime 
	SET		[Location] = t1.[Location]
			, [TransportType] = t1.[TransportType]
			, [StaffIDType] = t1.[StaffIDType]
			, [StaffID] = t1.[StaffID]
			, [StaffName] = t1.[StaffName]
			, ChangeDate = @Now
			, ChangeBy = @UserID 
	OUTPUT 'U', deleted.*, inserted.* 
	INTO #t_EHR_RoomTime_Audit  
	OUTPUT inserted.* 	
	FROM		t_EHR_RoomTime t
	CROSS JOIN	t_EHR_QC_RoomTime t1 
	WHERE		t1.QuickChartKey=@quickChartKey 
	AND			t1.ModuleTemplateKey=@ModuleTemplateKey 
	AND			t.[ChartKey] = @ChartKey 
	AND			t.[Status] = 'A' 
	AND			t.[WorkflowKey] = @WorkflowKey 
	AND			t.[ModuleKey] = @ModuleKey

	INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_RoomTime', NULL, NULL, 'U')
	
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
     ,@value = N'Rev Date: 5/9/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_QC_RoomTimeIn'
GO