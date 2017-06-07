IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_Positioning') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_Positioning;
GO

-- =============================================================================================================
-- Author:			Darren Lou
-- Create date:		5/6/15
-- Description:		Creates/Reads/Deactivates data row for the Positioning module
--				  
-- Parameters		Action:					'C' -> Create a new record
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
--					actionDate:				Date action was requested
-- =============================================================================================================
CREATE PROCEDURE p_EHR_CRUD_Positioning
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
	IF @action = 'V'
	BEGIN
		DECLARE @positionKeyV INT
		DECLARE @safetyStrapApplied BIT, @sideRailsUp BIT, @coveredWithBlanket BIT, @coveredWithSheet BIT
		DECLARE	@pillowUnderKnees BIT, @pillowUnderAbdomen BIT, @paddedHeadrest BIT
		DECLARE @armsAtSide BIT, @armsTucked BIT, @armsCrossChest BIT, @armsAboveHead BIT
		DECLARE @armboard90Degrees BIT, @armboardGT90Degrees BIT, @armboardLT90Degrees BIT
		DECLARE @armsRestrained BIT, @armsPadded BIT, @armsOther BIT
		DECLARE @armsOtherText VARCHAR(1000)

		-- these values can't be null in db.  Set to 0 in case following select finds no record
		SET @safetyStrapApplied = 0
		SET @sideRailsUp = 0
		SET @coveredWithBlanket = 0
		SET @coveredWithSheet = 0
		SET @pillowUnderKnees = 0
		SET @pillowUnderAbdomen = 0
		SET @paddedHeadrest = 0
		SET @armsAtSide = 0
		SET @armsTucked = 0
		SET @armsCrossChest = 0
		SET @armsAboveHead = 0
		SET @armboard90Degrees = 0
		SET @armboardGT90Degrees = 0
		SET @armboardLT90Degrees = 0
		SET @armsRestrained = 0
		SET @armsPadded = 0
		SET @armsOther = 0


		SELECT	@positionKeyV = PositionKey,
				@safetyStrapApplied = SafetyStrapApplied,
				@sideRailsUp = SideRailsUp,
				@coveredWithBlanket = CoveredWithBlanket,
				@coveredWithSheet = CoveredWithSheet,
				@pillowUnderKnees = PillowUnderKnees,
				@pillowUnderAbdomen = PillowUnderAbdomen,
				@paddedHeadrest = PaddedHeadrest,
				@armsAtSide = ArmsAtSide,
				@armsTucked = ArmsTucked,
				@armsCrossChest = ArmsCrossChest,
				@armsAboveHead =ArmsAboveHead,
				@armboard90Degrees = Armboard90Degrees,
				@armboardGT90Degrees = ArmboardGT90Degrees,
				@armboardLT90Degrees = ArmboardLT90Degrees,
				@armsRestrained = ArmsRestrained,
				@armsPadded = ArmsPadded,
				@armsOther = ArmsOther,
				@armsOtherText = ArmsOtherText
		FROM	t_EHR_PatientPosition
		WHERE	ModuleKey = @moduleKey

		IF @positionKeyV IS NULL OR @positionKeyV <= 0
			EXEC p_EHR_Missing @moduleKey, 'Position'

		DECLARE @uncheckedCheckboxUnderPatientPositon BIT
		SET		@uncheckedCheckboxUnderPatientPositon = ~@safetyStrapApplied & ~@sideRailsUp & ~@coveredWithBlanket & ~@coveredWithSheet & ~@pillowUnderKnees & ~ @pillowUnderAbdomen & ~@paddedHeadrest

		DECLARE @uncheckedCheckboxUnderArms BIT
		SET @uncheckedCheckboxUnderArms = ~@armsAtSide & ~@armsTucked & ~@armsCrossChest & ~@armsAboveHead & ~@armboard90Degrees & ~@armboardGT90Degrees & ~@armboardLT90Degrees & ~@armsRestrained & ~@armsPadded & ~@armsOther 

		IF @uncheckedCheckboxUnderPatientPositon = 1
		BEGIN
			IF @uncheckedCheckboxUnderArms= 1
			BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 'SafefyComfort', 'At least one checkbox must be checked for "Safety/Comfort" and "Arms".'
				EXEC p_EHR_Incomplete @moduleKey, 'Arms', ''
			END
			ELSE
				EXEC p_EHR_Incomplete @moduleKey, 'SafefyComfort', 'At least one checkbox must be checked for "Safety/Comfort".';
		END
		ELSE IF @uncheckedCheckboxUnderArms= 1
            EXEC p_EHR_Incomplete @moduleKey, 'Arms', 'At least one checkbox must be checked for "Arms".'

		IF @armsOther = 1 AND ISNULL(@armsOtherText, '') = ''
			EXEC p_EHR_Missing @moduleKey, 'ArmsOtherText'
	END 
	ELSE IF @action = 'T'
		SELECT	*
		FROM(VALUES
			('t_EHR_PatientPosition',    NULL, 1)
			,('t_EHR_Position',			 NULL, 0)
			)
		AS	temp (TableName, ResultName, SingleRow);

	ELSE IF @action = 'R' OR @action = 'A'
	BEGIN
		SELECT	*
		FROM	t_EHR_PatientPosition
		WHERE	ChartKey  = @chartKey
		AND		((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))
		AND     ModuleKey = @moduleKey

		SELECT	[PositionKey]
				,[Position]
		FROM	t_EHR_Position
		WHERE	Status IN ('A', 'D')
		AND		CenterID = @centerID
	END
	-- Create a new row for this module
	ELSE IF @action = 'C'
	BEGIN
		DECLARE @positionKey INT;
		DECLARE @position	 VARCHAR(128);
		
		SELECT	@positionKey = ppc.PositionKey
				,@position = p.Position
		FROM	t_VisitService vs 
		JOIN	t_Visit v
		ON		vs.VisitKey = v.VisitKey
		JOIN	t_EHR_Chart c
		ON		c.VisitKey = v.VisitKey
		JOIN	t_VisitPhysician vp
		ON		vs.VisitKey = vp.VisitKey
		AND		vp.VisitServiceKey = vs.VisitServiceKey
		JOIN	t_Physician ph
		ON		vp.PhysicianID = ph.PhysicianID
		AND		ph.CenterID = v.CenterID
		JOIN    t_PhysicianPrefCard ppc
		ON		ppc.CenterID = v.CenterID
		AND		ppc.PhysicianID = ph.PhysicianID
		AND		ppc.ServiceCode = vs.ServiceCode
		JOIN    t_EHR_Position p
		ON		ppc.PositionKey = p.PositionKey
		WHERE   c.ChartKey = @chartKey
		AND		c.CenterID = @centerID
		AND		vs.PrimaryProcedure = 1
		ORDER BY vs.ServiceCode, vs.SortOrder

		-- yes, Module scoped, so always create
		INSERT t_EHR_PatientPosition (ChartKey, WorkflowKey, ModuleKey, PositionKey, Position, CreateBy)
		VALUES (@chartKey, @workflowKey, @moduleKey, @positionKey, @position, @userID);

	END
	ELSE IF @action = 'D'
	-- should never be called - only chart closing proc will set to I, if module was removed from chart.
	-- module scoped, so let's use clustered index for table
		UPDATE	t_EHR_PatientPosition
		SET		Status = 'I'
				,DeactivateDate = @actionDate
				,DeactivateBy = @userID
		WHERE	ChartKey  = @chartKey
		AND		Status IN ('A', 'D')
		AND     ModuleKey = @moduleKey
							
	RETURN;
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH;

GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'Rev Date: 5/6/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_Positioning'
GO
