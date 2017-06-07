IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_FallRiskAssessment') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_LET_FallRiskAssessment;
GO

-- =============================================================================================================
-- Create date:		11/24/15
-- Description:		Examines the fall risk score and, if appropriate, sets an alert in t_EHR_Akert
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_FallRiskAssessment
	@Action				CHAR(1)		-- 'T' returns a list of tables that might be affected. 'E' is for execute
	,@CenterID			INT
	,@ChartKey			INT
	,@WorkflowKey		INT
	,@ModuleKey			INT
	,@BundleKey			INT
	,@UIDictionaryKey	INT
	,@Now				SMALLDATETIME
	,@UserID			VARCHAR(60)
WITH ENCRYPTION

AS
	
SET NOCOUNT ON;

BEGIN TRY
	IF @Action = 'T'
	BEGIN
		SELECT	TableName				 
				,Operation
		FROM	(
				VALUES	('t_EHR_Alert','U')
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END

	IF @Action = 'U'
	BEGIN
		DECLARE @fallRiskScore	INT
				,@isSet			BIT

		SELECT	@fallRiskScore = Score
		FROM	t_EHR_FallRiskAssessment
		WHERE	ChartKey = @ChartKey	

		IF @fallRiskScore >=6
			SET @isSet = 1
		ELSE
			SET @isSet = 0

		-- This update statement should trigger a LiveEdit to another module
		UPDATE	t_EHR_Alert
		SET		IsSet = @isSet
		OUTPUT	'U', deleted.*, inserted.*
		INTO	#t_EHR_Alert_Audit
		OUTPUT	inserted.*
		WHERE   ChartKey = @ChartKey
		AND		Title = 'Fall'

		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_Alert', NULL, NULL, 'U')
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
     ,@value = N'Rev Date: 6/1/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_FallRiskAssessment'
GO
