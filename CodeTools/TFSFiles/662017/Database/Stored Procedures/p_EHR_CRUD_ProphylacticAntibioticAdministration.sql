IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_ProphylacticAntibioticAdministration') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_ProphylacticAntibioticAdministration;
GO

-- =============================================================================================================
-- Author:			Roopa Rao
-- Create date:		03/15/16
-- Description:		Creates/Reads/Deactivates data row for the Prophylactic Medication Adminstration Module (083)
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
CREATE PROCEDURE p_EHR_CRUD_ProphylacticAntibioticAdministration
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

	DECLARE @areaName		VARCHAR(24)
	DECLARE @areaKey		INT
		
	IF @action = 'T'
		BEGIN
		SELECT	*
		FROM(VALUES
			 ('t_EHR_MedicationAdministration',				NULL,	1)
			,('t_EHR_MedicationAdministrationDetail',		NULL,	0)		
			,('v_EHR_UserStaff',							NULL,   1)
			,('t_EHR_UnitOfMeasure',						NULL,   0)
			,('t_EHR_AllergyChartDetail',					NULL,   0)
			)
		AS	temp (TableName, ResultName, SingleRow)
		RETURN;
		END
	
	DECLARE @SetMax INT
	SELECT  @areaKey= AreaKey 
	FROM [t_EHR_Workflow] 
	WHERE [WorkflowKey]=@workflowKey
		
		--Create data
	IF @action = 'C'
		
		BEGIN	
		
				/* Just set the isDirty flag, Prophylactic Antibiotic Medication Administration BLOC is incomplete if there are medications not administered
				if there are no medications, does not require any user interaction to be complete */		
				-- Nevermind
			--UPDATE t_EHR_Module SET
			--IsDirty=1
			--WHERE ModuleKey=@moduleKey		
						
			-- Create a new row in t_EHR_MedicationAdministration for this module (since that is module scoped)
			IF NOT EXISTS
			( SELECT 1 FROM t_EHR_MedicationAdministration 
			  WHERE ModuleKey=@moduleKey
			  )
				 INSERT t_EHR_MedicationAdministration 
				 (
				 ChartKey,
				 WorkflowKey,
				 ModuleKey,
				 CreateDate,
				 CreateBy
				 )							
				VALUES
				(
				 @chartKey,
				 @workflowKey,
				 @moduleKey,
				 @actionDate,
				 @userID
				 )					
					
											 
					-- Insert ProphylacticAntibiotic order medications if any 					
						
			INSERT  t_EHR_MedicationAdministrationDetail
			 (
			 ChartKey,
			 WorkflowKey,
			 ModuleKey,
			 OrderMedicationKey,
			 ProphylacticAntibiotic,
			 MedicationID,
			 MedicationIDType,
			 DrugCheckMedicationID,
			 DrugCheckMedicationIDType,
			 MedicationName,
			 Dose,
			 FormName,
			 RouteKey,
			 Route,
			 BodySiteKey,
			 BodySite,
			 Notes,
			 CreateBy
			 )
			SELECT 
			@chartKey,
			@workflowKey,
			@moduleKey,
			OrderMedicationKey,
			1,
			MedicationID,
			MedicationIDType,
			DrugCheckMedicationID, 
			DrugCheckMedicationIDType,
			MedicationName,
			Dose,
			FormName,
			RouteKey,
			Route,
			BodySiteKey,
			BodySite,
			Notes,
			@userID 
			FROM t_EHR_OrderMedication 
			WHERE  ProphylacticAntibiotic=1 
			AND (PhysicianSigned=1 OR VerbalOrder=1) 
			AND Status='A' AND 
			ChartKey=@ChartKey AND -- Disregard Area/ Workflow
			[OrderMedicationKey] 
			NOT IN 
			(
			SELECT OrderMedicationKey
			FROM t_EHR_MedicationAdministrationDetail
			WHERE ChartKey=@ChartKey 
			AND OrderMedicationKey IS NOT NULL
			)
																													
									
		END

	ELSE IF @action ='V'
	BEGIN

		IF dbo.f_EHR_IsModuleNA(@moduleKey) = 1
		RETURN;

		IF  EXISTS
		(
				SELECT 1
				FROM	t_EHR_MedicationAdministrationDetail
				WHERE	ChartKey= @chartKey
				AND		ProphylacticAntibiotic=1
				AND		AdministrationTime IS NULL	
				AND		Status='A'
		)
		EXEC p_EHR_Incomplete @moduleKey, 't_EHR_MedicationAdministration', 'Must administer the medications present or delete them';
	END
	
	ELSE IF @action = 'S'
	BEGIN
		-- Grab any new ProphylacticAntibiotic order medications if any 	
			INSERT  t_EHR_MedicationAdministrationDetail 
			(ChartKey,
			WorkflowKey,
			ModuleKey,
			OrderMedicationKey,
			ProphylacticAntibiotic,
			MedicationID,
			MedicationIDType,
			DrugCheckMedicationID,
			DrugCheckMedicationIDType,
			MedicationName,
			Dose,
			FormName,
			RouteKey,
			[Route],
			BodySiteKey,
			BodySite,
			Notes,
			CreateBy)
			OUTPUT	'I', inserted.*,inserted.*	
			INTO	#t_EHR_MedicationAdministrationDetail_Audit
			OUTPUT	inserted.*
			SELECT
			@chartKey,
			@workflowKey,
			@moduleKey,
			OrderMedicationKey,
			1,
			MedicationID,
			MedicationIDType,
			DrugCheckMedicationID,
			DrugCheckMedicationIDType,
			MedicationName,
			Dose,
			FormName,
			RouteKey,
			Route,BodySiteKey,BodySite,Notes,'hsta'
			FROM t_EHR_OrderMedication 
			WHERE  ProphylacticAntibiotic=1 
			AND Status='A' 
			AND (PhysicianSigned=1 OR VerbalOrder=1) 
			AND ChartKey=@ChartKey AND -- Disregard Area/ Workflow
			[OrderMedicationKey] 
			NOT IN 
			(
			SELECT OrderMedicationKey 
			FROM t_EHR_MedicationAdministrationDetail 
			WHERE ChartKey=@ChartKey 
			AND OrderMedicationKey 
			IS NOT NULL
			)
						
			INSERT INTO #UpdateLog VALUES (@moduleKey, @workflowKey,'t_EHR_MedicationAdministrationDetail', NULL, NULL, 'I')
		
			
			-- Update Medications if they have changed out in the and they haven't been touched yet in the current module (i.e. 083)			
			UPDATE toma  SET 
			toma.Status=tom.Status, 
			toma.Dose=tom.Dose,
			toma.RouteKey= tom.RouteKey,
			toma.Route= tom.Route, 
			toma.BodySiteKey= tom.BodySiteKey, 
			toma.BodySite=tom.BodySite,
			toma.Notes=tom.Notes
			OUTPUT	'U', deleted.*, inserted.* 
			INTO	#t_EHR_MedicationAdministrationDetail_Audit
			OUTPUT	inserted.*
			FROM t_EHR_OrderMedication tom  
			JOIN t_EHR_MedicationAdministrationDetail toma 
			ON tom.OrderMedicationKey = toma.OrderMedicationKey 
			WHERE  toma.ChartKey=@ChartKey 
			AND toma.ProphylacticAntibiotic=1 
			AND toma.ChangeDate IS NULL
			AND toma.AdministrationTime IS NULL
			AND 
			(
			toma.Status<>tom.Status OR
			toma.Dose<>tom.Dose OR
			toma.RouteKey<>tom.RouteKey OR
			toma.Route<> tom.Route OR
			toma.BodySiteKey<> tom.BodySiteKey OR
			toma.BodySite<>tom.BodySite OR
			toma.Notes<>tom.Notes
			)
			
			INSERT INTO #UpdateLog VALUES (@moduleKey, @workflowKey,'t_EHR_MedicationAdministrationDetail', NULL, NULL, 'U')
			

	END

	ELSE IF @action = 'R' OR @action = 'A'
		BEGIN
					
			
			SELECT *
			FROM	t_EHR_MedicationAdministration
			WHERE	ChartKey= @chartKey
			AND     ModuleKey = @moduleKey
			AND ((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))  -- 'A' does not filter on Status
			order by (CASE WHEN ChangeDate IS NOT NULL THEN ChangeDate WHEN ChangeDate IS NULL THEN CreateDate  END)DESC 
			
			SELECT *
			FROM	t_EHR_MedicationAdministrationDetail
			WHERE	ChartKey= @chartKey
			AND		ProphylacticAntibiotic=1
			AND ((@action='R' AND Status IN ('A', 'D')) OR (@action='A'))  -- 'A' does not filter on Status 			
			order by (CASE WHEN ChangeDate IS NOT NULL THEN ChangeDate WHEN ChangeDate IS NULL THEN CreateDate  END)DESC

			SELECT	CenterID,
					[UserID],
					[StaffID],
					[StaffName],
					[StaffIDType] 	
					FROM	v_EHR_UserStaff 
					WHERE	UserID = @UserID AND CenterID= @centerID
			
			SELECT UnitOfMeasure,
				  UnitOfMeasureDescription 
				  FROM t_EHR_UnitOfMeasure 
				  WHERE Status  = 'A'

			SELECT * FROM t_EHR_AllergyChartDetail 
			WHERE  
			ChartKey= @ChartKey			
			AND ((@action='R' AND Status ='A') OR (@action='A'))  -- 'A' does not filter on Status 
		
		END
		
	ELSE IF @action = 'D'
		BEGIN

			UPDATE t_EHR_MedicationAdministration
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			WHERE   ChartKey = @chartKey
			AND     ModuleKey = @moduleKey

			
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
     ,@value = N'Rev Date: 03/17/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_ProphylacticAntibioticAdministration'
GO
	
		
 	
	