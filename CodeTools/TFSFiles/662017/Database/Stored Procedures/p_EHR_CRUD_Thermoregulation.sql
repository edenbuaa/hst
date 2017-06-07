IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_Thermoregulation') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_Thermoregulation;
GO

-- =============================================================================================================
-- Author:			andy
-- Create date:		5/25/15
-- Description:		Creates/Reads/Deactivates data row for the Denititon module
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
--
--					userID:					User ID of responsible user 
--
-- =============================================================================================================
Create PROCEDURE p_EHR_CRUD_Thermoregulation
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

BEGIN TRY
	IF @action = 'T'
		SELECT	*
		FROM(VALUES
			('t_EHR_Thermoregulation',			NULL, 1)
			,('t_ItemEquipment',				NULL, 0)
			)
		AS	temp (TableName, ResultName, SingleRow)

	-- Create a new row for this module
	ELSE IF @action = 'C'
	   BEGIN
			INSERT t_EHR_Thermoregulation (ChartKey, ModuleKey, WorkflowKey, CreateBy)
			VALUES (@chartKey, @moduleKey, @workflowKey, @userID)
	   END
	ELSE IF @action = 'R' OR @action = 'A'
	BEGIN
		
		SELECT		* 
		FROM		t_EHR_Thermoregulation
		WHERE		ChartKey  = @chartKey 
		AND			( (@action='R' AND Status IN ('A', 'D')) OR (@action='A') )
		AND			ModuleKey = @moduleKey 		

		DECLARE		@invGroup	int
		SELECT		@invGroup = InvGroup
		FROM		t_InvConfiguration
		JOIN		t_EHR_Chart
		ON			t_EHR_Chart.CenterID = t_InvConfiguration.CenterID
		WHERE		ChartKey = @chartKey

		SELECT		ie.ItemEquipKey
					,ie.IdentificationNumber
					,ie.SerialNumber
		FROM		t_ItemEquipment ie
		JOIN		t_ItemMaster im
		ON			im.InvGroup = ie.InvGroup
		AND			im.ItemCode = ie.ItemCode
		JOIN		t_EHR_EquipmentCategory ec
		ON			ec.EHREquipmentCategoryKey = im. EHREquipmentCategoryKey
		WHERE		ie.InvGroup = @invGroup 
		AND			ISNULL(ie.IdentificationNumber, '') <> ''
		AND			ec.EHREquipmentCategoryName = 'Blanket'

	END
	ELSE IF @action = 'V'
		BEGIN
			DECLARE @PatientMaintainingTemperature		BIT
					,@HeatedBlanket	BIT
					,@CoolingBlanket	   BIT
					,@ForcedAirHeatedBlanket		BIT
					,@ForcedAirCoolingBlanket		BIT
					,@Other		BIT
					,@FullBody		BIT
					,@LowerBody		BIT
					,@UpperBody		BIT
					,@UnderBody		BIT
					,@ForcedAirCoolingBlanketSerial		varchar(10)
					,@ForcedAirHeatedBlanketSerial		varchar(10)
					,@OtherNote		VARCHAR(64)

			SELECT		@PatientMaintainingTemperature=PatientMaintainingTemperature, 
						@HeatedBlanket=HeatedBlanket, 
						@CoolingBlanket=CoolingBlanket, 
						@ForcedAirHeatedBlanket=ForcedAirHeatedBlanket, 
						@ForcedAirCoolingBlanket=ForcedAirCoolingBlanket, 
						@Other=Other, 
						@FullBody=FullBody, 
						@LowerBody=LowerBody, 
						@UpperBody=UpperBody, 
						@UnderBody=UnderBody, 
						@ForcedAirCoolingBlanket=ForcedAirCoolingBlanket, 
						@ForcedAirCoolingBlanketSerial=ForcedAirCoolingBlanketSerial, 
						@ForcedAirHeatedBlanket=ForcedAirHeatedBlanket, 
						@ForcedAirHeatedBlanketSerial=ForcedAirHeatedBlanketSerial,
						@OtherNote=OtherNote 
			FROM		t_EHR_Thermoregulation
			WHERE		ChartKey  = @chartKey 
			AND			Status = 'A'
			AND			ModuleKey = @moduleKey 	

				
			IF dbo.f_EHR_IsPAM(@centerID, @moduleKey, 'PatientMaintainingTemperature', @PatientMaintainingTemperature) = 0 
			EXEC p_EHR_Incomplete @moduleKey, 'PatientMaintainingTemperature', 'Must select either ''Patient maintaining temperature within normal limits without assistance or intervention'' or ''Patient maintaining temperature with assistance'' ';

			if (@PatientMaintainingTemperature =1) 
				BEGIN
				if @HeatedBlanket =0 and @CoolingBlanket=0 and @ForcedAirHeatedBlanket=0 and @ForcedAirCoolingBlanket=0 
				   and @Other=0 and @FullBody=0 and @LowerBody=0 and @UpperBody=0 and @UnderBody=0
					EXEC p_EHR_Incomplete @moduleKey, 'Devices', 'Choose one or more Devices/Interventions';		

				if @ForcedAirCoolingBlanket=1 and (@ForcedAirCoolingBlanketSerial is null or @ForcedAirCoolingBlanketSerial='')
					EXEC p_EHR_Incomplete @moduleKey, 'SerialCooling', 'Serial # is required';	

				if @ForcedAirHeatedBlanket=1 and (@ForcedAirHeatedBlanketSerial is null or @ForcedAirHeatedBlanketSerial='')
					EXEC p_EHR_Incomplete @moduleKey, 'SerialHeated', 'Serial # is required';

				if @HeatedBlanket=1 or @ForcedAirCoolingBlanket=1 or @CoolingBlanket=1 or (@ForcedAirHeatedBlanketSerial is not null and @ForcedAirHeatedBlanketSerial<>'') or @Other=1
				BEGIN	
					if @FullBody=0 and @LowerBody=0 and @UpperBody=0 and @UnderBody=0
					EXEC p_EHR_Incomplete @moduleKey, 'Location', 'One or more selection for Location is required';
                END
				if @Other=1 and (@OtherNote is null or @OtherNote='')
					EXEC p_EHR_Incomplete @moduleKey, 'OtherNote', 'Must fill Note (Other)';	  
				END
				
			  
			 END
	ELSE IF @action = 'D'

		UPDATE	t_EHR_Thermoregulation
		SET		Status = 'I'
				,DeactivateBy = @userID
				,DeactivateDate = @actionDate
		FROM	t_EHR_Thermoregulation
		WHERE	ChartKey  = @chartKey 
		AND		Status IN ('A', 'D')
		AND		ModuleKey = @moduleKey
		
	RETURN
END TRY
BEGIN CATCH

	EXEC p_RethrowError;

	RETURN -1;
END CATCH;

GO

EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 5/25/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_Thermoregulation'
GO
