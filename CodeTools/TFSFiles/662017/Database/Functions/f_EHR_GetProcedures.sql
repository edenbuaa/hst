IF OBJECT_ID (N'dbo.f_EHR_GetProcedures', N'FN') IS NOT NULL
          DROP FUNCTION dbo.f_EHR_GetProcedures
GO

CREATE FUNCTION dbo.f_EHR_GetProcedures (	
	@chartKey INT
	,@visitKey  INT
	,@primary BIT = NULL
)
RETURNS VARCHAR(1024)
--WITH ENCRYPTION, EXECUTE AS CALLER
AS
	
BEGIN
	DECLARE @results VARCHAR(1024)
	
	-- reused the existing UDF: f_EHR_GetServiceName
	SELECT 	@results = COALESCE(@results + '; ', '') + ProceduresName 
		FROM (SELECT dbo.f_EHR_GetServiceName(ProcedureModifier, ProcedureDescription) as ProceduresName
	FROM	t_EHR_PerformedProcedure
	WHERE	ChartKey = @chartKey
	AND		[Status] = 'A') A

	IF (@results IS NULL)
		SELECT 	@results =  COALESCE(@results + '; ', '') + ProceduresName 
		FROM (SELECT dbo.f_EHR_GetServiceName(ProcedureModifier, ProcedureDescription) as ProceduresName
		FROM 	t_EHR_ScheduledProcedure
		WHERE 	ChartKey = @chartKey
		AND 	[Status] = 'A') A

	IF (@results IS NULL)
		SELECT 	@results = dbo.f_EHR_GetPathwaysProceduresByVisitKey(@visitKey);

	RETURN @results

END;
GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'Rev Date: 3/18/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'FUNCTION' ,  @level1name = 'f_EHR_GetProcedures'
GO
