-- ============================================================
-- First step to be run before any table changes during upgrade
-- Put any table changes here.
-- ============================================================

SET NOCOUNT ON;

/* get out if initial install */
IF NOT EXISTS(	SELECT	* 
				FROM	INFORMATION_SCHEMA.COLUMNS
				WHERE	TABLE_NAME = 't_EHR_Module')
BEGIN
	RETURN;
END


/*******************************************************************************
* need to drop indexed view before rebuilding view that it depends on.
*******************************************************************************/

/* Drop Full Text index before dropping underlying view */
EXEC p_Drop_FullTextIndex 'v_EHR_Physician'
GO

/* then drop underlying view */
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_EHR_Physician]'))
	DROP VIEW [dbo].v_EHR_Physician
GO

IF NOT EXISTS(	SELECT	* 
				FROM	sys.columns
				WHERE	Name = N'Status'  
				AND		Object_ID = Object_ID(N't_VisitParticipant') )
BEGIN
	ALTER TABLE dbo.t_VisitParticipant 
	ADD	[Status] CHAR(1) NOT NULL DEFAULT 'A';
END

IF NOT EXISTS(	SELECT	* 
				FROM	sys.columns
				WHERE	Name = N'Status'  
				AND		Object_ID = Object_ID(N't_VisitPhysician') )
BEGIN
	ALTER TABLE dbo.t_VisitPhysician 
	ADD	[Status] CHAR(1) NOT NULL DEFAULT 'A';
END


IF NOT EXISTS(	SELECT	* 
				FROM	sys.columns
				WHERE	Name = N'HasCompletion'  
				AND		Object_ID = Object_ID(N't_EHR_ModuleTemplate') )
BEGIN
	ALTER TABLE dbo.t_EHR_ModuleTemplate 
	ADD	[HasCompletion]		BIT	NOT NULL DEFAULT 0
		,[SelfRefreshing]	BIT	NOT NULL DEFAULT 0;
END

IF NOT EXISTS(	SELECT	* 
				FROM	sys.columns
				WHERE	Name = N'AutoProcessSuppliesUsed'  
				AND		Object_ID = Object_ID(N't_EHR_CenterConfiguration') )
BEGIN
	ALTER TABLE dbo.t_EHR_CenterConfiguration 
	ADD	AutoProcessSuppliesUsed	BIT	NOT NULL DEFAULT 1;
END

IF NOT EXISTS(	SELECT	* 
				FROM	sys.columns
				WHERE	Name = N'AssignedBundle'  
				AND		Object_ID = Object_ID(N't_EHR_OperativeReportDocument') )
BEGIN
	ALTER TABLE dbo.t_EHR_OperativeReportDocument 
	ADD	AssignedBundle INT  NULL ;
END

IF NOT EXISTS(	SELECT	* 
				FROM	sys.columns
				WHERE	Name = N'CustomTemplate'  
				AND		Object_ID = Object_ID(N't_EHR_QuestionnaireQuestionTemplate') )
BEGIN
	ALTER TABLE dbo.t_EHR_QuestionnaireQuestionTemplate
	ADD	CustomTemplate VARCHAR(60)  NULL ;
END

IF EXISTS(	SELECT	* 
			FROM	sys.columns c
			WHERE	c.[Name] = N'PhysicianText'  
			AND		c.Object_ID = Object_ID(N't_EHR_OperativeReport')
			AND		c.max_length > 0) -- if it is already set to varchar(max), then max_length will be -1
BEGIN
	ALTER TABLE dbo.t_EHR_OperativeReport
	ALTER COLUMN PhysicianText VARCHAR(MAX) -- increased at request of Pacific and Austin.
END

IF NOT EXISTS(	SELECT	* 
				FROM	sys.indexes
				WHERE	Name = N'idx_EHR_Image_1'  
				AND		Object_ID = Object_ID(N't_EHR_Image') )
BEGIN
	CREATE INDEX idx_EHR_Image_1 ON t_EHR_Image(
		ChartKey ASC
	)
END

IF NOT EXISTS(	SELECT	* 
				FROM	sys.indexes
				WHERE	Name = N'idx_EHR_Image_2'  
				AND		Object_ID = Object_ID(N't_EHR_Image') )
BEGIN
	CREATE INDEX idx_EHR_Image_2 ON t_EHR_Image(
		ModuleKey ASC
	)
END

IF (SELECT COLUMNPROPERTY(OBJECT_ID('t_EHR_PatientValuables', 'U'), 'IntakeSignatureKey', 'AllowsNull')) = 0
BEGIN
	ALTER TABLE t_EHR_PatientValuables ALTER COLUMN IntakeSignatureKey INT NULL
END

IF (SELECT COLUMNPROPERTY(OBJECT_ID('t_EHR_PatientValuables', 'U'), 'ReturnSignatureKey', 'AllowsNull')) = 0
BEGIN
	ALTER TABLE t_EHR_PatientValuables ALTER COLUMN ReturnSignatureKey INT NULL
END

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_DrainsAndPacksDeleteOrStrikeThrough') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_DrainsAndPacksDeleteOrStrikeThrough

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_DrainsAndPacksInsert') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_DrainsAndPacksInsert

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_DrainsAndPacksUpdate') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_DrainsAndPacksUpdate

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_DressingDeleteOrStrikeThrough') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_DressingDeleteOrStrikeThrough

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_DressingInsert') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_DressingInsert

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_DressingUpdate') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_DressingUpdate

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_DressingDetail') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_DressingDetail

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_ImplantLogDetailDeleteOrStrikeThrough') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_ImplantLogDetailDeleteOrStrikeThrough

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_ImplantLogDetailInsert') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_ImplantLogDetailInsert

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_ImplantLogDetailUpdate') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_ImplantLogDetailUpdate

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_PrepDeleteOrStrikeThrough') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_PrepDeleteOrStrikeThrough

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_PrepInsert') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_PrepInsert

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_PrepUpdate') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_PrepUpdate

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_SolutionDeleteOrStrikeThrough') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_SolutionDeleteOrStrikeThrough

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_SolutionInsert') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_SolutionInsert

IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_LET_SolutionUpdate') AND type in(N'P',N'PC'))
	DROP PROCEDURE p_EHR_LET_SolutionUpdate


GO



