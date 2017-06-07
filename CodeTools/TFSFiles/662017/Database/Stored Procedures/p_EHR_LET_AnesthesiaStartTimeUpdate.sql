IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_AnesthesiaStartTimeUpdate') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_AnesthesiaStartTimeUpdate
GO
-- =============================================================================================================
-- Author:			Darren
-- Create date:		12/05/16
-- Description:		
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_AnesthesiaStartTimeUpdate
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
		--EXEC p_EHR_LET_StaffDetail @Action, @CenterID, @ChartKey, @WorkflowKey, @ModuleKey, @BundleKey, @UIDictionaryKey, @Now, @UserID
		EXEC p_EHR_LET_RoomTime @Action, @CenterID, @ChartKey, @WorkflowKey, @ModuleKey, @BundleKey, @UIDictionaryKey, @Now, @UserID
		RETURN;
	END
	--DECLARE @isPhysician BIT
	--DECLARE @isAnesthesiologist BIT
	--DECLARE @isCRNA BIT
	--DECLARE @visitKey INT
	--DECLARE @physicianID INT
	DECLARE @anesthesiaStartTime DATETIME
	--DECLARE @staffModuleKeyInCurrentWF INT
	--DECLARE @existsCurrentUserInStaffDetail BIT = 0
	--DECLARE @staffDetailKeyForCurrentUser INT
	--DECLARE @staffID INT
	--DECLARE @staffIDType CHAR(1)
	--DECLARE @staffName VARCHAR(140)
	--DECLARE @physicianRole TINYINT
	--DECLARE @physicianRoleToBeUsed TINYINT
	DECLARE @needToBackFillRoomInTime BIT = 1
	DECLARE @intraOpWFKey INT
	DECLARE @roomInModuleKey INT
	DECLARE @roomTime SMALLDATETIME
	DECLARE @lateStart				BIT
	DECLARE @enableLateStart		BIT
	DECLARE @RCNT INT;


	SELECT @anesthesiaStartTime = new_EventTime
	FROM #t_EHR_EventTime_Audit

	--back fill to ts011 time Start--
	SELECT @needToBackFillRoomInTime = NeedAnesStartTimeBackFillIntraOpRoomInTime
	FROM  t_EHR_CenterConfiguration
	WHERE CenterID = @CenterID

	IF @needToBackFillRoomInTime = 1 AND @anesthesiaStartTime IS NOT NULL
	BEGIN
		SELECT TOP 1 @intraOpWFKey = wf.WorkflowKey
		, @roomInModuleKey = mdl.ModuleKey
		FROM t_EHR_Workflow wf
		JOIN t_EHR_Area area
		ON wf.AreaKey = area.AreaKey
		AND area.AreaName = 'Intra-Op'
		AND wf.ChartKey = @ChartKey
		AND wf.Status = 'A'
		JOIN t_EHR_Module mdl
		ON wf.WorkflowKey = mdl.WorkflowKey
		And mdl.Status = 'A'
		JOIN t_EHR_ModuleTemplate mdlt
		ON mdl.ModuleTemplateKey = mdlt.ModuleTemplateKey
		AND mdlt.ModuleDesignID = '011'
		ORDER BY wf.WorkflowOrder

		IF EXISTS (SELECT 1 FROM t_EHR_RoomTime WHERE ModuleKey = @roomInModuleKey AND Status = 'A' AND RoomTime IS NULL)
		BEGIN
			SET @enableLateStart = dbo.f_EHR_EnableLateStart(@ChartKey, @intraOpWFKey, @roomInModuleKey)

			UPDATE t_EHR_RoomTime 
			SET RoomTime = @anesthesiaStartTime
			,LateStart = CASE @enableLateStart 
										WHEN 1 THEN dbo.f_EHR_IsLateStart(@ChartKey, @intraOpWFKey, @roomInModuleKey, @anesthesiaStartTime)
										ELSE LateStart
									 END
			, ChangeDate = @Now
			, ChangeBy = @UserID 
			OUTPUT 'U', deleted.*, inserted.* 
			INTO #t_EHR_RoomTime_Audit 
			OUTPUT inserted.*
			WHERE ModuleKey = @roomInModuleKey AND Status = 'A'

			SET @RCNT = @@ROWCOUNT;
			INSERT INTO #UpdateLog VALUES (@roomInModuleKey, @intraOpWFKey, 't_EHR_RoomTime', NULL, NULL, 'U')

			IF @RCNT > 0
			BEGIN
				EXEC p_EHR_LET_RoomTime 'U', @CenterID, @ChartKey, @intraOpWFKey, @roomInModuleKey, @BundleKey, @UIDictionaryKey, @Now, @UserID
			END
		END
	END
	--back fill to ts011 time End--

END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH
GO
EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 12/05/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_AnesthesiaStartTimeUpdate'
GO	
	
	