IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_InitialAnesthesiaProviderIDUpdate') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_InitialAnesthesiaProviderIDUpdate
GO
-- =============================================================================================================
-- Author:			Darren
-- Create date:		01/19/17
-- Description:		
-- Edit date:		02/17/17 by Susan
-- Changed:			Also need an EmployeeType as PhysicianRole when inserting record to t_EHR_StaffDetail
--					because 030 flyout use EmployeeType field to bound the 'staff role' combo box
--					And fix a bug regarding staff deletion
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_InitialAnesthesiaProviderIDUpdate
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
		EXEC p_EHR_LET_StaffDetail @Action, @CenterID, @ChartKey, @WorkflowKey, @ModuleKey, @BundleKey, @UIDictionaryKey, @Now, @UserID
		RETURN;
	END

	DECLARE @anesthesiaStartTime DATETIME
	DECLARE @staffModuleKeyInCurrentWF INT
	DECLARE @existsCurrentUserInStaffDetail BIT = 0
	DECLARE @staffDetailKeyForCurrentUser INT
	DECLARE @physicianRole TINYINT
	DECLARE @physicianRoleToBeUsed TINYINT
	DECLARE @oldInitialAnesthesiaProviderID INT
	DECLARE @oldInitialAnesthesiaProviderIDType CHAR(1)
	DECLARE @oldInitialAnesthesiaProviderName VARCHAR(140)
	DECLARE @newInitialAnesthesiaProviderID INT
	DECLARE @newInitialAnesthesiaProviderIDType CHAR(1)
	DECLARE @newInitialAnesthesiaProviderName VARCHAR(140)
	DECLARE @addInitialAnesthesiaProvider BIT = 0 --input InitialAnesthesiaProvider from empty
	DECLARE @updateInitialAnesthesiaProvider BIT = 0--change InitialAnesthesiaProvider from one to another
	DECLARE @deleteInitialAnesthesiaProvider BIT = 0--clear InitialAnesthesiaProvider
	DECLARE @oldPhysicianRoleToBeUsed TINYINT
	DECLARE @newPhysicianRoleToBeUsed TINYINT
	DECLARE @staffDetailKeyForOldInitialAnesthesiaProvider INT
	DECLARE @staffDetailKeyForNewInitialAnesthesiaProvider INT
	DECLARE @oldInitialAnesthesiaProviderExistsInStaffDetail BIT = 0
	DECLARE @newInitialAnesthesiaProviderExistsInStaffDetail BIT = 0
	DECLARE @RCNT INT;

	SELECT @staffModuleKeyInCurrentWF = m.ModuleKey
	FROM t_EHR_Module m
	JOIN t_EHR_ModuleTemplate mt
	ON m.ModuleTemplateKey = mt.ModuleTemplateKey
	AND mt.CenterID = @CenterID
	AND m.ChartKey = @ChartKey
	AND m.WorkflowKey = @WorkflowKey
	AND mt.ModuleDesignID = '030'
	AND m.Status = 'A'

	IF @staffModuleKeyInCurrentWF IS NULL
		RETURN;

	SELECT @BundleKey = BundleKey FROM t_EHR_Workflow WHERE WorkflowKey = @WorkflowKey

	SELECT @anesthesiaStartTime = EventTime
	FROM   t_EHR_EventTime et
	JOIN   t_EHR_ModuleTemplate mt
	ON     et.ModuleTemplateKey = mt.ModuleTemplateKey
	AND    et.ChartKey = @ChartKey
	AND    et.Status = 'A'
	AND    mt.ModuleDesignID = '085'
	AND    et.BundleKey = @BundleKey

	SELECT @oldInitialAnesthesiaProviderID = old_InitialAnesthesiaProviderID
	,@oldInitialAnesthesiaProviderIDType = old_InitialAnesthesiaProviderIDType
	,@oldInitialAnesthesiaProviderName = old_InitialAnesthesiaProviderName
	,@newInitialAnesthesiaProviderID = new_InitialAnesthesiaProviderID
	,@newInitialAnesthesiaProviderIDType = new_InitialAnesthesiaProviderIDType
	,@newInitialAnesthesiaProviderName = new_InitialAnesthesiaProviderName
	FROM #t_EHR_Anesthesia_Audit

	IF @oldInitialAnesthesiaProviderID IS NOT NULL
	BEGIN
		SELECT @oldPhysicianRoleToBeUsed = DefaultRole
		FROM v_EHR_Physician
		WHERE PhysicianID = @oldInitialAnesthesiaProviderID
		AND   CenterID = @CenterID

		SELECT @staffDetailKeyForOldInitialAnesthesiaProvider = StaffDetailKey
		FROM t_EHR_StaffDetail
		WHERE WorkflowKey = @WorkflowKey
		AND WorkflowKey = @WorkflowKey
		AND ModuleKey = @staffModuleKeyInCurrentWF
		AND StaffID = @oldInitialAnesthesiaProviderID
		AND StaffIDType = @oldInitialAnesthesiaProviderIDType
		AND StaffName = @oldInitialAnesthesiaProviderName
		AND PhysicianRole = @oldPhysicianRoleToBeUsed
		AND @oldPhysicianRoleToBeUsed IN (3, 5)--Anesthesiologist, CRNA
		AND Status = 'A'

		IF @staffDetailKeyForOldInitialAnesthesiaProvider IS NOT NULL
			SET @oldInitialAnesthesiaProviderExistsInStaffDetail = 1
	END
	

	IF @newInitialAnesthesiaProviderID IS NOT NULL
	BEGIN
		SELECT @newPhysicianRoleToBeUsed = DefaultRole
		FROM v_EHR_Physician
		WHERE PhysicianID = @newInitialAnesthesiaProviderID
		AND   CenterID = @CenterID

		SELECT @staffDetailKeyForNewInitialAnesthesiaProvider = StaffDetailKey
		FROM t_EHR_StaffDetail
		WHERE WorkflowKey = @WorkflowKey
		AND WorkflowKey = @WorkflowKey
		AND ModuleKey = @staffModuleKeyInCurrentWF
		AND StaffID = @newInitialAnesthesiaProviderID
		AND StaffIDType = @newInitialAnesthesiaProviderIDType
		AND StaffName = @newInitialAnesthesiaProviderName
		AND PhysicianRole = @newPhysicianRoleToBeUsed
		AND @newPhysicianRoleToBeUsed IN (3, 5)--Anesthesiologist, CRNA
		AND Status = 'A'

		IF @staffDetailKeyForNewInitialAnesthesiaProvider IS NOT NULL
			SET @newInitialAnesthesiaProviderExistsInStaffDetail = 1
	END

	IF @oldInitialAnesthesiaProviderID IS NULL AND @newInitialAnesthesiaProviderID IS NOT NULL
		SET @addInitialAnesthesiaProvider = 1
		
	ELSE IF @oldInitialAnesthesiaProviderID IS NOT NULL AND @newInitialAnesthesiaProviderID IS NOT NULL
		SET @updateInitialAnesthesiaProvider = 1

	ELSE IF @oldInitialAnesthesiaProviderID IS NOT NULL AND @newInitialAnesthesiaProviderID IS NULL
		SET @deleteInitialAnesthesiaProvider = 1

	IF @addInitialAnesthesiaProvider = 1
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM v_EHR_Physician WHERE PhysicianID = @newInitialAnesthesiaProviderID AND CenterID = @CenterID)
			RETURN;

		IF @newInitialAnesthesiaProviderExistsInStaffDetail = 0
		BEGIN
			INSERT t_EHR_StaffDetail (ChartKey, WorkflowKey, ModuleKey, StaffID, StaffIDType, StaffName, PhysicianRole, EmployeeType, InTime, CreateDate, CreateBy)
			OUTPUT 'I', inserted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			VALUES (@ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @newInitialAnesthesiaProviderID, @newInitialAnesthesiaProviderIDType, @newInitialAnesthesiaProviderName, @newPhysicianRoleToBeUsed, @newPhysicianRoleToBeUsed, @anesthesiaStartTime, @Now, @UserID)

			SET @RCNT = @@ROWCOUNT;
			INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'I')

			IF @RCNT > 0
			BEGIN
				EXEC p_EHR_LET_StaffDetail 'I', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
			END
		END
	END

	ELSE IF @updateInitialAnesthesiaProvider = 1
	BEGIN
		IF @oldInitialAnesthesiaProviderExistsInStaffDetail = 1 AND @newInitialAnesthesiaProviderExistsInStaffDetail = 0
		BEGIN
			UPDATE t_EHR_StaffDetail 
			SET		StaffID = @newInitialAnesthesiaProviderID, 
					StaffIDType = @newInitialAnesthesiaProviderIDType, 
					StaffName = @newInitialAnesthesiaProviderName, 
					PhysicianRole = @newPhysicianRoleToBeUsed, 
					EmployeeType = @newPhysicianRoleToBeUsed,
					ChangeDate = @Now, 
					ChangeBy = @UserID
			OUTPUT 'U', deleted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			WHERE StaffDetailKey = @staffDetailKeyForOldInitialAnesthesiaProvider

			SET @RCNT = @@ROWCOUNT;
			INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'U')

			IF @RCNT > 0
			BEGIN
				EXEC p_EHR_LET_StaffDetail 'U', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
			END

			RETURN
		END
		IF @oldInitialAnesthesiaProviderExistsInStaffDetail = 1
		BEGIN
			UPDATE t_EHR_StaffDetail 
			SET		Status = 'I', 
					--ChangeDate = @Now, ChangeBy = @UserID, 
					DeactivateDate = @Now, DeactivateBy = @UserID 
			OUTPUT 'D', deleted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			WHERE StaffDetailKey = @staffDetailKeyForOldInitialAnesthesiaProvider

			SET @RCNT = @@ROWCOUNT;
			INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'U')

			IF @RCNT > 0
			BEGIN
				EXEC p_EHR_LET_StaffDetail 'D', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
			END
		END

		IF NOT EXISTS(SELECT 1 FROM v_EHR_Physician WHERE PhysicianID = @newInitialAnesthesiaProviderID AND CenterID = @CenterID)
			RETURN;

		IF @newInitialAnesthesiaProviderExistsInStaffDetail = 0
		BEGIN
			INSERT t_EHR_StaffDetail (ChartKey, WorkflowKey, ModuleKey, StaffID, StaffIDType, StaffName, PhysicianRole, EmployeeType, InTime, CreateDate, CreateBy)
			OUTPUT 'I', inserted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			VALUES (@ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @newInitialAnesthesiaProviderID, @newInitialAnesthesiaProviderIDType, @newInitialAnesthesiaProviderName, @newPhysicianRoleToBeUsed, @newPhysicianRoleToBeUsed, @anesthesiaStartTime, @Now, @UserID)

			SET @RCNT = @@ROWCOUNT;

			INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'I')
			IF @RCNT > 0
			BEGIN
				EXEC p_EHR_LET_StaffDetail 'I', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
			END
		END
	END

	ELSE IF @deleteInitialAnesthesiaProvider = 1
	BEGIN
		IF @oldInitialAnesthesiaProviderExistsInStaffDetail = 1
		BEGIN
			UPDATE t_EHR_StaffDetail 
			SET		Status = 'I', 
					--ChangeDate = @Now, ChangeBy = @UserID, 
					DeactivateDate = @Now, DeactivateBy = @UserID 
			OUTPUT 'D', deleted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			WHERE StaffDetailKey = @staffDetailKeyForOldInitialAnesthesiaProvider

			IF @@ROWCOUNT > 0
			BEGIN
				INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'U')
				EXEC p_EHR_LET_StaffDetail 'D', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
			END
		END
	END

END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH
GO
EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 02/17/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_InitialAnesthesiaProviderIDUpdate'
GO	
	
	