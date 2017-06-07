IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_DiagnosisPreOp') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_DiagnosisPreOp
GO
-- =============================================================================================================
-- Author:			Darren
-- Create date:		12/17/15
-- Description:		
-- =============================================================================================================
CREATE PROCEDURE p_EHR_LET_DiagnosisPreOp
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
	DECLARE @ICDToBeUsed VARCHAR(10)
	DECLARE @ICDVersionToBeUsed VARCHAR(10)

	SELECT @BundleKey = BundleKey
	FROM t_EHR_Module
	WHERE ModuleKey = @ModuleKey

	IF dbo.f_EHR_IsModuleInFirstBundle(@ChartKey, @WorkflowKey, '008') <> 1
		RETURN
	
	SELECT TOP 1 @ICDToBeUsed=ICD,
	@ICDVersionToBeUsed=ICDVersion
	FROM t_EHR_DiagnosisPreOp
	WHERE ChartKey = @ChartKey
	AND BundleKey = @BundleKey
	AND Status = 'A'
	AND ICD IS NOT NULL
	AND ICDVersion IS NOT NULL
	ORDER BY DiagnosisPreOpKey

	IF @ICDToBeUsed IS NOT NULL AND @ICDVersionToBeUsed IS NOT NULL
	BEGIN
		SELECT @visitKey = c.VisitKey 
		FROM t_EHR_Chart c
		JOIN t_VisitClinical vc
		ON c.VisitKey = vc.VisitKey
		WHERE c.ChartKey = @ChartKey

		UPDATE t_VisitClinical SET 
		ICD_Admit = @ICDToBeUsed,
		ICD_AdmitVer = @ICDVersionToBeUsed
		OUTPUT	'U', deleted.*, inserted.*
		INTO	#t_VisitClinical_Audit
		OUTPUT	inserted.*
		WHERE VisitKey = @visitKey

		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_VisitClinical', NULL, NULL, 'U')
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
     ,@value = N'Rev Date: 11/13/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_DiagnosisPreOp'
GO	
	
	