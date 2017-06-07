IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_CommunicationLog') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_CommunicationLog;
GO

-- =============================================================================================================
-- Author:			Andy Jia
-- Create date:		8/13/15
-- Description:		Creates/Reads/Deactivates data row for the Communication Log module
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
CREATE PROCEDURE p_EHR_CRUD_CommunicationLog
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

DECLARE @PersonKey INT
DECLARE @userPermissions table(
	UserID CHAR(40) NULL,
    FunctionKey int NOT NULL,
	CenterID INT NULL,
    CanCreate INT NOT NULL DEFAULT(0),
    CanRetrieve INT NOT NULL DEFAULT(0),
	CanUpdate INT NOT NULL DEFAULT(0),
    CanDelete INT NOT NULL DEFAULT(0));

BEGIN TRY
	IF @action = 'T'

		SELECT * 
		FROM(VALUES
			('t_Person',						NULL,		1)
			,('v_EHR_UserFullName',				NULL,		1)
			,('v_EHR_UserStaff',				NULL,		1)
			,('t_UserPermission',				NULL,		1)
			,('t_EHR_CommunicationLogDetail',	NULL,		0)
			,('t_EHR_CommunicationLog',			NULL,		1)
			)
			AS	temp (TableName, ResultName, SingleRow)

	ELSE IF @action = 'R' OR @action = 'A'
		BEGIN

			SELECT	@PersonKey = PersonKey							
			FROM	t_EHR_Chart 
			WHERE	ChartKey = @chartKey 
			AND		Status IN ('A','D')

			SELECT	*
			FROM	t_Person 
			WHERE	PersonKey = @PersonKey 

			SELECT	CenterID
					,UserID
					,FullName
			FROM	v_EHR_UserFullName
			WHERE	UserID = @userID

			SELECT	*
			FROM	v_EHR_UserStaff
			WHERE	UserID = @userID
			AND		CenterID = @centerID

			INSERT INTO @userPermissions (FunctionKey,CanCreate,CanRetrieve,CanUpdate,CanDelete)
			EXEC p_GetEffectiveUserPermission @centerID, @userID

			SELECT UserID = @userID, FunctionKey, CenterID = @centerID, CanCreate, CanRetrieve, CanUpdate, CanDelete FROM @userPermissions
			WHERE FunctionKey = 805

			SELECT	*
			FROM	t_EHR_CommunicationLogDetail
			WHERE	ChartKey  = @chartKey
			AND		((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))
			AND     ModuleKey = @moduleKey

			SELECT	*
			FROM	t_EHR_CommunicationLog
			WHERE	ChartKey  = @chartKey
			AND		((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))
			AND     ModuleKey = @moduleKey
		END
	-- Create a new row for this module
	ELSE IF @action = 'C'
	BEGIN
		-- yes, Module scoped, so always create
		DECLARE @LanguageCode CHAR(2)
		DECLARE @Description VARCHAR(30)
		DECLARE @TempLanguageCode CHAR(2)

		SELECT	@TempLanguageCode = DefaultPreferredLanguageCode
		FROM	t_EHR_ChartConfiguration
		WHERE	CenterID = @centerID
		SET  @TempLanguageCode = ISNULL(@TempLanguageCode, 'EN')

		SELECT @LanguageCode = LanguageCode
				,@Description = [Description]
		FROM t_LanguageCode Where LanguageCode = @TempLanguageCode

		INSERT t_EHR_CommunicationLog (ChartKey, WorkflowKey, ModuleKey, PrimaryLanguageCode, PrimaryLanguangeDescription, CreateBy)
		VALUES (@chartKey, @workflowKey, @moduleKey, @LanguageCode, @Description, @userID);

	END
	ELSE IF @action = 'V'
		BEGIN
			IF dbo.f_EHR_IsModuleNA(@moduleKey) = 0
			BEGIN
				DECLARE @PrimaryLanguageCode CHAR(2)
				DECLARE @IncorrectLanguage BIT
				DECLARE @UnableToContactPatient BIT
				DECLARE @CorrectLanguangeDescription VARCHAR(30)

				SELECT @IncorrectLanguage = IncorrectLanguage, @UnableToContactPatient = UnableToContactPatient,
					   @CorrectLanguangeDescription = CorrectLanguangeDescription, @PrimaryLanguageCode = PrimaryLanguageCode
				FROM t_EHR_CommunicationLog 
				WHERE ChartKey = @chartKey AND WorkflowKey = @workflowKey AND ModuleKey = @moduleKey AND [Status] = 'A'


				IF EXISTS(SELECT * FROM [dbo].[t_EHR_CommunicationLogDetail] WHERE CommunicationStatus = 4 AND ModuleKey = @moduleKey AND [Status] = 'A')
				BEGIN
					IF @UnableToContactPatient = 0 AND dbo.f_EHR_IsPAM(@centerID, @moduleKey, 'PrimaryLanguageCode', @PrimaryLanguageCode) = 0 
					BEGIN
						EXEC p_EHR_Incomplete @moduleKey, 'PrimaryLanguangeDescription', 'Primary Language must be filled out'
					END
				END
				ELSE IF @UnableToContactPatient = 0
				BEGIN
					EXEC p_EHR_Incomplete @moduleKey, 't_EHR_CommunicationLog', 'Must check "N/A" or have at least one completed call or "Unable to contact Patient" checkbox selected to complete the BLOC.'
				END

				
				IF @IncorrectLanguage = 1
				BEGIN
					IF dbo.f_EHR_IsPAM(@centerID, @moduleKey, 'CorrectLanguangeDescription', @CorrectLanguangeDescription) = 0
					BEGIN
						EXEC p_EHR_Incomplete @moduleKey, 'CorrectLanguangeDescription', 'Correct Language must be filled out'
					END
				END
				
			END
		END
	ELSE IF @action = 'D'
	BEGIN
	---- should never be called - only chart closing proc will set to I, if module was removed from chart.
	---- module scoped, so let's use clustered index for table
		UPDATE	t_EHR_CommunicationLog
		SET		Status = 'I'
				,DeactivateDate = @actionDate
				,DeactivateBy = @userID
		WHERE	ChartKey  = @chartKey
		AND		Status IN ('A', 'D')
		AND     ModuleKey = @moduleKey

		UPDATE	t_EHR_CommunicationLogDetail
		SET		Status = 'I'
				,DeactivateDate = @actionDate
				,DeactivateBy = @userID 	
		WHERE	ChartKey  = @chartKey
		AND		Status IN ('A', 'D')
		AND     ModuleKey = @moduleKey
	END		
							
	RETURN;
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH;

GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'Rev Date: 3/31/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_CommunicationLog'
GO