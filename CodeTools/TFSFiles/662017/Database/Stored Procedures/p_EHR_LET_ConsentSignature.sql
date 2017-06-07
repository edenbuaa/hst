IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_ConsentSignature') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_ConsentSignature
GO
-- =============================================================================================================
-- Author:			Bill Teng
-- Create date:		6/1/2016
-- Description:		Live edit trigger for update on Consent Signature - PatientSignature and WitnessSignature
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_ConsentSignature
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
				VALUES	 ('t_EHR_Bundle', 'U')
						,('t_EHR_Alert',  'U')
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END

	IF @Action = 'R'
		RETURN;	
	SELECT @BundleKey = BundleKey FROM t_EHR_Workflow WHERE WorkflowKey = @WorkflowKey

	DECLARE @isConsentFullySigned BIT

	-- Check all required signature's signed value 
	SET @isConsentFullySigned = dbo.[f_EHR_IsConsentSigned](@ModuleKey, @CenterID)

	DECLARE @hasProcedureQuestion BIT
	SET @hasProcedureQuestion = dbo.f_EHR_ExistsProcedureQuestion(@ModuleKey)

	DECLARE @hasAnesthesiaQuestion BIT
	SET @hasAnesthesiaQuestion = dbo.f_EHR_ExistsAnesthesiaQuestion(@ModuleKey)

	DECLARE @procedureSigned TINYINT
	SET @procedureSigned = dbo.f_EHR_IsChartProcedureConsentSigned(@ChartKey, @CenterID)

	IF (@BundleKey IS NULL OR @BundleKey <= 0)
	BEGIN
		SELECT		TOP 1 @BundleKey = BundleKey
		FROM		t_EHR_Bundle
		WHERE		ChartKey = @ChartKey
		ORDER BY	CreateDate
	END

	IF (@Action = 'X')
	BEGIN 
		IF (@BundleKey > 0)
		BEGIN
			IF (@isConsentFullySigned = 1)
			BEGIN
				IF (@hasProcedureQuestion = 1)
				BEGIN
					UPDATE		t_EHR_Bundle
					SET			IsProcedureConsentSigned = 1
								,ChangeDate = @Now
								,ChangeBy = @UserID
					OUTPUT		'U', deleted.*, inserted.* INTO	#t_EHR_Bundle_Audit
					OUTPUT		inserted.*	
					WHERE		BundleKey = @BundleKey

					INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Bundle', NULL, NULL, 'U')	
											
				END			

				IF (@hasAnesthesiaQuestion = 1)
				BEGIN
					UPDATE		t_EHR_Bundle
					SET			IsAnesthesiaConsentSigned = 1
								,ChangeDate = @Now
								,ChangeBy = @UserID
					OUTPUT		'U', deleted.*, inserted.* INTO	#t_EHR_Bundle_Audit
					OUTPUT		inserted.*	
					WHERE		BundleKey = @BundleKey

					INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Bundle', NULL, NULL, 'U')
				END
						
			END

			-- chart scope checking the procedure consent signature		
			IF (@procedureSigned = 1)
			BEGIN
				UPDATE		t_EHR_Alert
				SET			IsSet = 0
							,ChangeDate = @Now
							,ChangeBy = @UserID
				OUTPUT		'U', deleted.*, inserted.* INTO	#t_EHR_Alert_Audit
				OUTPUT		inserted.*	
				WHERE		ChartKey = @ChartKey
				AND			Title = 'Consent'
				AND			[Status] = 'A'

				INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Alert', NULL, NULL, 'U')
			END
		END
	END
	ELSE IF (@Action = 'Y')
	BEGIN
		IF (@BundleKey > 0)
		BEGIN
			IF (@isConsentFullySigned = 0)
			BEGIN
				IF (@hasProcedureQuestion = 1)
				BEGIN
					UPDATE		t_EHR_Bundle
					SET			IsProcedureConsentSigned = 0
								,ChangeDate = @Now
								,ChangeBy = @UserID
					OUTPUT		'U', deleted.*, inserted.* INTO	#t_EHR_Bundle_Audit
					OUTPUT		inserted.*	
					WHERE		BundleKey = @BundleKey

					INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Bundle', NULL, NULL, 'U')				
				END

				IF (@hasAnesthesiaQuestion = 1)
				BEGIN
					UPDATE		t_EHR_Bundle
					SET			IsAnesthesiaConsentSigned = 0
								,ChangeDate = @Now
								,ChangeBy = @UserID
					OUTPUT		'U', deleted.*, inserted.* INTO	#t_EHR_Bundle_Audit
					OUTPUT		inserted.*	
					WHERE		BundleKey = @BundleKey

					INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Bundle', NULL, NULL, 'U')
				END						
			END

			-- Update the alert for showing
			-- chart scope checking the procedure consent signature		
			IF (@procedureSigned = 0)
			BEGIN
				UPDATE		t_EHR_Alert
				SET			IsSet = 1
							,ChangeDate = @Now
							,ChangeBy = @UserID
				OUTPUT		'U', deleted.*, inserted.* INTO	#t_EHR_Alert_Audit
				OUTPUT		inserted.*	
				WHERE		ChartKey = @ChartKey
				AND			Title = 'Consent'
				AND			[Status] = 'A'

				INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Alert', NULL, NULL, 'U')
			END

		END		
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
     ,@value = N'Rev Date: 06/01/2016'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_ConsentSignature'
GO	
	
	