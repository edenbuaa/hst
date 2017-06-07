IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_SupervisingAnesthesiaProviderIDUpdate') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_SupervisingAnesthesiaProviderIDUpdate
GO
-- =============================================================================================================
-- Author:			Darren
-- Create date:		12/08/16
-- Description:		
-- Edit date:		02/17/17 by Susan
-- Changed:			Also need an EmployeeType as PhysicianRole when inserting record to t_EHR_StaffDetail
--					because 030 flyout use EmployeeType field to bound the 'staff role' combo box.
--					And fix a bug regarding staff deletion
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_SupervisingAnesthesiaProviderIDUpdate
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
	DECLARE @oldSupervisingAnesthesiaProviderID INT
	DECLARE @oldSupervisingAnesthesiaProviderIDType CHAR(1)
	DECLARE @oldSupervisingAnesthesiaProviderName VARCHAR(140)
	DECLARE @newSupervisingAnesthesiaProviderID INT
	DECLARE @newSupervisingAnesthesiaProviderIDType CHAR(1)
	DECLARE @newSupervisingAnesthesiaProviderName VARCHAR(140)
	DECLARE @addSupervisingAnesthesiaProvider BIT = 0 --input SupervisingAnesthesiaProvider from empty
	DECLARE @updateSupervisingAnesthesiaProvider BIT = 0--change SupervisingAnesthesiaProvider from one to another
	DECLARE @deleteSupervisingAnesthesiaProvider BIT = 0--clear SupervisingAnesthesiaProvider
	DECLARE @oldPhysicianRoleToBeUsed TINYINT
	DECLARE @newPhysicianRoleToBeUsed TINYINT
	DECLARE @staffDetailKeyForOldSupervisingAnesthesiaProvider INT
	DECLARE @staffDetailKeyForNewSupervisingAnesthesiaProvider INT
	DECLARE @oldSupervisingAnesthesiaProviderExistsInStaffDetail BIT = 0
	DECLARE @newSupervisingAnesthesiaProviderExistsInStaffDetail BIT = 0
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

	SELECT @oldSupervisingAnesthesiaProviderID = old_SupervisingAnesthesiaProviderID
	,@oldSupervisingAnesthesiaProviderIDType = old_SupervisingAnesthesiaProviderIDType
	,@oldSupervisingAnesthesiaProviderName = old_SupervisingAnesthesiaProviderName
	,@newSupervisingAnesthesiaProviderID = new_SupervisingAnesthesiaProviderID
	,@newSupervisingAnesthesiaProviderIDType = new_SupervisingAnesthesiaProviderIDType
	,@newSupervisingAnesthesiaProviderName = new_SupervisingAnesthesiaProviderName
	FROM #t_EHR_Anesthesia_Audit

	IF @oldSupervisingAnesthesiaProviderID IS NOT NULL
	BEGIN
		SELECT @oldPhysicianRoleToBeUsed =  CASE DefaultRole
												WHEN 5 THEN 5 
												ELSE 3 
											END
		FROM v_EHR_Physician
		WHERE PhysicianID = @oldSupervisingAnesthesiaProviderID
		AND   CenterID = @CenterID

		SELECT @staffDetailKeyForOldSupervisingAnesthesiaProvider = StaffDetailKey
		FROM t_EHR_StaffDetail
		WHERE WorkflowKey = @WorkflowKey
		AND WorkflowKey = @WorkflowKey
		AND ModuleKey = @staffModuleKeyInCurrentWF
		AND StaffID = @oldSupervisingAnesthesiaProviderID
		AND StaffIDType = @oldSupervisingAnesthesiaProviderIDType
		AND StaffName = @oldSupervisingAnesthesiaProviderName
		AND PhysicianRole = @oldPhysicianRoleToBeUsed
		AND Status = 'A'

		IF @staffDetailKeyForOldSupervisingAnesthesiaProvider IS NOT NULL
			SET @oldSupervisingAnesthesiaProviderExistsInStaffDetail = 1
	END
	

	IF @newSupervisingAnesthesiaProviderID IS NOT NULL
	BEGIN
		SELECT @newPhysicianRoleToBeUsed =  CASE DefaultRole
											WHEN 5 THEN 5 
											ELSE 3 
										END
		FROM v_EHR_Physician
		WHERE PhysicianID = @newSupervisingAnesthesiaProviderID
		AND   CenterID = @CenterID

		SELECT @staffDetailKeyForNewSupervisingAnesthesiaProvider = StaffDetailKey
		FROM t_EHR_StaffDetail
		WHERE WorkflowKey = @WorkflowKey
		AND WorkflowKey = @WorkflowKey
		AND ModuleKey = @staffModuleKeyInCurrentWF
		AND StaffID = @newSupervisingAnesthesiaProviderID
		AND StaffIDType = @newSupervisingAnesthesiaProviderIDType
		AND StaffName = @newSupervisingAnesthesiaProviderName
		AND PhysicianRole = @newPhysicianRoleToBeUsed
		AND Status = 'A'

		IF @staffDetailKeyForNewSupervisingAnesthesiaProvider IS NOT NULL
			SET @newSupervisingAnesthesiaProviderExistsInStaffDetail = 1
	END

	IF @oldSupervisingAnesthesiaProviderID IS NULL AND @newSupervisingAnesthesiaProviderID IS NOT NULL
		SET @addSupervisingAnesthesiaProvider = 1
		
	ELSE IF @oldSupervisingAnesthesiaProviderID IS NOT NULL AND @newSupervisingAnesthesiaProviderID IS NOT NULL
		SET @updateSupervisingAnesthesiaProvider = 1

	ELSE IF @oldSupervisingAnesthesiaProviderID IS NOT NULL AND @newSupervisingAnesthesiaProviderID IS NULL
		SET @deleteSupervisingAnesthesiaProvider = 1

	IF @addSupervisingAnesthesiaProvider = 1
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM v_EHR_Physician WHERE PhysicianID = @newSupervisingAnesthesiaProviderID AND CenterID = @CenterID)
			RETURN;

		IF @newSupervisingAnesthesiaProviderExistsInStaffDetail = 0
		BEGIN
			INSERT t_EHR_StaffDetail (ChartKey, WorkflowKey, ModuleKey, StaffID, StaffIDType, StaffName, PhysicianRole, EmployeeType, InTime, CreateDate, CreateBy)
			OUTPUT 'I', inserted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			VALUES (@ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @newSupervisingAnesthesiaProviderID, @newSupervisingAnesthesiaProviderIDType, @newSupervisingAnesthesiaProviderName, @newPhysicianRoleToBeUsed, @newPhysicianRoleToBeUsed, @anesthesiaStartTime, @Now, @UserID)

			SET @RCNT = @@ROWCOUNT;
			INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'I')

			IF @RCNT > 0
			BEGIN
				EXEC p_EHR_LET_StaffDetail 'I', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
			END
		END
	END

	ELSE IF @updateSupervisingAnesthesiaProvider = 1
	BEGIN
		IF @oldSupervisingAnesthesiaProviderExistsInStaffDetail = 1 AND @newSupervisingAnesthesiaProviderExistsInStaffDetail = 0
			BEGIN
				UPDATE t_EHR_StaffDetail 
				SET		StaffID = @newSupervisingAnesthesiaProviderID, 
						StaffIDType = @newSupervisingAnesthesiaProviderIDType, 
						StaffName = @newSupervisingAnesthesiaProviderName, 
						PhysicianRole = @newPhysicianRoleToBeUsed, 
						EmployeeType = @newPhysicianRoleToBeUsed,
						ChangeDate = @Now, 
						ChangeBy = @UserID
				OUTPUT 'U', deleted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
				WHERE StaffDetailKey = @staffDetailKeyForOldSupervisingAnesthesiaProvider

				IF @@ROWCOUNT > 0
				BEGIN
					INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'U')
					EXEC p_EHR_LET_StaffDetail 'U', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
				END

				RETURN
			END
		IF @oldSupervisingAnesthesiaProviderExistsInStaffDetail = 1
		BEGIN
			UPDATE t_EHR_StaffDetail 
			SET		Status = 'I', 
					--ChangeDate = @Now, ChangeBy = @UserID, 
					DeactivateDate = @Now, DeactivateBy = @UserID 
			OUTPUT 'D', deleted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			WHERE StaffDetailKey = @staffDetailKeyForOldSupervisingAnesthesiaProvider

			IF @@ROWCOUNT > 0
			BEGIN
				INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'U')
				EXEC p_EHR_LET_StaffDetail 'D', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
			END
		END

		IF NOT EXISTS(SELECT 1 FROM v_EHR_Physician WHERE PhysicianID = @newSupervisingAnesthesiaProviderID AND CenterID = @CenterID)
			RETURN;

		IF @newSupervisingAnesthesiaProviderExistsInStaffDetail = 0
		BEGIN
			INSERT t_EHR_StaffDetail (ChartKey, WorkflowKey, ModuleKey, StaffID, StaffIDType, StaffName, PhysicianRole, EmployeeType, InTime, CreateDate, CreateBy)
			OUTPUT 'I', inserted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			VALUES (@ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @newSupervisingAnesthesiaProviderID, @newSupervisingAnesthesiaProviderIDType, @newSupervisingAnesthesiaProviderName, @newPhysicianRoleToBeUsed, @newPhysicianRoleToBeUsed, @anesthesiaStartTime, @Now, @UserID)

			IF @@ROWCOUNT > 0
			BEGIN
				INSERT INTO #UpdateLog VALUES (@staffModuleKeyInCurrentWF, @WorkflowKey, 't_EHR_StaffDetail', NULL, NULL, 'I')
				EXEC p_EHR_LET_StaffDetail 'I', @CenterID, @ChartKey, @WorkflowKey, @staffModuleKeyInCurrentWF, @BundleKey, -1, @Now, @UserID
			END
		END
	END

	ELSE IF @deleteSupervisingAnesthesiaProvider = 1
	BEGIN
		IF @oldSupervisingAnesthesiaProviderExistsInStaffDetail = 1
		BEGIN
			UPDATE	t_EHR_StaffDetail 
			SET		Status = 'I', 
					--ChangeDate = @Now, ChangeBy = @UserID, 
					DeactivateDate = @Now, DeactivateBy = @UserID 
			OUTPUT 'D', deleted.*, inserted.* INTO #t_EHR_StaffDetail_Audit OUTPUT inserted.*
			WHERE StaffDetailKey = @staffDetailKeyForOldSupervisingAnesthesiaProvider

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
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_SupervisingAnesthesiaProviderIDUpdate'
GO	
	
	