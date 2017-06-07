IF OBJECT_ID (N'dbo.f_EHR_PatientLocation', N'FN') IS NOT NULL
          DROP FUNCTION dbo.f_EHR_PatientLocation
GO

-- =======================================================================
-- Author: Bill Teng
-- Date: 12/29/16
-- Get Patient Location's Color Number
-- =======================================================================
CREATE FUNCTION dbo.f_EHR_PatientLocation (
	@centerID INT
	,@chartKey INT
)
RETURNS INT
--WITH ENCRYPTION, EXECUTE AS CALLER
AS
	
BEGIN
	DECLARE @location CHAR(10) = NULL;
	DECLARE @result INT = NULL;
	DECLARE @isRegNextWorkflowRoomIN TINYINT = NULL;

	-- short circut the process if patient is discharged.
	-- Discharge Area: Changed the logic to 058 BLOC, May 2, 2017
	DECLARE @complete BIT, @completedBy VARCHAR(50)
	SELECT	top 1 
			@complete = Complete, 
			@completedBy = CompletedBy 
	FROM	t_EHR_Module M
	JOIN	t_EHR_ModuleTemplate MT
	ON		M.ModuleTemplateKey = MT.ModuleTemplateKey
	WHERE	MT.ModuleDesignID = '058'
	AND		M.ChartKey = @chartKey

	--IF (dbo.f_EHR_AreaLocationInOut(10, @chartKey, 'IN') = 1 AND dbo.f_EHR_AreaLocationInOut(10, @chartKey, 'OUT') = 0)			
	IF @complete = 1 AND @completedBy IS NOT NULL
	BEGIN
			SELECT	@result = P.RowColor 
			FROM	t_EHR_CenterConfiguration C
			JOIN	t_PatientLocation P
			ON		C.DischargeLocation = P.Location
			AND		C.CenterID = P.CenterID
			WHERE	C.CENTERID = @centerID;

			RETURN	ISNULL(@result, 0);
	END;

	-- all other areas except registration: take the most recent room in time
	WITH rt (InLocation, InTimeIndex)
	AS
	(
		SELECT	rt.[Location]
				,ROW_NUMBER() OVER ( PARTITION BY rt.Chartkey ORDER BY rt.RoomTime DESC)
		FROM	t_EHR_RoomTime rt
		JOIN	t_EHR_Workflow w
		ON		w.WorkflowKey = rt.WorkflowKey
		WHERE	rt.Chartkey = @chartKey
		AND		rt.RoomTime IS NOT NULL
		AND		rt.InOut = 'IN'
		AND		rt.[Status] = 'A'
		AND		w.AreaKey <> 11
	)
	SELECT	@location = InLocation
	FROM	rt
	WHERE	InTimeIndex = 1;

	IF @location IS NOT NULL
	BEGIN
		SELECT	@result =RowColor 
		FROM	t_PatientLocation
		WHERE	[Location] = @location
		AND		CenterID = @centerID

		RETURN	ISNULL(@result, 0);
	END

	-- Registration Area
	IF (dbo.f_EHR_AreaLocationInOut(11, @chartKey, 'IN') = 1 AND dbo.f_EHR_AreaLocationInOut(11, @chartKey, 'OUT') = 0)				 
	BEGIN
			--PATIENT ON THE REGISTRATION NOW
			SELECT	@result = P.RowColor 
			FROM	t_EHR_CenterConfiguration C
			JOIN	t_PatientLocation P
			ON		C.RegistrationLocation = P.Location
			AND		C.CenterID = P.CenterID
			WHERE	C.CENTERID = @centerID

			RETURN	ISNULL(@result, 0);
	END;	

	-- Registration Complete Color
	IF (dbo.f_EHR_AreaLocationInOut(11, @chartKey, 'IN') = 1 AND dbo.f_EHR_AreaLocationInOut(11, @chartKey, 'OUT') = 1 AND dbo.f_EHR_IsRegNextWorkflowRoomIn(@centerID, @chartKey) = 0)				 
	BEGIN
		SELECT	@result = P.RowColor 
		FROM	t_EHR_CenterConfiguration C
		JOIN	t_PatientLocation P
		ON		C.RegistrationCompleteLocation = P.Location
		AND		C.CenterID = P.CenterID
		WHERE	C.CENTERID = @centerID

		RETURN	ISNULL(@result, 0);
	END

	RETURN	ISNULL(@result, 0);
END;
GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'Rev Date: 12/29/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'FUNCTION' ,  @level1name = 'f_EHR_PatientLocation'
GO
