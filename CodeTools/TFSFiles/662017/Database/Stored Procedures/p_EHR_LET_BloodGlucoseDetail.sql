IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_BloodGlucoseDetail') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_BloodGlucoseDetail
GO
-- ==================================================================================================================================
-- Author:			Darren
-- Create date:		11/24/16
-- Description:		Live edit trigger to update 099
-- ==================================================================================================================================
CREATE PROCEDURE p_EHR_LET_BloodGlucoseDetail
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
DECLARE @uBloodGlucoseDetailkey INT
DECLARE @uTestTime SMALLDATETIME
DECLARE @uResult VARCHAR(60)
BEGIN TRY
	IF @Action = 'T'
	BEGIN		
		SELECT	TableName
				,Operation 
		FROM	(VALUES				
					 ( 't_EHR_InHouseLabResultsDetail',	'I')					
					,( 't_EHR_InHouseLabResultsDetail',	'U')					
					,( 't_EHR_InHouseLabResultsDetail',	'D')					
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END

	IF @Action = 'D' OR @Action = 'S' 
	BEGIN
		SELECT @uBloodGlucoseDetailkey = new_BloodGlucoseDetailKey			  
		FROM #v_EHR_BloodGlucoseDetail_Audit

		IF @uBloodGlucoseDetailkey IS NOT NULL
		BEGIN
			UPDATE	t_EHR_InHouseLabResultsDetail
			SET		Status='I'	, DeactivateDate = @Now, DeactivateBy = @UserID
			OUTPUT	'U' ,deleted.*,inserted.*
					INTO	#t_EHR_InHouseLabResultsDetail_Audit
					OUTPUT	inserted.*
			WHERE BloodGlucoseDetailKey= @uBloodGlucoseDetailkey		
			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_InHouseLabResultsDetail', NULL, NULL, 'D')
		END
	END	
	IF @Action = 'I'
	BEGIN
		SELECT @uBloodGlucoseDetailkey = new_BloodGlucoseDetailKey			  
		FROM #v_EHR_BloodGlucoseDetail_Audit

		IF @uBloodGlucoseDetailkey IS NOT NULL
		BEGIN
			SELECT	 @uTestTime = BloodGlucoseDateTime
					,@uResult = Result			  
			FROM t_EHR_BloodGlucoseDetail
			WHERE BloodGlucoseDetailKey = @uBloodGlucoseDetailkey
		END 
		IF @uTestTime IS NOT NULL AND @uResult IS NOT NULL
		BEGIN
		INSERT t_EHR_InHouseLabResultsDetail(ChartKey							
							,CreateBy
							,TestName
							,TestResult
							,BloodGlucoseDetailKey
							)
		OUTPUT 'I', inserted.*, inserted.* 
		INTO #t_EHR_InHouseLabResultsDetail_Audit 
		OUTPUT inserted.*
		VALUES(   @chartKey							
							,@userID
							,CONCAT('Blood Glucose ', @uTestTime) 
							,@uResult
							,@uBloodGlucoseDetailkey)

		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_InHouseLabResultsDetail', NULL, NULL, 'I')
		END
	END
	IF @Action = 'U' 
	BEGIN

		SELECT @uBloodGlucoseDetailkey = new_BloodGlucoseDetailKey			  
		FROM #v_EHR_BloodGlucoseDetail_Audit

		IF @uBloodGlucoseDetailkey IS NOT NULL
		BEGIN
			SELECT	 @uTestTime = BloodGlucoseDateTime
					,@uResult = Result			  
			FROM t_EHR_BloodGlucoseDetail
			WHERE BloodGlucoseDetailKey = @uBloodGlucoseDetailkey
		END 
		IF @uTestTime IS NOT NULL AND @uResult IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT * FROM t_EHR_InHouseLabResultsDetail WHERE BloodGlucoseDetailKey = @uBloodGlucoseDetailkey)
			BEGIN
				INSERT t_EHR_InHouseLabResultsDetail(ChartKey							
							,CreateBy
							,TestName
							,TestResult
							,BloodGlucoseDetailKey
							)
				OUTPUT 'I', inserted.*, inserted.* 
				INTO #t_EHR_InHouseLabResultsDetail_Audit 
				OUTPUT inserted.*
				VALUES(   @chartKey							
									,@userID
									,CONCAT('Blood Glucose ', @uTestTime) 
									,@uResult
									,@uBloodGlucoseDetailkey)

				INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_InHouseLabResultsDetail', NULL, NULL, 'I')
			END
			ELSE
			BEGIN
				UPDATE	t_EHR_InHouseLabResultsDetail
				SET		TestName = CONCAT('Blood Glucose ', @uTestTime) 
						,TestResult = @uResult	
				OUTPUT	'U' ,deleted.*,inserted.*
						INTO	#t_EHR_InHouseLabResultsDetail_Audit
						OUTPUT	inserted.*
				WHERE BloodGlucoseDetailKey = @uBloodGlucoseDetailkey
				INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_InHouseLabResultsDetail', NULL, NULL, 'U')
			END
		END
		ELSE 
		BEGIN
			UPDATE	t_EHR_InHouseLabResultsDetail
			SET		Status='I'	, DeactivateDate = @Now, DeactivateBy = @UserID
			OUTPUT	'U' ,deleted.*,inserted.*
					INTO	#t_EHR_InHouseLabResultsDetail_Audit
					OUTPUT	inserted.*
			WHERE BloodGlucoseDetailKey = @uBloodGlucoseDetailkey	
			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_InHouseLabResultsDetail', NULL, NULL, 'D')
		END


	RETURN;
	END		
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH
GO
EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 11/24/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_BloodGlucoseDetail'
GO	
	
	