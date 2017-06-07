IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CreateWorkflowFromTemplate') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CreateWorkflowFromTemplate;
GO
-- =============================================================================================================
-- Author:			Dan Bonelli
-- Create date:		1/14/15
-- Description:		Creates a new workflow from a template
--				  
-- Parameters		
--					ChartKey:				Workflow key.  For Create, the resulting WorkflowKey
--											is passed back through this parameter.
--
--					WorkflowTemplateKey:	WorkflowTemplate to be used as template for new workflow.
--													
--					WorkflowOrder:			Order that workflow appears in the UI
--
--					AreaKey:				Area this workflow belongs to. If null, use the default
--											from the WorkflowTemplate.  If not, use this value.
--
--					UserID:					User ID of record for this operation. 
--
--					WorkflowKey:			Key of the newly created workflow
-- Edit date:		6/18/15 by Susan
-- Changed:			Add BundleKey to t_EHR_Module
-- Edit date:		6/24/15 by Susan
-- Changed:			Remove AreaKey = @AreaKey clause when calculating WorkflowOrder, otherwise WorkflowOrder will always be 1.
-- Edit date:		6/30/15 by Mike
-- Changed:			Added in the logic for the Questions module
-- Edit date:		3/11/2016 by Bill
-- Changed:			Add ConsentID
-- =============================================================================================================
CREATE PROCEDURE p_EHR_CreateWorkflowFromTemplate
	@ChartKey						int
	,@BundleKey						int -- pass null if not part of a bundle
	,@WorkflowTemplateKey			int
	,@AreaKey						int
	,@UserID						varchar(60)
	,@ActionDate					datetime
	,@WorkflowKey					int OUTPUT
--WITH ENCRYPTION

AS
	
SET NOCOUNT ON;

