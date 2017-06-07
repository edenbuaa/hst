IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_AllergyUnreviewed') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_AllergyUnreviewed
GO
-- =============================================================================================================
-- Author:			Susan Taylor
-- Create date:		2/15/16
-- Description:		Changes needed when Allergy no longer reviewed (due to allergy details change or NKA reset to 0).
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_AllergyUnreviewed
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
		-- Please note: if list of affected tables change, then p_EHR_AllergyChart and  p_EHR_LET_AllergyChartDetail 
		-- will also need affected table list to change (since those can call this proc)
		SELECT	TableName
				,Operation 
		FROM	(
				VALUES ('t_EHR_AllergyModule','U')
					  ,('t_EHR_AllergyChart', 'U')	
					  ,('t_EHR_Alert', 'U')	
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END

	IF @Action = 'R'
		RETURN;

			
	---- this update can affect other modules
	UPDATE t_EHR_AllergyModule 
	SET Reviewed = 0, ChangeDate=@Now, ChangeBy=@UserID
	OUTPUT	'U', deleted.*, inserted.*
	INTO	#t_EHR_AllergyModule_Audit
	OUTPUT	inserted.*
	WHERE	ChartKey = @ChartKey AND [Status] IN ('A','D')

	INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_AllergyModule', NULL, NULL, 'U')

	IF (@Action= 'I' or @Action= 'U' or @Action='D')
	   BEGIN
		UPDATE t_EHR_AllergyModule 
		SET Reviewed = 1, ChangeDate=@Now, ChangeBy=@UserID
		OUTPUT	'U', deleted.*, inserted.*
		INTO	#t_EHR_AllergyModule_Audit
		OUTPUT	inserted.*
		WHERE	ChartKey = @ChartKey and WorkflowKey= @WorkflowKey and ModuleKey=@ModuleKey AND [Status] IN ('A','D')
		
		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_AllergyModule', NULL, NULL, 'U')

		-- fire the reviewed trigger
		EXEC p_EHR_LET_AllergyModule @Action, @CenterID,@ChartKey,@WorkflowKey,@ModuleKey,@BundleKey,@UIDictionaryKey,@Now,@UserID
       END
		-- Changed so that Allergy Alerts no longer show ever.  May change this back to show
		-- AllergyAlert ToDo:  if decided that alerts no longer show, then do Allergy module infrastructure cleanup.
	--UPDATE	t_EHR_Alert
	--SET		IsSet = 1, ChangeDate=@Now, ChangeBy=@UserID
	--OUTPUT	'U', deleted.*, inserted.*
	--INTO	#t_EHR_Alert_Audit
	--OUTPUT	inserted.*
	--WHERE   ChartKey = @ChartKey
	--AND		Title = 'Allergy Review'

	--INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Alert', NULL, NULL, 'U')

	-- if new allergies, then alert should show
	-- if allergies removed, then alert is removed in no allergies currently exist
	IF @Action = 'I' 
	BEGIN
		UPDATE t_EHR_Alert 
		SET IsSet = 1, ChangeDate=@Now, ChangeBy=@UserID
		OUTPUT	'U', deleted.*, inserted.*
		INTO	#t_EHR_Alert_Audit
		OUTPUT	inserted.*
		WHERE	ChartKey = @ChartKey AND [Status] IN ('A','D') AND Title = 'Allergy'

		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Alert', NULL, NULL, 'U')	
	END
	ELSE IF @Action = 'S' OR @Action= 'D'
	BEGIN
		DECLARE @AllergyCnt INT
		SELECT	@AllergyCnt = Count(*)
		FROM	t_EHR_AllergyChartDetail
		WHERE	ChartKey=@ChartKey AND STATUS='A'

		IF @AllergyCnt = 0 
		BEGIN
			UPDATE	t_EHR_Alert 
			SET		IsSet = 0, ChangeDate=@Now, ChangeBy=@UserID
			OUTPUT	'U', deleted.*, inserted.*
			INTO	#t_EHR_Alert_Audit
			OUTPUT	inserted.*
			WHERE	ChartKey = @ChartKey AND [Status] IN ('A','D') AND Title = 'Allergy'

			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Alert', NULL, NULL, 'U')	
		END
	END

	IF @Action = 'I'
	BEGIN
		UPDATE t_EHR_AllergyChart 
		SET NKA = 0, ChangeDate=@Now, ChangeBy=@UserID
		OUTPUT	'U', deleted.*, inserted.*
		INTO	#t_EHR_AllergyChart_Audit
		OUTPUT	inserted.*
		WHERE	ChartKey = @ChartKey AND [Status] IN ('A','D')

		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_AllergyChart', NULL, NULL, 'U')	
	END

	RETURN
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH
GO
EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 2/15/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_AllergyUnreviewed'
GO	
	
	