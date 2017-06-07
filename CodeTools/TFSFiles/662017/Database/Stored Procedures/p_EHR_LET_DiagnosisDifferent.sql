IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_DiagnosisDifferent') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_DiagnosisDifferent
GO
-- =============================================================================================================
-- Author:			Darren
-- Create date:		12/18/15
-- Description:		
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_DiagnosisDifferent
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
				VALUES ('t_VisitClinical','U')
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END
	DECLARE @visitKey INT
	DECLARE @firstBundleKey INT
	DECLARE @PrePostDifferent INT

	SELECT @BundleKey = BundleKey FROM t_EHR_Module WHERE ModuleKey = @ModuleKey

	IF dbo.f_EHR_IsModuleInFirstBundle(@ChartKey, @WorkflowKey, '008') = 1
	BEGIN
		SELECT @visitKey = c.VisitKey 
		FROM t_EHR_Chart c
		JOIN t_VisitClinical vc
		ON c.VisitKey = vc.VisitKey
		WHERE c.ChartKey = @ChartKey
	
		IF NOT EXISTS (SELECT * FROM T_VisitCPT WHERE VisitKey = @visitKey)
		BEGIN
			SELECT @PrePostDifferent = PrePostDifferent FROM t_EHR_Diagnosis WHERE BundleKey = @BundleKey
			UPDATE t_VisitClinical SET 
			DiagDiffers = @PrePostDifferent
			OUTPUT	'U', deleted.*, inserted.*
			INTO	#t_VisitClinical_Audit
			OUTPUT	inserted.*
			WHERE VisitKey = @visitKey

			INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_VisitClinical', NULL, NULL, 'U')
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
     ,@value = N'Rev Date: 12/18/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_DiagnosisDifferent'
GO	
	
	