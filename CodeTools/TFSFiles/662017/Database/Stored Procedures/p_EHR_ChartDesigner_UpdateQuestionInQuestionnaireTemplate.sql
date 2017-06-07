
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_ChartDesigner_UpdateQuestionInQuestionnaireTemplate') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_ChartDesigner_UpdateQuestionInQuestionnaireTemplate;
GO


-- =============================================================================================================
-- Author:			Roopa
-- Create date:		9/16/16
-- Description:		Updates the  Question Template in the Questionnaire Template
--				  
	
-- =============================================================================================================

CREATE PROCEDURE p_EHR_ChartDesigner_UpdateQuestionInQuestionnaireTemplate
	@QuestionnaireTemplateKey		INT
	,@QuestionTemplateKey			INT
	,@Required						BIT
	,@Ordinal						INT
	,@CustomTemplate				VARCHAR(60)
WITH ENCRYPTION

AS
	
SET NOCOUNT ON;
	
	UPDATE t_EHR_QuestionnaireQuestionTemplate 
	SET Ordinal=@Ordinal,
	[Required]=@Required,
	ChangeDate=getDate() ,
	CustomTemplate=@CustomTemplate
	WHERE
	 QuestionnaireTemplateKey=@QuestionnaireTemplateKey AND QuestionTemplateKey=@QuestionTemplateKey

	
GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'Rev Date: 9/16/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_ChartDesigner_UpdateQuestionInQuestionnaireTemplate'
GO
