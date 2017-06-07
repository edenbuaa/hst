IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_TourniquetDetail') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_TourniquetDetail
GO
-- =============================================================================================================
-- Author:			Darren
-- Create date:		01/14/16
-- Description:		
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_TourniquetDetail
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
				VALUES ('t_EHR_Tourniquet','U')
				,('t_EHR_MedicationAdministration','U')
				,('t_EHR_GCodeDetail','U')			
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END

	DECLARE @totalMinutesLeft INT
			,@totalMinutesRight INT
			,@TourniquetStartTime SMALLDATETIME

	SELECT @totalMinutesLeft = SUM(DATEDIFF(MINUTE, TimeUp, TimeDown))
	FROM   t_EHR_TourniquetDetail
	WHERE  BodySide = 'L'
	AND	   ChartKey = @ChartKey
	AND	   ModuleKey = @ModuleKey
	AND    WorkflowKey = @WorkflowKey
	AND    Status IN ('A')
	AND    TimeUp IS NOT NULL
	AND    TimeDown IS NOT NULL

	SELECT @totalMinutesRight = SUM(DATEDIFF(MINUTE, TimeUp, TimeDown))
	FROM   t_EHR_TourniquetDetail
	WHERE  BodySide = 'R'
	AND	   ChartKey = @ChartKey
	AND	   ModuleKey = @ModuleKey
	AND    WorkflowKey = @WorkflowKey
	AND    Status IN ('A')
	AND    TimeUp IS NOT NULL
	AND    TimeDown IS NOT NULL

	--Update Medication Administration Time Warning and GCodes if Prophylactic Antibiotics are present in Orders but didnt get administered
	SELECT  @TourniquetStartTime= TimeUp FROM t_EHR_TourniquetDetail WHERE ChartKey=@chartKey AND Status= 'A'
	IF(@TourniquetStartTime IS NOT NULL)
	BEGIN
	
		DECLARE @Status INT
		EXEC p_EHR_CalculateProphylacticAntibioticWarning @chartKey, @Status OUTPUT
					
		UPDATE  t_EHR_MedicationAdministration SET AdministrationTimeWarning =@Status
		OUTPUT	'U', deleted.*, inserted.* INTO	#t_EHR_MedicationAdministration_Audit
		OUTPUT	inserted.*
		WHERE ChartKey=@chartKey
		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_MedicationAdministration', NULL, NULL, 'U')

		EXEC p_EHR_LET_UpdateAntibioticGCodes @Action, @CenterID, @ChartKey, @WorkflowKey, @ModuleKey, @BundleKey, @UIDictionaryKey, @Now, @UserID
		
		
	END

	UPDATE t_EHR_Tourniquet SET 
	TotalMinutesLeft = ISNULL(@totalMinutesLeft, 0),
	TotalMinutesRight = ISNULL(@totalMinutesRight, 0)
	OUTPUT	'U', deleted.*, inserted.*
	INTO	#t_EHR_Tourniquet_Audit
	OUTPUT	inserted.*
	WHERE  ChartKey = @chartKey
	AND	   ModuleKey = @moduleKey
	AND    WorkflowKey = @workflowKey
	AND    Status IN ('A')

	INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Tourniquet', NULL, NULL, 'U')

	RETURN
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH
GO
EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 01/14/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_TourniquetDetail'
GO	
	
	