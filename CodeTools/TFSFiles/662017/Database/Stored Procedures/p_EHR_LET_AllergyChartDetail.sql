IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_AllergyChartDetail') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_AllergyChartDetail
GO
-- =============================================================================================================
-- Author:			Susan Taylor
-- Create date:		12/29/15
-- Description:		
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_AllergyChartDetail
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
					  ,('t_EHR_HomeMedicationDetail', 'U')	
					  ,('t_EHR_Module', 'U')
					  ,('t_EHR_OrderMedication', 'U')
					  ,('t_EHR_OrderText', 'U')
					  ,('t_EHR_HistoryAndPhysical', 'U')
					  ,('t_EHR_MedicationAdministrationDetail','U')
					  ,('t_EHR_PrepDetail','U')
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END

	-- Allergy no longer in reviewed state
	EXEC p_EHR_LET_AllergyUnreviewed @Action, @CenterID, @ChartKey, @WorkflowKey, @ModuleKey, @BundleKey, @UIDictionaryKey, @Now, @UserID

	-- Medication uncheck status (allergy/drug, drug/drug) update
	EXEC p_EHR_LET_UncheckStatusAllMedication @Action, @CenterID, @ChartKey, @WorkflowKey, @ModuleKey, @BundleKey, @UIDictionaryKey, @Now, @UserID

	-- ToDo:  Eventually can move t_EHR_Alert changes from  p_EHR_LET_AllergyUnreviewed to here
	--        Waiting for confirmation that AllergyReview alert no longer needed, then t_EHR_Alert can be completely removed from 
	--        that sproc as well as T_EHR_LET_AllergyChart table list

	-- check for latex allergy (AllergyClassID=68) for alert purposes

	DECLARE @hasLatexAllergy BIT
	SET @hasLatexAllergy = 0

	IF (EXISTS (SELECT * from t_EHR_AllergyChartDetail WHERE ChartKey = @ChartKey AND Status = 'A' AND AllergyClassID=68) )
		SET @hasLatexAllergy = 1

	-- the alert will exists, but may not have the desired value, in which case update
	IF (NOT EXISTS (SELECT 1 FROM t_EHR_Alert WHERE ChartKey = @chartKey AND Title='Latex' AND Status='A' AND IsSet = @hasLatexAllergy) )
	BEGIN
		UPDATE t_EHR_Alert 
		SET IsSet = @hasLatexAllergy, ChangeDate=@Now, ChangeBy=@UserID
		OUTPUT	'U', deleted.*, inserted.*
		INTO	#t_EHR_Alert_Audit
		OUTPUT	inserted.*
		WHERE	ChartKey = @ChartKey AND Title='Latex' AND [Status] IN ('A')

		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Alert', NULL, NULL, 'U')
	END

	-- Populate the Allergies to Phsyical History Bloc if Allery Bloc is completed.
	DECLARE @blocCompleted	BIT = 0
	DECLARE @allergries		VARCHAR(1024)	

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

			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_HistoryAndPhysical', NULL, NULL, 'U')	
		END
		
	END	
	-- Populate End

	-- Synchronize Allergy information between pathways and echart
	DECLARE @uiFieldName VARCHAR(100)
	DECLARE @alleryComment varchar(250)
	DECLARE @visitKey int

	SELECT	@uiFieldName = UIFieldName
	FROM	t_EHR_UIDictionary
	WHERE	UIDictionaryKey = @UIDictionaryKey
	
	IF @uiFieldName = 'Notes'-- exclude the note field
	RETURN

	SELECT	@visitKey = VisitKey
	FROM	t_EHR_Chart
	WHERE	Chartkey = @chartKey

	SELECT @alleryComment = dbo.f_EHR_Allergies(@ChartKey)

	UPDATE t_Visit
	SET		AllergyComment = @alleryComment
			,Allergy = (CASE 
							WHEN LEN(@alleryComment) > 0 THEN 1
							ELSE 0
						END)
	WHERE VisitKey = @visitKey

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
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_AllergyChartDetail'
GO	
	
	