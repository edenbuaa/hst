IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_WorkflowTemplateRequiresBundle') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_WorkflowTemplateRequiresBundle;
GO
-- =============================================================================================================
-- Author:			Mike Shubat
-- Create date:		1/19/2016
-- Description:		Adds a bundle to a chart
--				  
-- Parameters		
--					chartKey:				key of chart we are working on
--
--					bundleTemplateKey:		Template key of bundle, as selected by user
--
--					userID:					User ID of responsible user 
--
--					actionDate:				workstation time on responsible users device
-- =============================================================================================================
/*
-- Code to identify chart tables that probably require bundles.  
-- With these in hand, then looking through p_EHR_InitSeed will yield identity of modules needing bundles

-- tables with primary keys involving bundlekey
WITH pkys (TableName, FieldName)
AS
(
	SELECT	c.Table_Name
			,c.Column_Name 
	FROM     INFORMATION_SCHEMA.TABLE_CONSTRAINTS t 
	JOIN     INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE c 
	ON		c.Constraint_Name = t.Constraint_Name
	AND		c.Table_Name = t.Table_Name
	WHERE	t.Constraint_Type = 'PRIMARY KEY'
	AND		c.COLUMN_NAME = 'BundleKey'
)
SELECT * FROM pkys
ORDER BY  TableName, FieldName;

-- tables with primary keys or clustered indexes involving BundleKey
SELECT DISTINCT t.name TableName
FROM	sys.indexes i 
JOIN	sys.index_columns ic 
ON		ic.[object_id]  = i.[object_id]
AND		ic.index_id = i.index_id
JOIN	sys.columns c 
ON		c.[object_id] = ic.[object_id]
AND		c.column_id = ic.column_id
JOIN	sys.tables t 
ON		t.[object_id] = i.[object_id]
WHERE	(i.is_primary_key = 1 OR i.index_id = 1) --index_id == 1 means clustered index
AND		c.name = 'BundleKey'

*/

CREATE PROCEDURE p_EHR_WorkflowTemplateRequiresBundle
	@workflowTemplateKey	int
	,@chartKey				int
	,@requiresBundle		bit OUTPUT
--WITH ENCRYPTION

AS
	
SET NOCOUNT ON;

BEGIN TRY
	SET @requiresBundle = 0;
	
	DECLARE @centerID INT
	
	SELECT @centerID = CenterID
	FROM	t_EHR_Chart
	WHERE	ChartKey = @chartKey

	IF EXISTS (	SELECT	*
				FROM	t_EHR_WorkflowModuleTemplate wmt	
				JOIN	t_EHR_ModuleTemplate mt
				ON		mt.ModuleTemplateKey = wmt.ModuleTemplateKey
				WHERE	wmt.WorkflowTemplateKey = @workflowTemplateKey
				AND		mt.[Status] = 'A'
				AND		mt.RequiresBundle = 1)
		SET @requiresBundle = 1;	

	IF NOT EXISTS(SELECT	*
				FROM	t_EHR_Bundle bd
				JOIN	t_EHR_BundleTemplate bdt
				ON		bd.BundleTemplateKey = bdt.BundleTemplateKey
				WHERE	bd.ChartKey = @chartKey
				AND		bd.[Status]='A')
	BEGIN
				DECLARE @bundleTemplateKey INT
				IF NOT EXISTS(SELECT * FROM t_EHR_BundleTemplate WHERE CenterID = @centerID AND BundleTemplateName = 'Vacant bundle')
				BEGIN
					INSERT INTO t_EHR_BundleTemplate (BundleTemplateName, BundleTemplateDescription, CenterID, CreateBy, [Status])
					VALUES ('Vacant bundle','Empty bundle',@centerID,'hsta', 'I');

					SET		@bundleTemplateKey = SCOPE_IDENTITY();
				END
				ELSE
					SELECT	@bundleTemplateKey = BundleTemplateKey 
					FROM	t_EHR_BundleTemplate
					WHERE	CenterID = @centerID 
					AND		BundleTemplateName = 'Vacant bundle'

				INSERT INTO t_EHR_Bundle (ChartKey, BundleTemplateKey, CreateBy, [Status])
				VALUES (@chartKey, @bundleTemplateKey, 'hsta', 'A');
	END

	-- return the vacant bundles
	SELECT	bd.BundleKey, 
			bdt.BundleTemplateName
	FROM	t_EHR_Bundle bd
	JOIN	t_EHR_BundleTemplate bdt
	ON		bd.BundleTemplateKey = bdt.BundleTemplateKey
	WHERE	bd.ChartKey = @chartKey
	AND		bd.[Status]='A';	
	
	RETURN;
END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH;

GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'Rev Date: 3/1/2017'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_WorkflowTemplateRequiresBundle'
GO
