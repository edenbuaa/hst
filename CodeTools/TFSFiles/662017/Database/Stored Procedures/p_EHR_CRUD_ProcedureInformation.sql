IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_ProcedureInformation') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_ProcedureInformation;
GO

-- =============================================================================================================
-- Author:			Andy
-- Create date:		8/6/15
-- Description:		Creates/Reads/Deactivates data row for the Incision Stop Time module
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
-- Editor:			peter f
-- Description:		reviesed the 'R' action to sync with pathway follow the rules as 023 follows
-- =============================================================================================================
CREATE PROCEDURE p_EHR_CRUD_ProcedureInformation
	 @action			CHAR(1)
	,@centerID			INT
	,@chartKey			INT
	,@workflowKey		INT
	,@moduleKey			INT
	,@userID			VARCHAR(60)
	,@actionDate		SMALLDATETIME
--WITH ENCRYPTION

AS
	
SET NOCOUNT ON;

DECLARE		@bundleKey					INT
DECLARE		@roomin						SMALLDATETIME

--DECLARE		@visitServiceKey		INT
--DECLARE		@serviceDescription		VARCHAR(512)
--DECLARE		@serviceModifier		CHAR(1)

BEGIN TRY		
	SELECT		@bundleKey	= BundleKey
	FROM		t_EHR_Module 
	WHERE		ModuleKey = @moduleKey

	SELECT		@roomin = RoomTimeIn 
	FROM		v_EHR_WorkflowRoomTime
	WHERE		ChartKey = @chartKey 
	AND			AreaKey = 4

	PRINT 'RoomTime:' 
	PRINT @roomin

	IF @action = 'T'
		SELECT	*
		FROM(VALUES
			('v_EHR_Modifier',				NULL, 0)
			,('t_EHR_PerformedProcedure',	NULL, 0)
			,('t_EHR_Bundle',				NULL, 1)
			,('t_EHR_ScheduledProcedure',	NULL, 0)
			,('v_EHR_WorkflowRoomTime',		NULL, 1)
			,('t_VisitClinical',			NULL, 0)
			,('t_EHR_Procedure',			NULL, 1)
			)
		AS	temp (TableName, ResultName, SingleRow)

	-- Create a new row for this module
	ELSE IF @action = 'C'
		BEGIN
			-- Data is bundle-scoped.
			IF NOT EXISTS	(	SELECT	* 
								FROM	t_EHR_Procedure 
								WHERE	ChartKey = @chartKey 
								AND		BundleKey = @bundleKey
							)
			BEGIN
				INSERT t_EHR_Procedure (ChartKey, BundleKey, CreateBy)
				VALUES				   (@chartKey, @bundleKey, @userID)

				INSERT INTO t_EHR_ScheduledProcedure(ChartKey
					,BundleKey
					,CreateBy
					,VisitServiceKey
					,ProcedureDescription
					,ProcedureModifier
					,PrimaryProcedure
					,SortOrder)
				SELECT   @chartKey
					,@bundleKey 
					,@userID
					,VisitServiceKey
					,ProcedureDescription = ServiceDescription
					,ProcedureModifier = ServiceModifier
					,PrimaryProcedure
					,SortOrder
				FROM   t_VisitService vs INNER JOIN t_EHR_Chart c ON vs.VisitKey = c.VisitKey
				WHERE  c.ChartKey = @chartKey AND c.Status IN ('A', 'D')
				AND  vs.VisitServiceKey NOT IN 
					(
						SELECT VisitServiceKey FROM t_EHR_ScheduledProcedure 
						WHERE ChartKey = @chartKey AND BundleKey = @bundleKey AND Status IN ('A', 'D') AND VisitServiceKey IS NOT NULL
					)
			END
		END
	ELSE IF @action = 'R' OR @action = 'A'
		BEGIN
			--EXEC p_EHR_SyncSchedProcPathways @chartKey,@bundleKey,@userID;
			-- For a non-grid record, status will be 
			--  'A', even if module is removed, until the chart is closed.  During 
			--  close, status will be set to 'I' if the module was removed from all workflows.
			--  If chart is reopened, then PreCloseStatus will be used to reverse the closing .
			--
			-- When retreiving data from closed charts, Status could be 'I' if module was
			--  removed from chart. but in this case the module's status would be 'I' too, 
			--IF @roomin IS NOT NULL
			--BEGIN

				--BEGIN TRAN
				--UPDATE t_EHR_ScheduledProcedure 
				--SET		ProcedureDescription = vs.ServiceDescription,
				--		ProcedureModifier = vs.ServiceModifier,
				--		PrimaryProcedure = vs.PrimaryProcedure,
				--		SortOrder = vs.SortOrder
				--FROM	t_EHR_ScheduledProcedure sp INNER JOIN t_VisitService vs ON sp.VisitServiceKey = vs.VisitServiceKey 
				--INNER JOIN t_EHR_Chart c ON vs.VisitKey = c.VisitKey
				--WHERE c.ChartKey = @chartKey AND c.Status IN ('A', 'D')

				--INSERT INTO t_EHR_ScheduledProcedure(ChartKey
				--	,BundleKey
				--	,CreateBy
				--	,VisitServiceKey
				--	,ProcedureDescription
				--	,ProcedureModifier
				--	,PrimaryProcedure
				--	,SortOrder)
				--SELECT   @chartKey
				--	,@bundleKey 
				--	,@userID
				--	,vs.VisitServiceKey
				--	,ProcedureDescription = vs.ServiceDescription
				--	,ProcedureModifier = vs.ServiceModifier
				--	,vs.PrimaryProcedure
				--	,vs.SortOrder
				--FROM   t_VisitService vs INNER JOIN t_EHR_Chart c ON vs.VisitKey = c.VisitKey
				--WHERE c.ChartKey = @chartKey AND c.Status IN ('A', 'D') 
				--AND   vs.VisitServiceKey NOT IN  
				--(
				--	SELECT VisitServiceKey FROM t_EHR_ScheduledProcedure 
				--	WHERE ChartKey = @chartKey AND BundleKey = @bundleKey AND Status IN ('A', 'D') AND VisitServiceKey IS NOT NULL
				--)
				--COMMIT TRAN

			--END

			SELECT Code, Description ,0 as AreaKey --for audit log
			FROM v_EHR_Modifier

			SELECT  * 
			FROM    t_EHR_PerformedProcedure
			WHERE   ChartKey = @chartKey
			AND     BundleKey = @bundleKey
			AND		((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))

			SELECT  BundleKey,
					ChartKey, 
					IsProcedureConsentSigned
			FROM	t_EHR_Bundle
			WHERE	BundleKey = @bundleKey

			SELECT  * 
			FROM    t_EHR_ScheduledProcedure
			WHERE   ChartKey = @chartKey
			AND     BundleKey = @bundleKey
			AND		((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))
			ORDER BY VisitServiceKey DESC
			
			/*			
			-- Commented by Peter.
			SELECT top 1 * 
			FROM v_EHR_WorkflowRoomTime
			WHERE ChartKey = @chartKey 
			AND  AreaKey = 4*/

			/* we want to get the room in info both intra-op & pre-op (refer to bug 923)*/
			SELECT  * 
			FROM	v_EHR_WorkflowRoomTime	vwt
			JOIN	t_EHR_Area	ar
			ON		vwt.AreaKey = ar.AreaKey
			WHERE 	vwt.ChartKey = @chartKey
			AND		ar.AreaName in ('Intra-Op','Pre-Op')

			SELECT vc.* 
			FROM t_VisitClinical vc INNER JOIN t_EHR_Chart c ON vc.VisitKey = c.VisitKey 
			WHERE c.ChartKey = @chartKey

			SELECT  * 
			FROM    t_EHR_Procedure
			WHERE   ChartKey = @chartKey
			AND     BundleKey = @bundleKey
			AND		((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))
		END
	ELSE IF @action = 'S'
	BEGIN
		--check HSTPathway and sync with HSTeChart
		EXEC p_EHR_SyncSchedProcPathways @chartKey, @bundleKey, @userID, @action, @moduleKey, @workflowKey
	END
	ELSE IF @action = 'V'
		BEGIN
			DECLARE @PrePostDifferent BIT
			DECLARE @ScheduledCount INT
			DECLARE @PerformedCount INT
			DECLARE	@vroomin SMALLDATETIME

			SELECT  @PrePostDifferent = PrePostDifferent 
			FROM    t_EHR_Procedure
			WHERE   ChartKey = @chartKey
			AND     BundleKey = @bundleKey
			AND		[Status] IN ('A', 'D')

			SELECT  @vroomin = RoomTimeIn
			FROM	v_EHR_WorkflowRoomTime	vwt
			JOIN	t_EHR_Area	ar
			ON		vwt.AreaKey = (SELECT AreaKey FROM t_EHR_Workflow WHERE WorkflowKey = @workflowKey)
			WHERE 	vwt.ChartKey = @chartKey

			SELECT  @PerformedCount = COUNT(*) 
			FROM    t_EHR_PerformedProcedure
			WHERE   ChartKey = @chartKey
			AND     BundleKey = @bundleKey
			AND		[Status] IN ('A', 'D')

			SELECT  @ScheduledCount = COUNT(*) 
			FROM    t_EHR_ScheduledProcedure
			WHERE   ChartKey = @chartKey
			AND     BundleKey = @bundleKey
			AND		[Status] IN ('A', 'D')

			IF dbo.f_EHR_IsPAM(@centerID, @moduleKey, 'PrePostDifferent', @PrePostDifferent) = 0
			BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 'PrePostDifferent', '''Pre-op/Post-op Procedure different'' must be filled out'
			END

			IF @vroomin IS NOT NULL
			BEGIN
				IF @ScheduledCount = 0
				BEGIN
					EXEC p_EHR_Incomplete @moduleKey, 't_EHR_ScheduledProcedure', 'Must have at least one Scheduled Procedure'
				END
				IF @PerformedCount = 0
				BEGIN
					EXEC p_EHR_Incomplete @moduleKey, 't_EHR_PerformedProcedure', 'Must have at least one Performed Procedure'
				END
			END
			ELSE
			BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 't_EHR_Procedure', 'Must fill Room In Time in order to enable Load or Add Performed Procedure(s) buttons'
			END
		END
	ELSE IF @action = 'D'
		BEGIN
			UPDATE	t_EHR_Procedure
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			WHERE   ChartKey = @chartKey
			AND     BundleKey = @bundleKey

			UPDATE	t_EHR_ScheduledProcedure
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			WHERE   ChartKey = @chartKey
			AND     BundleKey = @bundleKey

			UPDATE	t_EHR_PerformedProcedure
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			WHERE   ChartKey = @chartKey
			AND     BundleKey = @bundleKey
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
     ,@value = N'Rev Date: 5/11/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_ProcedureInformation'
GO