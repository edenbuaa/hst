IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_CLOtest') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_CLOtest
GO
-- ==================================================================================================================================
-- Author:			Peter
-- Create date:		06/13/16
-- Description:		Live edit trigger to update 099
-- ==================================================================================================================================
CREATE PROCEDURE p_EHR_LET_CLOtest
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
DECLARE @uCLOtestkey INT
DECLARE @uTestTime SMALLDATETIME
DECLARE @uBxLocation VARCHAR(60)
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
		DECLARE audit_cursor CURSOR FOR
		SELECT new_CLOtestkey
		FROM #t_EHR_CLOtest_Audit
		--SELECT @uCLOtestkey = new_CLOtestkey			  
		--FROM #t_EHR_CLOtest_Audit

		OPEN audit_cursor

		FETCH NEXT FROM audit_cursor INTO @uCLOtestkey

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @uCLOtestkey IS NOT NULL
			BEGIN
				UPDATE	t_EHR_InHouseLabResultsDetail
				SET		Status='I'	, DeactivateDate = @Now, DeactivateBy = @UserID
				OUTPUT	'U' ,deleted.*,inserted.*
						INTO	#t_EHR_InHouseLabResultsDetail_Audit
						OUTPUT	inserted.*
				WHERE CLOtestKey= @uCLOtestkey		
				INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_InHouseLabResultsDetail', NULL, NULL, 'D')
			END
			FETCH NEXT FROM audit_cursor INTO @uCLOtestkey
		END
		
	END	
	IF @Action = 'I'
	BEGIN
		SELECT @uCLOtestkey = new_CLOtestkey			  
		FROM #t_EHR_CLOtest_Audit

		IF @uCLOtestkey IS NOT NULL
		BEGIN
			SELECT	 @uTestTime = TestTime
					,@uBxLocation = BxLocation			  
					,@uResult = Result			  
			FROM t_EHR_CLOtest
			WHERE CLOtestKey = @uCLOtestkey
		END 
		IF @uTestTime IS NOT NULL AND @uBxLocation IS NOT NULL AND @uResult IS NOT NULL
		BEGIN
		INSERT t_EHR_InHouseLabResultsDetail(ChartKey							
							,CreateBy
							,TestName
							,TestResult
							,CLOtestKey
							)
		OUTPUT 'I', inserted.*, inserted.* 
		INTO #t_EHR_InHouseLabResultsDetail_Audit 
		OUTPUT inserted.*
		VALUES(   @chartKey							
							,@userID
							,CONCAT('CLO test ', @uTestTime,' ', @uBxLocation) 
							,@uResult
							,@uCLOtestkey)

		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_InHouseLabResultsDetail', NULL, NULL, 'I')
		END
	END
	IF @Action = 'U' 
	BEGIN

		SELECT @uCLOtestkey = new_CLOtestkey			  
		FROM #t_EHR_CLOtest_Audit

		IF @uCLOtestkey IS NOT NULL
		BEGIN
			SELECT	 @uTestTime = TestTime
					,@uBxLocation = BxLocation			  
					,@uResult = Result			  
			FROM t_EHR_CLOtest
			WHERE CLOtestKey = @uCLOtestkey
		END 
		IF @uTestTime IS NOT NULL AND @uBxLocation IS NOT NULL AND @uResult IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT * FROM t_EHR_InHouseLabResultsDetail WHERE CLOtestKey = @uCLOtestkey)
			BEGIN
				INSERT t_EHR_InHouseLabResultsDetail(ChartKey							
							,CreateBy
							,TestName
							,TestResult
							,CLOtestKey
							)
				OUTPUT 'I', inserted.*, inserted.* 
				INTO #t_EHR_InHouseLabResultsDetail_Audit 
				OUTPUT inserted.*
				VALUES(   @chartKey							
									,@userID
									,CONCAT('CLO test ', @uTestTime,' ', @uBxLocation) 
									,@uResult
									,@uCLOtestkey)

				INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_InHouseLabResultsDetail', NULL, NULL, 'I')
			END
			ELSE
			BEGIN
				UPDATE	t_EHR_InHouseLabResultsDetail
				SET		TestName = CONCAT('CLO test ', @uTestTime,' ', @uBxLocation)
						,TestResult = @uResult	
						,Reviewed = 0
				OUTPUT	'U' ,deleted.*,inserted.*
						INTO	#t_EHR_InHouseLabResultsDetail_Audit
						OUTPUT	inserted.*
				WHERE CLOtestKey= @uCLOtestkey
				INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_InHouseLabResultsDetail', NULL, NULL, 'U')
			END
		END
		ELSE 
		BEGIN
			UPDATE	t_EHR_InHouseLabResultsDetail
			SET		Status='I'	
			OUTPUT	'U' ,deleted.*,inserted.*
					INTO	#t_EHR_InHouseLabResultsDetail_Audit
					OUTPUT	inserted.*
			WHERE CLOtestKey= @uCLOtestkey		
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
     ,@value = N'Rev Date: 06/13/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_CLOtest'
GO	
	
	