BEGIN TRY
	-- Sanity checks: see if user passed in a WorkflowTemplateKey that didn't exist, etc...
	IF NOT EXISTS(	SELECT	*
					FROM	t_EHR_Chart
					WHERE	ChartKey = @ChartKey)
		RAISERROR('ChartKey specified does not exist', 16, 1)

	IF NOT @BundleKey IS NULL AND NOT EXISTS(	SELECT	*
												FROM	t_EHR_Bundle
												WHERE	BundleKey = @BundleKey)
		RAISERROR('BundleKey specified does not exist', 16, 1)

	DECLARE @requiresBundle BIT = 0;
	EXEC p_EHR_WorkflowTemplateRequiresBundle @WorkflowTemplateKey, @ChartKey, @requiresBundle OUTPUT;
	IF @BundleKey IS NULL AND @requiresBundle = 1
		RAISERROR('BundleKey not specified, yet workflow requires bundle', 16, 1)

	IF NOT EXISTS(	SELECT	*
					FROM	t_EHR_WorkflowTemplate
					WHERE	WorkflowTemplateKey = @WorkflowTemplateKey)
		RAISERROR('WorkflowTemplateKey specified does not exist', 16, 1)

	-- Calculate WorkflowOrder based on how many other workflows are in the chart
	DECLARE @workflowCount	INT;
	SET @workflowCount	=	(	SELECT COUNT(*) 
								FROM t_EHR_Workflow 
								WHERE ChartKey = @ChartKey
--								AND AreaKey = @AreaKey 
							);

	DECLARE @workflowName VARCHAR(50)
	SELECT	@workflowName = WorkflowTemplateName
	FROM	t_EHR_WorkflowTemplate 
	WHERE	WorkflowTemplateKey = @WorkflowTemplateKey; 

	DECLARE @watCount	INT;
	SET @watCount		=	(	SELECT COUNT(*) 
								FROM t_EHR_Workflow 
								WHERE ChartKey = @ChartKey
								AND AreaKey = @AreaKey
								AND WorkflowName LIKE @workflowName + '%'
								AND [Status] = 'A' 
							);

	-- Copy workflow template values into new workflow		
	INSERT t_EHR_Workflow ( ChartKey
							,BundleKey
							,WorkflowTemplateKey
							,WorkflowName						   
							,WorkflowDescription
							,WorkflowOrder
							,AreaKey
							,CreateBy 
							,Complete  ) 
	SELECT 	@ChartKey
			,@BundleKey
			,@WorkflowTemplateKey
			,WorkflowTemplateName + CASE WHEN @watCount > 0 THEN ' ' + CAST(@watCount + 1 AS VARCHAR) ELSE '' END
			,WorkflowTemplateDescription
			,@workflowCount + 1
			,DefaultAreaKey
			,@UserID
			,0
	FROM	t_EHR_WorkflowTemplate
	WHERE	WorkflowTemplateKey = @WorkflowTemplateKey	
	AND		Status = 'A'


	SET @WorkflowKey = SCOPE_IDENTITY()		

	-- For each module in the workflow template, create a corresponding record in t_EHR_Module and call
	--  the CRUD procedure for the module template.
	DECLARE @ModuleTemplateKey			INT
			,@WorkflowModuleTemplateKey	INT -- RFU, in case we need to fish anything else out of the workflowmoduletemplate record
			,@ModuleOrder				INT
			,@QuestionnaireTemplateKey	INT
			,@TitleOverride				VARCHAR(128)
			,@ConsentID					INT
			,@AreaFilter				INT;

	DECLARE mod_cursor CURSOR LOCAL FOR
		SELECT	wmt.ModuleTemplateKey
				,wmt.WorkflowModuleTemplateKey
				,wmt.ModuleOrder
				,CASE
					WHEN NOT mt.QuestionnaireTemplateKey IS NULL THEN mt.QuestionnaireTemplateKey -- module that contains a fixed questionnaire, never varies depending on context
					ELSE wmt.QuestionnaireTemplateKey -- the questions module or Patient Education, the questionnaire varies depending on the context.
				 END
				,wmt.TitleOverride -- for the questions module, need a sensible title for any given
				,wmt.ConsentID
				,wmt.AreaFilter
		FROM	t_EHR_WorkflowModuleTemplate wmt 			
		JOIN	t_EHR_ModuleTemplate mt
		ON		wmt.ModuleTemplateKey = mt.ModuleTemplateKey
		WHERE	wmt.[Status] = 'A' 
		AND		mt.[Status] = 'A'
		AND		wmt.WorkflowTemplateKey = @WorkflowTemplateKey
		ORDER BY wmt.ModuleOrder;

	DECLARE @HeaderTemplateKey			INT				
	DECLARE @centerID INT; SELECT @centerID = CenterID FROM t_EHR_Chart WHERE ChartKey = @ChartKey;

	SELECT @HeaderTemplateKey=ModuleTemplateKey FROM t_EHR_ModuleTemplate WHERE ModuleDesignID='000' AND ModuleVersionNumber=1 AND CenterID = @centerID

	EXEC p_EHR_AddModuleToWorkflow 	@WorkflowKey
									,@HeaderTemplateKey	
									,NULL   -- workflowModuleTemplateKey
									,NULL   -- inactiveModuleKey
									,@UserID
									,@ActionDate
									,1
									,NULL
									,NULL
									,NULL
									,NULL;

	OPEN mod_cursor
	FETCH NEXT FROM mod_cursor INTO @ModuleTemplateKey, @WorkflowModuleTemplateKey, @ModuleOrder, @QuestionnaireTemplateKey, @TitleOverride, @ConsentID, @AreaFilter;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ModuleOrder = @ModuleOrder + 1;		-- Because we are artificially inserting the workflow header as a module, the order needs to be offset by one

		EXEC p_EHR_AddModuleToWorkflow 	@WorkflowKey
										,@ModuleTemplateKey	
										,@WorkflowModuleTemplateKey
										,NULL   -- inactiveModuleKey
										,@UserID
										,@ActionDate
										,@ModuleOrder
										,@QuestionnaireTemplateKey
										,@ConsentID
										,@TitleOverride
										,@AreaFilter;

		FETCH NEXT FROM mod_cursor INTO @ModuleTemplateKey, @WorkflowModuleTemplateKey, @ModuleOrder, @QuestionnaireTemplateKey, @TitleOverride, @ConsentID, @AreaFilter;
	END
	CLOSE mod_cursor
	DEALLOCATE mod_cursor

	RETURN;
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH;

GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'Rev Date: 6/30/15'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CreateWorkflowFromTemplate'
GO
