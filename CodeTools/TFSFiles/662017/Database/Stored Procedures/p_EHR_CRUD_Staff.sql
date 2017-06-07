IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_Staff') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_Staff;
GO

-- =============================================================================================================
-- Author:			Andy
-- Create date:		2/26/16
-- Description:		Creates/Reads/Deactivates data row for the Staff module
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
CREATE PROCEDURE p_EHR_CRUD_Staff
	@action				CHAR(1)
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
			('v_EHR_WorkflowRoomTime',		NULL,	1)
			,('v_EHR_EmployeeType',			NULL,	0)
			,('t_VisitParticipant',			NULL,	0)
			,('t_VisitPhysician',			NULL,	0)
			,('t_EHR_Area',					NULL,	1)
			,('v_EHR_BundleEventTime',		NULL,	1)
			,('t_Employee',					NULL,	0)
			,('v_EHR_Physician',			NULL,	0)
			,('t_EHR_StaffDetail',			NULL,	0)
			)
		AS	temp (TableName, ResultName, SingleRow)

	--Create a new row for this module
	--ELSE IF @action = 'C'
	--	BEGIN
	--		-- yes since this is module scoped, and not a grid table, we always create a new row
	--		INSERT t_EHR_Counts (ChartKey, WorkflowKey, ModuleKey, CreateBy,CreateDate)
	--		VALUES (@chartKey, @workflowKey, @moduleKey, @userID,@actionDate);
	--	END
	ELSE IF @action = 'R' OR @action = 'A'
		BEGIN
			SELECT TOP 1 * 
			FROM v_EHR_WorkflowRoomTime
			WHERE ChartKey = @chartKey 
			AND  WorkflowKey = @workflowKey

			SELECT *
			FROM v_EHR_EmployeeType

			SELECT vp.* 
			FROM t_VisitParticipant vp LEFT JOIN t_EHR_Chart c ON vp.VisitKey = c.VisitKey
			WHERE c.ChartKey = @chartKey
			ORDER BY vp.VisitParticipantKey DESC

			SELECT vp.* 
			FROM t_VisitPhysician vp LEFT JOIN t_EHR_Chart c ON vp.VisitKey = c.VisitKey
			WHERE c.ChartKey = @chartKey
			ORDER BY vp.VisitPhysicianKey DESC

			SELECT a.* 
			FROM t_EHR_Workflow wf LEFT JOIN t_EHR_Area a ON wf.AreaKey = a.AreaKey
			WHERE wf.WorkflowKey = @workflowKey AND a.AreaKey = 5

			SELECT * 
			FROM v_EHR_BundleEventTime
			WHERE ChartKey = @chartKey

			SELECT * FROM t_Employee
			WHERE CenterID = @centerID

			SELECT * FROM v_EHR_Physician
			WHERE CenterID = @centerID

			SELECT	[ChartKey]
					,[Status]
					,[PreCloseStatus]
					,[WorkflowKey]
					,[ModuleKey]
					,[StaffDetailKey]
					,[VisitParticipantKey]
					,[VisitPhysicianKey]
					,[StaffIDType]
					,[StaffID]
					,[StaffName]
					,[EmployeeType]	= ISNULL(EmployeeType, CAST(PhysicianRole AS CHAR(8)))
					,[PhysicianRole]
					,[InTime]
					,[OutTime]
					,[Duration]
					,[UseRoomIn]
					,[Notes]
					,[StrikethroughReason]
					,[CreateDate]
					,[CreateBy]
					,[ChangeDate]
					,[ChangeBy]
					,[DeactivateDate]
					,[DeactivateBy]
			FROM	t_EHR_StaffDetail
			WHERE	ChartKey = @chartKey
			AND		ModuleKey = @moduleKey
			AND  ((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))
			ORDER BY StaffDetailKey DESC
		END
	ELSE IF @action = 'V'
	BEGIN
		DECLARE @AnesthesiaStartTime DATETIME
		DECLARE @AnesthesiaStopTime DATETIME
		DECLARE @RoomTimeIn SMALLDATETIME
		DECLARE @RoomTimeOut SMALLDATETIME
		DECLARE @StartTime SMALLDATETIME
		DECLARE @StopTime SMALLDATETIME
		DECLARE @roominflag BIT
		DECLARE @anesthesiaflag BIT
		DECLARE @prompt VARCHAR(60)
		DECLARE @promptend VARCHAR(60)
		DECLARE @Message VARCHAR(512)
		DECLARE @MessageEnd VARCHAR(512)
		DECLARE @StaffCount INT
		SELECT @RoomTimeIn = RoomTimeIn, @RoomTimeOut = RoomTimeOut
		FROM v_EHR_WorkflowRoomTime
		WHERE ChartKey = @chartKey AND WorkflowKey = @workflowKey

		SELECT @AnesthesiaStartTime = AnesthesiaStartTime, @AnesthesiaStopTime = AnesthesiaStopTime 
		FROM v_EHR_BundleEventTime
		WHERE ChartKey = @chartKey

		SELECT	@StaffCount = COUNT(*)
		FROM	t_EHR_StaffDetail
		WHERE	ChartKey = @chartKey
		AND		ModuleKey = @moduleKey
		AND		[Status] IN ('A', 'D')

		IF EXISTS(SELECT a.* FROM t_EHR_Workflow wf LEFT JOIN t_EHR_Area a ON wf.AreaKey = a.AreaKey WHERE wf.WorkflowKey = @workflowKey AND a.AreaKey = 5)
		BEGIN
			SET @prompt = 'anesthesia start time'
            SET @promptend = 'anesthesia stop time'
			SET @anesthesiaflag = 1
			SET @roominflag = 0
			IF @AnesthesiaStartTime IS NOT NULL
			BEGIN
				IF @StaffCount = 0
				BEGIN
					EXEC p_EHR_Incomplete @moduleKey, 't_EHR_StaffDetail', 'Must contain at least one staff entry'
				END
			END
			ELSE
			BEGIN
				IF @StaffCount = 0
				BEGIN
					EXEC p_EHR_Incomplete @moduleKey, 't_EHR_StaffDetail', 'BLOC is read-only until the user taps the anesthesia start time for the workflow'
				END
			END
		END
		ELSE
		BEGIN
			SET @prompt = 'room in time'
            SET @promptend = 'room out time'
			SET @anesthesiaflag = 0
			SET @roominflag = 1
			IF @RoomTimeIn IS NOT NULL
			BEGIN
				IF @StaffCount = 0
				BEGIN
					EXEC p_EHR_Incomplete @moduleKey, 't_EHR_StaffDetail', 'Must contain at least one staff entry'
				END
			END
			ELSE
			BEGIN
				IF @StaffCount = 0
				BEGIN
					EXEC p_EHR_Incomplete @moduleKey, 't_EHR_StaffDetail', 'BLOC is read-only until the user taps the room in time for the workflow'
				END
			END
		END

		SET @Message = 'No In Time can be earlier than the ' + @prompt + ' for the workflow'
		SET @MessageEnd = 'No Out Time can be later than the ' + @promptend + ' for the workflow'

		IF EXISTS(SELECT * FROM	t_EHR_StaffDetail WHERE	ChartKey = @chartKey AND ModuleKey = @moduleKey AND [Status] IN ('A', 'D') AND InTime IS NULL AND OutTime IS NOT NULL)
		BEGIN
			EXEC p_EHR_Incomplete @moduleKey, 'v_EHR_WorkflowRoomTime', 'Must contain at least one completed staff entry'
		END
		ELSE
		BEGIN
			IF @roominflag = 1
			BEGIN
				SET @StartTime = @RoomTimeIn
			END
			ELSE IF @anesthesiaflag = 1
			BEGIN
				SET @StartTime = @AnesthesiaStartTime
			END
			IF EXISTS(SELECT * FROM	t_EHR_StaffDetail WHERE	ChartKey = @chartKey AND ModuleKey = @moduleKey AND [Status] IN ('A', 'D') AND InTime < @StartTime)
			BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 'InTime', @Message
			END
		END

		IF EXISTS(SELECT * FROM	t_EHR_StaffDetail WHERE	ChartKey = @chartKey AND ModuleKey = @moduleKey AND [Status] IN ('A', 'D') AND OutTime IS NULL AND InTime IS NOT NULL)
		BEGIN
			EXEC p_EHR_Incomplete @moduleKey, 'v_EHR_WorkflowRoomTime', 'Must contain at least one completed staff entry'
		END
		ELSE
		BEGIN
			IF @roominflag = 1
			BEGIN
				SET @StopTime = @RoomTimeOut
			END
			ELSE IF @anesthesiaflag = 1
			BEGIN
				SET @StopTime = @AnesthesiaStopTime
			END
			IF EXISTS(SELECT * FROM	t_EHR_StaffDetail WHERE	ChartKey = @chartKey AND ModuleKey = @moduleKey AND [Status] IN ('A', 'D') AND OutTime > @StopTime)
			BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 'OutTime', @MessageEnd
			END
		END

		IF EXISTS(SELECT * FROM	t_EHR_StaffDetail WHERE	ChartKey = @chartKey AND ModuleKey = @moduleKey AND [Status] IN ('A', 'D') AND OutTime IS NULL AND InTime IS NULL)
		BEGIN
			EXEC p_EHR_Incomplete @moduleKey, 'v_EHR_WorkflowRoomTime', 'Must contain at least one completed staff entry'
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT * FROM	t_EHR_StaffDetail WHERE	ChartKey = @chartKey AND ModuleKey = @moduleKey AND [Status] IN ('A', 'D') AND InTime >= OutTime)
			BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 'v_EHR_WorkflowRoomTime', 'No Out Time can be earlier than an In Time'
			END
		END
	END
	ELSE IF @action = 'D'
		BEGIN
			-- no UI to delete a non-grid row.  status only set to I when chart closed and someone removed module from workflow.
			UPDATE t_EHR_StaffDetail
			SET  Status = 'I'
			,DeactivateDate = @actionDate
			,DeactivateBy = @userID
			FROM t_EHR_StaffDetail
			WHERE ChartKey = @chartKey 
			AND  ModuleKey = @moduleKey
			AND  Status IN ('A','D')
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
     ,@value = N'Rev Date: 5/15/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_Staff'
GO