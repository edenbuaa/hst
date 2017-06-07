IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_Allergy') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_Allergy;
GO

-- =============================================================================================================
-- Author:			Susan Taylor
-- Create date:		12/18/15
-- Design ID:		003
-- Description:		Creates/Reads/Deactivates data row for the Allergy Module
--				  
-- Parameters		action:					'T' -> Return list of tables that this proc returns
--
--											'C' -> Create a new record
--
--											'R' -> Reads the module data into result set. This can return more 
--													than one table.
--
--											'D' -> Deactivates specified row
--
--											'A' -> Reads the module data into the result set for Audit (which wants all rows even if they are not displayed)
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
-- =============================================================================================================
CREATE PROCEDURE p_EHR_CRUD_Allergy
	 @action			CHAR(1)
	,@centerID			INT
	,@chartKey			INT
	,@workflowKey		INT
	,@moduleKey			INT
	,@userID			VARCHAR(60)
	,@actionDate		SMALLDATETIME
-- WITH ENCRYPTION

AS
	
SET NOCOUNT ON;

BEGIN TRY
	IF @action = 'T'
		SELECT	*
		FROM(VALUES
			 ('t_EHR_AllergyChart',				NULL,	1)			
			,('t_EHR_AllergyChartDetail',		NULL,	1)
			,('t_EHR_AllergyModule',			NULL,	1)
			)
		AS	temp (TableName, ResultName, SingleRow)
	
	-- Create a new row for this chart and or module/workflow
	-- The allergy details and no-known allergy info is chart based, and the reviewed info is module/workflow based
	ELSE IF @action = 'C'
		BEGIN
			-- no allergy grid yet, so create grid data from pulling chart or past visits; and create 0 value for no know allergies
			IF NOT EXISTS(SELECT 1 FROM t_EHR_AllergyChart WHERE ChartKey = @chartKey AND Status = 'A')
			BEGIN
				DECLARE @PullingChartKey INT
				DECLARE @personKey INT
				SET @PullingChartKey = NULL
				DECLARE @hasAllergies BIT;
				DECLARE @hasLatexAllergy BIT
				SET @hasAllergies = 0;
				SET @hasLatexAllergy = 0

				SELECT	TOP 1 @personKey=PersonKey
				FROM	t_EHR_Chart
				WHERE	ChartKey=@chartKey

				-- determine if a chart exists with allergy information. In which case the most recent past visit or chart with any module reviewed data is used.
				-- The reviewed status and no-known allergy data is always set to 0 (for a newly created allergy module).
				SELECT	TOP 1 @PullingChartKey=c.ChartKey
				FROM	t_EHR_Chart c
				JOIN	t_EHR_AllergyModule am
				ON		am.ChartKey = c.ChartKey
				WHERE	c.PersonKey = @personKey
				AND		am.Reviewed = 1 
				AND		am.Status='A'
				AND		c.Status='A'
				ORDER BY am.ChangeDate DESC

				-- copy allergy data from appropriate chart to pull data from 
				IF @PullingChartKey IS NOT NULL
				BEGIN
					INSERT	t_EHR_AllergyChartDetail (ChartKey, AllergyClassID, AllergyName, AllergyOther, AllergyType, AllergyReactionKey, AllergyReaction, AllergySeverity, Notes, CreateDate, CreateBy)
					SELECT	ChartKey=@ChartKey, AllergyClassID, AllergyName, AllergyOther, AllergyType, AllergyReactionKey, AllergyReaction, AllergySeverity, Notes, CreateDate=@actionDate, CreateBy=@userID
					FROM	t_EHR_AllergyChartDetail acd
					WHERE	acd.ChartKey=@PullingChartKey 
					AND		acd.Status='A'

					IF ( @@ROWCOUNT > 0) SET @hasAllergies = 1;

					IF (@hasAllergies = 1 AND EXISTS (SELECT * from t_EHR_AllergyChartDetail WHERE ChartKey = @ChartKey AND Status = 'A' AND AllergyClassID=68) )
						SET @hasLatexAllergy = 1

				END				
				ELSE  -- Note: AllergyType 4 is "Unknown", AllergySeverity 4 is "Unknown"
				BEGIN
					INSERT t_EHR_AllergyChartDetail (ChartKey, AllergyOther, AllergyType, AllergySeverity, CreateDate, CreateBy)
					SELECT DISTINCT ChartKey=@ChartKey, AllergyComment, AllergyType=4, AllergySeverity=4, CreateDate=@actionDate, CreateBy=@userID
					FROM	t_Visit
					WHERE	PersonKey=@personKey
					AND		Allergy=1
					AND		COALESCE(AllergyComment,'') <> ''
					AND		AdmitDate < getDate()

					IF ( @@ROWCOUNT > 0) SET @hasAllergies = 1;
				END



				INSERT t_EHR_AllergyChart (ChartKey, NKA, CreateDate, CreateBy)
				VALUES (@chartKey, 0, @actionDate, @userID)		
						
				-- Allergy Alert shows if any allergies exist.
				IF NOT EXISTS(SELECT 1 FROM t_EHR_Alert WHERE ChartKey = @chartKey AND Title='Allergy' AND Status='A')
					INSERT t_EHR_Alert	(ChartKey, Title, IsSet, CreateDate, CreateBy)
					VALUES (@chartKey, 'Allergy', @hasAllergies, @actionDate, @userID)
				ELSE
					UPDATE	t_EHR_Alert
					SET		IsSet =  @hasAllergies

				-- Latex Alert shows if any latex allergies exist.
				IF NOT EXISTS(SELECT 1 FROM t_EHR_Alert WHERE ChartKey = @chartKey AND Title='Latex' AND Status='A')
					INSERT t_EHR_Alert	(ChartKey, Title, IsSet, CreateDate, CreateBy)
					VALUES (@chartKey, 'Latex', @hasLatexAllergy, @actionDate, @userID)
				ELSE
					UPDATE	t_EHR_Alert
					SET		IsSet =  @hasLatexAllergy

				-- Synchronize Allergy information between pathways and echart
				DECLARE @visitKey int
				DECLARE @alleryComment varchar(250)

				SELECT	@visitKey = VisitKey
				FROM	t_EHR_Chart
				WHERE	Chartkey = @chartKey

				SELECT  @alleryComment = AllergyComment
				FROM	t_Visit
				WHERE	VisitKey = @visitKey

				IF @alleryComment IS NOT NULL AND LEN(@alleryComment) > 0
				BEGIN
					INSERT INTO t_EHR_AllergyChartDetail(ChartKey,AllergyOther,AllergyType)
					VALUES(@chartKey, @alleryComment , 1)
				END


			END

			-- for all modules/workflow create 0 value for reviewed
			IF NOT EXISTS(SELECT 1 FROM t_EHR_AllergyModule WHERE ChartKey = @chartkey AND WorkflowKey = @workflowKey AND ModuleKey = @moduleKey AND [Status] = 'A')
				INSERT t_EHR_AllergyModule (ChartKey, WorkflowKey, ModuleKey, Reviewed, CreateDate, CreateBy)
				VALUES (@chartKey, @workflowKey, @moduleKey, 0, @actionDate, @userID)

			-- Changed so that Allergy Alerts no longer show ever.  May change this back to show
			-- AllergyAlert ToDo:  if decided that alerts no longer show, then do Allergy module infrastructure cleanup.
			--IF NOT EXISTS(SELECT 1 FROM t_EHR_Alert WHERE ChartKey = @chartKey AND Title='Allergy Review' AND Status='A')
			--	INSERT t_EHR_Alert	(ChartKey, Title, IsSet, CreateDate, CreateBy)
			--	VALUES (@chartKey, 'Allergy Review', 0, @actionDate, @userID)

		END

	ELSE IF @action = 'R' OR @action = 'A'
		BEGIN
			SELECT	*
			FROM	t_EHR_AllergyChart ac
			WHERE	ac.ChartKey = @chartKey		
			AND		( (@action='R' AND ac.Status IN ('A', 'D')) OR (@action='A') )	-- 'A' does not filter on Status
	

			SELECT	*
			FROM	t_EHR_AllergyChartDetail acd
			WHERE	acd.ChartKey = @chartKey
			AND		( (@action='R' AND acd.Status IN ('A', 'D')) OR (@action='A') )	-- 'A' does not filter on Status

			-- this table is really module based (not chart based, like the other tables in this CRUD
			SELECT	*
			FROM	t_EHR_AllergyModule am
			WHERE	ChartKey  = @chartKey
			AND		am.ModuleKey = @moduleKey		
			AND		am.WorkflowKey = @workflowKey		
			AND		( (@action='R' AND am.Status IN ('A', 'D')) OR (@action='A') )	-- 'A' does not filter on Status
	


		END

	-- Validate
	ELSE IF @action = 'V'
	BEGIN
		EXEC p_EHR_V_Allergy @centerID, @chartKey, @workflowKey, @moduleKey
	END
	ELSE IF @action = 'D'
		BEGIN
			UPDATE	t_EHR_AllergyChartDetail
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			WHERE	ChartKey  = @chartKey

			UPDATE	t_EHR_AllergyChart
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			WHERE	ChartKey  = @chartKey

			UPDATE	t_EHR_AllergyModule
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			WHERE	ChartKey  = @chartKey
			AND		WorkflowKey = @workflowKey
			AND		ModuleKey = @moduleKey


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
     ,@value = N'Rev Date: 12/18/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_Allergy'
GO