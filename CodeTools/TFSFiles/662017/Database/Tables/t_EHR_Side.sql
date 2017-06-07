:SETVAR tableName "t_EHR_Side"

SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON

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

	CREATE TABLE t_EHR_Side(
		
		[SideCode]						VARCHAR (24) NOT NULL
		,[SideName]				        VARCHAR (128) NULL
		,[Ordinal]						INT NOT NULL DEFAULT (1) -- sort order for how areas are presented
		
		,[CreateDate]					SMALLDATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
		,[CreateBy]						VARCHAR(60) NULL
		,[ChangeDate]					SMALLDATETIME NULL
		,[ChangeBy]						VARCHAR(60) NULL		
	 CONSTRAINT pky_EHR_Side PRIMARY KEY CLUSTERED 
	(
		SideCode ASC
	)
	) 


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
     ,@value = N'Rev Date: 5/15/2017'
     ,@level0type = N'SCHEMA', @level0name = dbo
     ,@level1type = N'TABLE' ,  @level1name = 't_EHR_Side'
GO
