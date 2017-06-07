:SETVAR tableName "t_EHR_QuestionnaireQuestionTemplate"

SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NOCOUNT ON

/*******************************************************************************************************/
/* Pre-procesessing */
/*******************************************************************************************************/
DECLARE @ret int;
DECLARE @err nvarchar(MAX),
		@err_severity int,
		@err_state int,
		@err_pro nvarchar(MAX),
		@err_number int ;

BEGIN TRY
	BEGIN TRANSACTION

	/* Preprocess the table*/
	EXEC @ret = p_Preprocessing '$(tableName)'

	IF @ret IS NULL OR @ret <> 0 
	BEGIN
		IF @@TRANCOUNT <> 0 
			ROLLBACK TRANSACTION;

		RETURN;
	END
	/* end of Pre-processing */

	CREATE TABLE [dbo].[t_EHR_QuestionnaireQuestionTemplate](
		[QuestionnaireTemplateKey]	[INT]			NOT NULL	
		,[QuestionTemplateKey]		[INT]			NOT NULL	
		,[Ordinal]					[TINYINT]		NOT NULL DEFAULT 1 -- the order in which the questions appear
		,[Required]					[BIT]			NOT NULL DEFAULT 0 -- question required in this questionnaire
		,[Status]					CHAR(1)			NOT NULL DEFAULT 'A'
		,[CustomTemplate]			VARCHAR(60)		NULL 
		,[CreateDate]				SMALLDATETIME	NOT NULL DEFAULT CURRENT_TIMESTAMP
		,[CreateBy]					[VARCHAR](60)	NULL
		,[ChangeDate]				SMALLDATETIME	NULL
		,[ChangeBy]					[VARCHAR](60)	NULL
		,[DeactivateDate]			SMALLDATETIME	NULL
		,[DeactivateBy]				[VARCHAR](60)	NULL
	 CONSTRAINT [pky_EHR_QuestionnaireQuestionTemplate] PRIMARY KEY 
	(
		-- any given question can only be asked once per questionnaire
		[QuestionnaireTemplateKey] ASC
		,[QuestionTemplateKey]
	)
	)  

	ALTER TABLE [dbo].[t_EHR_QuestionnaireQuestionTemplate]  
	WITH CHECK 
	ADD CONSTRAINT [fky_EHR_QuestionnaireQuestionTemplate_1] FOREIGN KEY([QuestionTemplateKey])
	REFERENCES [dbo].[t_EHR_QuestionTemplate] ([QuestionTemplateKey])
	ON DELETE CASCADE

	ALTER TABLE [dbo].[t_EHR_QuestionnaireQuestionTemplate]  
	WITH CHECK 
	ADD CONSTRAINT [fky_EHR_QuestionnaireQuestionTemplate_2] FOREIGN KEY([QuestionnaireTemplateKey])
	REFERENCES [dbo].[t_EHR_QuestionnaireTemplate] ([QuestionnaireTemplateKey])

	/* Post-processing */
	EXEC @ret = p_Postprocessing '$(tableName)'

	IF @ret IS NULL OR @ret <> 0 
	BEGIN
		IF @@TRANCOUNT <> 0 
			ROLLBACK TRANSACTION;

		RETURN;
	END
	
	COMMIT TRANSACTION;

	PRINT 'Finish successfully';
END TRY
BEGIN CATCH 
	SELECT  @err_severity = ERROR_SEVERITY(),
			@err_state = ERROR_STATE(),
			@err_number = ERROR_NUMBER(),
			@err = ERROR_MESSAGE();

	IF @@TRANCOUNT <> 0 
		ROLLBACK TRANSACTION;

	RAISERROR(@err,@err_severity,127)
END CATCH


GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'$Revision: 1 $-----$Date: 6/30/2015 10:52a $'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'TABLE' ,  @level1name = 't_EHR_QuestionnaireQuestionTemplate'
GO
