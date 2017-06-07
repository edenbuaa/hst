IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_AllergyModule') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_AllergyModule
GO
-- =============================================================================================================
-- Author:			Susan Taylor
-- Create date:		12/31/15
-- Description:		When one allergy module has been reviewed, 
--					remove Allergy Review Alert, but only if All allergy modules have been reviewed
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_AllergyModule
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
		-- Please note: if list of affected tables change, then p_EHR_AllergyChart will also need affected table list to change (since that can call this proc)
		SELECT	TableName
				,Operation 
		FROM	(
				VALUES ('t_EHR_Alert', 'U')	
				,('t_EHR_HistoryAndPhysical', 'U')
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END

	DECLARE @neededReviewCnt Int;
	SELECT	@neededReviewCnt = COUNT(*)
	FROM	t_EHR_AllergyModule
	WHERE	Reviewed = 0
	AND		ChartKey = @ChartKey 
	AND		[Status] IN ('A','D')

	-- Remove Allergy Review Alert only if all Allergy modules have been reviewed
	--IF @neededReviewCnt = 0
		-- Changed so that Allergy Alerts no longer show ever.  May change this back to show
		-- AllergyAlert ToDo:  if decided that alerts no longer show, then do Allergy module infrastructure cleanup.
	--BEGIN
	--	UPDATE	t_EHR_Alert
	--	SET		IsSet = 0
	--	OUTPUT	'U', deleted.*, inserted.*
	--	INTO	#t_EHR_Alert_Audit
	--	OUTPUT	inserted.*
	--	WHERE   ChartKey = @ChartKey
	--	AND		Title = 'Allergy Review'

	--	INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Alert', NULL, NULL, 'U')

	--END


	-- Populate the Allergies to phsyical history bloc if Allery Bloc is completed. Only when the reviewed was fired manually
	DECLARE @uiFieldName	VARCHAR(100)
	DECLARE @blocCompleted	BIT = 0
	DECLARE @allergries		VARCHAR(1024)	

	SELECT	@uiFieldName = UIFieldName
	FROM	t_EHR_UIDictionary
	WHERE	UIDictionaryKey = @UIDictionaryKey
	IF @uiFieldName = 'Reviewed'
	BEGIN
		EXEC p_EHR_V_Allergy @centerID, @chartKey, @workflowKey, @moduleKey

		-- if incomplete messages exist upon validation, return (Room In BLOC not yet complete)
		IF NOT EXISTS (SELECT * FROM #Incomplete Where ModuleKey=@moduleKey)
			SET @blocCompleted = 1

		DELETE FROM #Incomplete		-- this temp table should not yet have any contents, so clear it in case it does

		-- if module complete, i.e. no incomplete messages
		IF @blocCompleted = 1
		BEGIN
			SELECT @allergries = dbo.f_EHR_GetAllergiesStatement(@chartKey)
			IF @allergries IS NOT NULL
			BEGIN
				UPDATE t_EHR_HistoryAndPhysical
				SET		UnverifiedAllergies = (CASE 
													WHEN ISNULL(UnverifiedAllergies, '') = '' THEN @allergries
													ELSE UnverifiedAllergies
												END)
				OUTPUT	'U', deleted.*, inserted.*
				INTO	#t_EHR_HistoryAndPhysical_Audit
				OUTPUT	inserted.*
				WHERE  ChartKey = @ChartKey
			END

			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_HistoryAndPhysical', NULL, NULL, 'U')	
		END	
	END
	-- Populate End
	RETURN
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH
GO
EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 12/31/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_AllergyModule'
GO	
	
	