
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_ChartDesigner_GetQuestionnaireTemplate') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_ChartDesigner_GetQuestionnaireTemplate
GO
-- =============================================================================================================
-- Author:			Roopa
-- Create date:		5/5/16
-- Description:		Get GetQuestionnaireTemplate details on supplying a key
-- =============================================================================================================
CREATE PROCEDURE p_EHR_ChartDesigner_GetQuestionnaireTemplate
	@QuestionnaireTemplateKey INT
	
	
WITH ENCRYPTION

AS
	
SET NOCOUNT ON;

BEGIN TRY



SELECT QuestionnaireTemplateKey,QuestionnaireName,[QuestionnaireDesignID],Protected,Category,Status  FROM t_EHR_QuestionnaireTemplate WHERE QuestionnaireTemplateKey=@QuestionnaireTemplateKey ORDER BY CreateDate DESC

Select 
tq.QuestionTemplateKey,
tq.QuestionID,
tq.QuestionText,
tq.ShortName,
tq.QuestionTypeID,
tqt.QuestionTypeName,
tqq.Required AS RequiredInQuestionnaire,
tqq.CustomTemplate,
tqq.Ordinal,
tqq.CustomTemplate,
tq.Protected  
FROM  t_EHR_QuestionTemplate tq 
JOIN t_EHR_QuestionType tqt ON tqt.QuestionTypeID=tq.QuestionTypeID
JOIN t_EHR_QuestionnaireQuestionTemplate tqq ON tq.QuestionTemplateKey=tqq.QuestionTemplateKey WHERE tq.ParentQuestionTemplateKey IS NULL
AND tq.Status = 'A' AND tqq.QuestionnaireTemplateKey=@QuestionnaireTemplateKey ORDER BY tqq.Ordinal

SELECT QuestionTemplateKey,ParentQuestionTemplateKey,QuestionText,Ordinal FROM t_EHR_QuestionTemplate tq WHERE ParentQuestionTemplateKey IN 
(SELECT QuestionTemplateKey FROM t_EHR_QuestionnaireQuestionTemplate WHERE QuestionnaireTemplateKey=@QuestionnaireTemplateKey
AND STATUS='A') AND STATUS='A'  ORDER BY Ordinal



RETURN
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH
GO
EXEC sp_addextendedproperty 
     N'TFS-Version'
     ,@value = N'Rev Date: 5/5/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_ChartDesigner_GetQuestionnaireTemplate'
GO	
	
	

