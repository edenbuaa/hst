
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_ChartDesigner_AddQuestionToQuestionnaireTemplate') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_ChartDesigner_AddQuestionToQuestionnaireTemplate;
GO

-- =============================================================================================================
-- Author:			Roopa
-- Create date:		5/2/16
-- Description:		Adds a Questionnaire Template
--				  
	
-- =============================================================================================================


CREATE PROCEDURE p_EHR_ChartDesigner_AddQuestionToQuestionnaireTemplate
	@QuestionnaireTemplateKey		INT
	,@QuestionTemplateKey			INT
	,@Ordinal						INT	
	,@Required						BIT
	,@CustomTemplate				VARCHAR(60)
WITH ENCRYPTION

AS
	
SET NOCOUNT ON;
				
		INSERT t_EHR_QuestionnaireQuestionTemplate(QuestionnaireTemplateKey,QuestionTemplateKey,Ordinal,[Required],CustomTemplate)
		SELECT @QuestionnaireTemplateKey,@QuestionTemplateKey,@Ordinal,@Required,@CustomTemplate
		

	
GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'Rev Date: 5/31/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_ChartDesigner_AddQuestionToQuestionnaireTemplate'
GO
