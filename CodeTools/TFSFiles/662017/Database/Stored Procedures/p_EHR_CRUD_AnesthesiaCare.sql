IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_AnesthesiaCare') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_AnesthesiaCare;
GO

-- =============================================================================================================
-- Author:			Andy
-- Create date:		7/13/16
-- Design ID:		067
-- Description:		Creates/Reads/Deactivates data row for the Anesthesia Care module
--				  
-- Parameters		action:					'T' -> Return list of tables that this proc returns
--
--											'C' -> Create a new record
--
--											'R' -> Reads the moudle data into result set. This can return more 
--													than one table.
--
--											'D' -> Deactivates specified row
--
--					chartKey:				Chart containing this module
--
--					workflowKey:			Workflow containing this module
--
--					moduleKey:				Reference to the instance of the module
--											 that this data backs
--
--					userID:					User ID of responsible user 
--
--					actionDate:				Date row was touched
-- Editor:			peter f
-- Description:		reviesed the 'R' action to sync with pathway follow the rules as 023 follows
-- =============================================================================================================
CREATE PROCEDURE p_EHR_CRUD_AnesthesiaCare
	 @action			CHAR(1)
	,@centerID			INT
	,@chartKey			INT
	,@workflowKey		INT
	,@moduleKey			INT
	,@userID			VARCHAR(60)
	,@actionDate		SMALLDATETIME
WITH ENCRYPTION

AS
	
SET NOCOUNT ON;

DECLARE		@bundleKey					INT
DECLARE     @minbundleKey				INT

