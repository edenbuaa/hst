IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_FinalAnesthesiaProviderIDUpdate') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_FinalAnesthesiaProviderIDUpdate
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
CREATE PROCEDURE p_EHR_LET_FinalAnesthesiaProviderIDUpdate
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

	DECLARE @anesthesiaStopTime DATETIME
	DECLARE @staffModuleKeyInCurrentWF INT
	DECLARE @existsCurrentUserInStaffDetail BIT = 0
	DECLARE @staffDetailKeyForCurrentUser INT
	DECLARE @physicianRole TINYINT
	DECLARE @physicianRoleToBeUsed TINYINT
	DECLARE @oldFinalAnesthesiaProviderID INT
	DECLARE @oldFinalAnesthesiaProviderIDType CHAR(1)
	DECLARE @oldFinalAnesthesiaProviderName VARCHAR(140)
	DECLARE @newFinalAnesthesiaProviderID INT
	DECLARE @newFinalAnesthesiaProviderIDType CHAR(1)
	DECLARE @newFinalAnesthesiaProviderName VARCHAR(140)
	DECLARE @addFinalAnesthesiaProvider BIT = 0 --input FinalAnesthesiaProvider from empty
	DECLARE @updateFinalAnesthesiaProvider BIT = 0--change FinalAnesthesiaProvider from one to another
	DECLARE @deleteFinalAnesthesiaProvider BIT = 0--clear FinalAnesthesiaProvider
	DECLARE @oldPhysicianRoleToBeUsed TINYINT
	DECLARE @newPhysicianRoleToBeUsed TINYINT
	DECLARE @staffDetailKeyForOldFinalAnesthesiaProvider INT
	DECLARE @staffDetailKeyForNewFinalAnesthesiaProvider INT
	DECLARE @oldFinalAnesthesiaProviderExistsInStaffDetail BIT = 0
	DECLARE @newFinalAnesthesiaProviderExistsInStaffDetail BIT = 0

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

	SELECT @anesthesiaStopTime = EventTime
	FROM   t_EHR_EventTime et
	JOIN   t_EHR_ModuleTemplate mt
	ON     et.ModuleTemplateKey = mt.ModuleTemplateKey
	AND    et.ChartKey = @ChartKey
	AND    et.Status = 'A'
	AND    mt.ModuleDesignID = '086'
	AND    et.BundleKey = @BundleKey

	SELECT @oldFinalAnesthesiaProviderID = old_FinalAnesthesiaProviderID
	,@oldFinalAnesthesiaProviderIDType = old_FinalAnesthesiaProviderIDType
	,@oldFinalAnesthesiaProviderName = old_FinalAnesthesiaProviderName
	,@newFinalAnesthesiaProviderID = new_FinalAnesthesiaProviderID
	,@newFinalAnesthesiaProviderIDType = new_FinalAnesthesiaProviderIDType
	,@newFinalAnesthesiaProviderName = new_FinalAnesthesiaProviderName
	FROM #t_EHR_Anesthesia_Audit

	IF @oldFinalAnesthesiaProviderID IS NOT NULL
	BEGIN
		SELECT @oldPhysicianRoleToBeUsed = DefaultRole
		FROM v_EHR_Physician
		WHERE PhysicianID = @oldFinalAnesthesiaProviderID
		AND   CenterID = @CenterID

		SELECT @staffDetailKeyForOldFinalAnesthesiaProvider = StaffDetailKey
		FROM t_EHR_StaffDetail
		WHERE WorkflowKey = @WorkflowKey
		AND WorkflowKey = @WorkflowKey
		AND ModuleKey = @staffModuleKeyInCurrentWF
		AND StaffID = @oldFinalAnesthesiaProviderID
		AND StaffIDType = @oldFinalAnesthesiaProviderIDType
		AND StaffName = @oldFinalAnesthesiaProviderName
		AND PhysicianRole = @oldPhysicianRoleToBeUsed
		AND @oldPhysicianRoleToBeUsed IN (3, 5)--Anesthesiologist, CRNA
		AND Status = 'A'

		IF @staffDetailKeyForOldFinalAnesthesiaProvider IS NOT NULL
			SET @oldFinalAnesthesiaProviderExistsInStaffDetail = 1
	END
	

	IF @newFinalAnesthesiaProviderID IS NOT NULL
	BEGIN
		SELECT @newPhysicianRoleToBeUsed = DefaultRole
		FROM v_EHR_Physician
		WHERE PhysicianID = @newFinalAnesthesiaProviderID
		AND   CenterID = @CenterID

		SELECT @staffDetailKeyForNewFinalAnesthesiaProvider = StaffDetailKey
		FROM t_EHR_StaffDetail
		WHERE WorkflowKey = @WorkflowKey
		AND WorkflowKey = @WorkflowKey
		AND ModuleKey = @staffModuleKeyInCurrentWF
		AND StaffID = @newFinalAnesthesiaProviderID
		AND StaffIDType = @newFinalAnesthesiaProviderIDType
		AND StaffName = @newFinalAnesthesiaProviderName
		AND PhysicianRole = @newPhysicianRoleToBeUsed
		AND @newPhysicianRoleToBeUsed IN (3, 5)--Anesthesiologist, CRNA
		AND Status = 'A'

		IF @staffDetailKeyForNewFinalAnesthesiaProvider IS NOT NULL
			SET @newFinalAnesthesiaProviderExistsInStaffDetail = 1
	END

	IF @oldFinalAnesthesiaProviderID IS NULL AND @newFinalAnesthesiaProviderID IS NOT NULL
		SET @addFinalAnesthesiaProvider = 1
		
	ELSE IF @oldFinalAnesthesiaProviderID IS NOT NULL AND @newFinalAnesthesiaProviderID IS NOT NULL
		SET @updateFinalAnesthesiaProvider = 1

	ELSE IF @oldFinalAnesthesiaProviderID IS NOT NULL AND @newFinalAnesthesiaProviderID IS NULL
		SET @deleteFinalAnesthesiaProvider = 1

	IF @addFinalAnesthesiaProvider = 1
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM v_EHR_Physician WHERE PhysicianID = @newFinalAnesthesiaProviderID AND CenterID = @CenterID)
			RETURN;

		IF @newFinalAnesthesiaProviderExistsInStaffDetail = 0
		BEGIN
			INSERT t_EHR_StaffDetail (ChartKey, WorkflowKey, ModuleKey, StaffID, StaffIDType, StaffName, PhysicianRole, EmployeeType, OutTime, CreateDate, CreateBy)
			OUTPUT 'I', inserted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			VALUES (@ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @newFinalAnesthesiaProviderID, @newFinalAnesthesiaProviderIDType, @newFinalAnesthesiaProviderName, @newPhysicianRoleToBeUsed, @newPhysicianRoleToBeUsed, @anesthesiaStopTime, @Now, @UserID)

			SET @RCNT = @@ROWCOUNT;
			INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'I')

			IF @RCNT > 0
			BEGIN
				EXEC p_EHR_LET_StaffDetail 'I', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
			END
		END
	END

	ELSE IF @updateFinalAnesthesiaProvider = 1
	BEGIN
		IF @oldFinalAnesthesiaProviderExistsInStaffDetail = 1 AND @newFinalAnesthesiaProviderExistsInStaffDetail = 0
			BEGIN
				UPDATE t_EHR_StaffDetail 
				SET		StaffID = @newFinalAnesthesiaProviderID, 
						StaffIDType = @newFinalAnesthesiaProviderIDType, 
						StaffName = @newFinalAnesthesiaProviderName, 
						PhysicianRole = @newPhysicianRoleToBeUsed, 
						EmployeeType = @newPhysicianRoleToBeUsed,
						ChangeDate = @Now, 
						ChangeBy = @UserID
				OUTPUT 'U', deleted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
				WHERE StaffDetailKey = @staffDetailKeyForOldFinalAnesthesiaProvider

				SET @RCNT = @@ROWCOUNT;
				INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'U')

				IF @RCNT > 0
				BEGIN
					EXEC p_EHR_LET_StaffDetail 'U', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
				END

				RETURN
			END
		IF @oldFinalAnesthesiaProviderExistsInStaffDetail = 1
		BEGIN
			UPDATE t_EHR_StaffDetail 
			SET		Status = 'I', 
					--ChangeDate = @Now, ChangeBy = @UserID, 
					DeactivateDate = @Now, DeactivateBy = @UserID 
			OUTPUT 'D', deleted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			WHERE StaffDetailKey = @staffDetailKeyForOldFinalAnesthesiaProvider

			SET @RCNT = @@ROWCOUNT;
			INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'U')

			IF @RCNT > 0
			BEGIN
				EXEC p_EHR_LET_StaffDetail 'D', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
			END
		END

		IF NOT EXISTS(SELECT 1 FROM v_EHR_Physician WHERE PhysicianID = @newFinalAnesthesiaProviderID AND CenterID = @CenterID)
			RETURN;

		IF @newFinalAnesthesiaProviderExistsInStaffDetail = 0
		BEGIN
			INSERT t_EHR_StaffDetail (ChartKey, WorkflowKey, ModuleKey, StaffID, StaffIDType, StaffName, PhysicianRole, EmployeeType, OutTime, CreateDate, CreateBy)
			OUTPUT 'I', inserted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			VALUES (@ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @newFinalAnesthesiaProviderID, @newFinalAnesthesiaProviderIDType, @newFinalAnesthesiaProviderName, @newPhysicianRoleToBeUsed, @newPhysicianRoleToBeUsed, @anesthesiaStopTime, @Now, @UserID)

			SET @RCNT = @@ROWCOUNT;
			INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'I')

			IF @RCNT > 0
			BEGIN
				EXEC p_EHR_LET_StaffDetail 'I', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
			END
		END
	END

	ELSE IF @deleteFinalAnesthesiaProvider = 1
	BEGIN
		IF @oldFinalAnesthesiaProviderExistsInStaffDetail = 1
		BEGIN
			UPDATE t_EHR_StaffDetail 
			SET		Status = 'I', 
					--ChangeDate = @Now, ChangeBy = @UserID, 
					DeactivateDate = @Now, DeactivateBy = @UserID 
			OUTPUT 'D', deleted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			WHERE StaffDetailKey = @staffDetailKeyForOldFinalAnesthesiaProvider

			SET @RCNT = @@ROWCOUNT;
			INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'U')

			IF @RCNT > 0
			BEGIN
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
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_FinalAnesthesiaProviderIDUpdate'
GO	
	
	