IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_AllergyChart') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_AllergyChart
GO
-- =============================================================================================================
-- Author:			Susan Taylor
-- Create date:		12/29/15
-- Description:		When NKA has been unchecked, perform same LET as when the allergy details grid has been modified.
--					When NKA has been checked, mark this module as reviewed and perform same LET as when Review button clicked.
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_AllergyChart
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
		SELECT	TableName
				,Operation 
		FROM	(
				VALUES ('t_EHR_AllergyModule','U')
					  ,('t_EHR_AllergyChart', 'U')	
					  ,('t_EHR_Alert', 'U')	
					  ,('t_EHR_HistoryAndPhysical', 'U')
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END

	DECLARE @NKA BIT;

	SELECT  TOP 1 @NKA=NKA
	FROM t_EHR_AllergyChart
	WHERE ChartKey=@ChartKey AND [Status] IN ('A','D')

	IF @NKA = 1
	BEGIN

		-- if NKA set, then set review to true for only this module
		UPDATE t_EHR_AllergyModule 
		SET Reviewed = 1, ChangeDate=@Now, ChangeBy=@UserID
		OUTPUT	'U', deleted.*, inserted.*
		INTO	#t_EHR_AllergyModule_Audit
		OUTPUT	inserted.*
		WHERE	ChartKey = @ChartKey 
		AND		ModuleKey = @ModuleKey
		AND		[Status] IN ('A','D')	
		
		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_AllergyModule', NULL, NULL, 'U')

		-- like p_EHR_LET_AllergyModule, update AllergyReview alert iff all allergy module alerts have been reviewed
			-- Changed so that Allergy Alerts no longer show ever.  May change this back to show
			-- AllergyAlert ToDo:  if decided that alerts no longer show, then do Allergy module infrastructure cleanup.
		EXEC p_EHR_LET_AllergyModule @Action, @CenterID, @ChartKey, @WorkflowKey, @ModuleKey, @BundleKey, @UIDictionaryKey, @Now, @UserID

	END
	ELSE
	BEGIN
		-- update all allergy module entries across all modules due to moving from reviewed to unreviewed state
		EXEC p_EHR_LET_AllergyUnreviewed @Action, @CenterID, @ChartKey, @WorkflowKey, @ModuleKey, @BundleKey, @UIDictionaryKey, @Now, @UserID
	END

	-- Populate the allery  Allergies if Allery Bloc is completed.
	DECLARE @blocCompletedDate SMALLDATETIME
	DECLARE @allergries		VARCHAR(1024)	

	SELECT	@blocCompletedDate = CompletionDate -- we use the completion date to identify this module is complete or not, bcz the complete filed here is always 0
	FROM	t_EHR_Module
	WHERE	ModuleKey = @ModuleKey

	IF @blocCompletedDate IS NOT NULL
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
     ,@value = N'Rev Date: 12/29/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_AllergyChart'
GO	
	
	