BEGIN TRY
	SELECT      @minbundleKey = MIN(BundleKey) FROM t_EHR_Workflow WHERE ChartKey = @chartKey

	SELECT		@bundleKey = ISNULL(BundleKey, @minbundleKey)
	FROM		t_EHR_Workflow 
	WHERE		WorkflowKey = @workflowKey

	IF @action = 'T'
		SELECT	*
		FROM(VALUES
			('t_EHR_PatientPosition',				NULL, 0)
			,('t_EHR_AnesthesiaCare',				NULL, 1)
			)
		AS	temp (TableName, ResultName, SingleRow)

	-- Create a new row for this module
	ELSE IF @action = 'C'
		BEGIN
			-- Data is bundle-scoped.
			IF NOT EXISTS(SELECT * FROM	t_EHR_AnesthesiaCare WHERE ChartKey = @chartKey AND	BundleKey = @bundleKey)
			BEGIN
				INSERT t_EHR_AnesthesiaCare (ChartKey,BundleKey,CreateBy)
				VALUES (@chartKey,@bundleKey,@userID)
			END
		END
	ELSE IF @action = 'R' OR @action = 'A'
		BEGIN
			SELECT  * 
			FROM    t_EHR_PatientPosition pp INNER JOIN t_EHR_Module m ON pp.ModuleKey = m.ModuleKey
			WHERE   pp.ChartKey = @chartKey
			AND     pp.WorkflowKey IN (SELECT WorkflowKey FROM t_EHR_Workflow WHERE ChartKey = @chartKey AND BundleKey = @bundleKey AND Status IN ('A'))
			AND		((@action='R' AND pp.Status IN ('A', 'D')) OR (@action='A'))
			AND		m.Status IN ('A', 'D')

			SELECT  * 
			FROM    t_EHR_AnesthesiaCare
			WHERE   ChartKey = @chartKey
			AND     BundleKey = @bundleKey
			AND		((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))
		END
	ELSE IF @action = 'V'
	BEGIN
		IF EXISTS(SELECT 1 FROM t_EHR_Module WHERE ModuleKey = @moduleKey AND Status='A' AND NA < 1)
		BEGIN
			DECLARE @MonitorCheckComplete		BIT
			DECLARE @HMECheckComplete			BIT
			DECLARE @AppliedMonitorStandard		BIT
			DECLARE @AppliedMonitorEKG			BIT
			DECLARE @AppliedMonitorPulseOximeter	BIT
			DECLARE @AppliedMonitorNIBP			BIT
			DECLARE @AppliedMonitorO2			BIT	
			DECLARE @AppliedMonitorCO2			BIT
			DECLARE @AppliedMonitorStethoscope	BIT
			DECLARE @AppliedMonitorNerve			BIT
			DECLARE @AppliedMonitorCompression	BIT
			DECLARE @AppliedMonitorTemperature	BIT
			DECLARE @AppliedMonitorWarmingUnit	BIT
			DECLARE @EyeCareNA					BIT
			DECLARE @EyeCareLubricated			BIT
			DECLARE @EyeCareTaped				BIT
			DECLARE @EyeCarePadded				BIT
			DECLARE @PressurePoints				TINYINT
			

			SELECT  @MonitorCheckComplete			=		MonitorCheckComplete		
					,@HMECheckComplete				=		HMECheckComplete			
					,@AppliedMonitorStandard		=		AppliedMonitorStandard		
					,@AppliedMonitorEKG				=		AppliedMonitorEKG			
					,@AppliedMonitorPulseOximeter	=		AppliedMonitorPulseOximeter
					,@AppliedMonitorNIBP			=		AppliedMonitorNIBP			
					,@AppliedMonitorO2				=		AppliedMonitorO2			
					,@AppliedMonitorCO2				=		AppliedMonitorCO2			
					,@AppliedMonitorStethoscope		=		AppliedMonitorStethoscope	
					,@AppliedMonitorNerve			=		AppliedMonitorNerve		
					,@AppliedMonitorCompression		=		AppliedMonitorCompression	
					,@AppliedMonitorTemperature		=		AppliedMonitorTemperature	
					,@AppliedMonitorWarmingUnit		=		AppliedMonitorWarmingUnit	
					,@PressurePoints				=		PressurePoints				
					,@EyeCareNA						=		EyeCareNA					
					,@EyeCareLubricated				=		EyeCareLubricated			
					,@EyeCareTaped					=		EyeCareTaped				
					,@EyeCarePadded					=		EyeCarePadded				
			FROM    t_EHR_AnesthesiaCare
			WHERE   ChartKey = @chartKey
			AND     BundleKey = @bundleKey

			IF  @MonitorCheckComplete = 0  
				EXEC p_EHR_Incomplete @moduleKey, 'MonitorCheckComplete', 'Must check ''Monitor and Machine check complete''';
				
			IF  @HMECheckComplete = 0 AND dbo.f_EHR_IsPAM(@centerID, @moduleKey, 'HMECheckComplete', @HMECheckComplete) = 0
				EXEC p_EHR_Incomplete @moduleKey, 'HMECheckComplete', 'Must check ''HME and Circuit check complete''';

			IF @AppliedMonitorEKG = 0 AND @AppliedMonitorNIBP = 0 AND  @AppliedMonitorO2 = 0 AND @AppliedMonitorCO2 = 0 AND
				 @AppliedMonitorStethoscope = 0 AND @AppliedMonitorNerve = 0 AND @AppliedMonitorTemperature = 0 AND
				 @AppliedMonitorWarmingUnit = 0 AND @AppliedMonitorStandard = 0 AND @AppliedMonitorPulseOximeter = 0 AND
				 @AppliedMonitorCompression = 0 AND dbo.f_EHR_IsPAM(@centerID, @moduleKey, 'AppliedMonitorsText', @AppliedMonitorEKG) = 0 
				EXEC p_EHR_Incomplete @moduleKey, 'AppliedMonitorsText', 'Must check one or more checkboxes for ''Applied Monitors''' ;

			IF  @PressurePoints IS NULL AND dbo.f_EHR_IsPAM(@centerID, @moduleKey, 'PressurePointsText', @PressurePoints) = 0
				EXEC p_EHR_Incomplete @moduleKey, 'PressurePointsText', 'Pressure Points must be filled out';
				
			IF  @EyeCareNA = 0 AND @EyeCareLubricated = 0 AND @EyeCareTaped = 0 AND @EyeCarePadded = 0 
				EXEC p_EHR_Incomplete @moduleKey, 'EyeCareText', 'Must check one or more checkboxes for ''Eye Care''';


		END


	END
	ELSE IF @action = 'D'
		BEGIN
			UPDATE	t_EHR_AnesthesiaCare
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			WHERE   ChartKey = @chartKey
			AND     BundleKey = @bundleKey
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
     ,@value = N'Rev Date: 6/02/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_AnesthesiaCare'
GO