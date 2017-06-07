IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_CheckOrderMedication') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_CheckOrderMedication
GO
-- ==================================================================================================================================
-- Author:			Darren Lou
-- Create date:		08/31/16
-- Description:		Live edit trigger to update Medication Administration check status
-- ==================================================================================================================================
CREATE PROCEDURE p_EHR_LET_CheckOrderMedication
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
		FROM	(VALUES				
					( 't_EHR_MedicationAdministrationDetail','U')		
				)
		AS AffectedTableList (TableName,Operation)

		RETURN;
	END

	IF @Action = 'U'
	BEGIN
		DECLARE @OrderMedicationKey INT, @MedicationCheckStatus TINYINT, @MedicationCheckWarning VARCHAR(MAX)

		SELECT @OrderMedicationKey = new_OrderMedicationKey, @MedicationCheckStatus = new_MedicationCheckStatus, @MedicationCheckWarning = new_MedicationCheckWarning  FROM #t_EHR_OrderMedication_Audit
		
		UPDATE t_EHR_MedicationAdministrationDetail 
		SET MedCheckStatus = @OrderMedicationKey,
		MedCheckWarning = @MedicationCheckWarning
		WHERE  OrderMedicationKey = @OrderMedicationKey
		AND AdministrationTime IS NULL

		INSERT INTO #UpdateLog VALUES (@ModuleKey, @WorkflowKey, 't_EHR_MedicationAdministrationDetail', NULL, NULL, 'U')
	END
	
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH
GO
EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 08/31/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_LET_CheckOrderMedication'
GO	
	
	