-- ============================================================
-- last step to be run during upgrade
-- Put any data fixes needed due to table changes.
-- ============================================================

SET NOCOUNT ON;





/**********************************************************************************************************************************
* Registration BLOC and schedule coloring based on patient location
***********************************************************************************************************************************/
DECLARE @dbCreator NVARCHAR(60), @WorkstationTime DATETIME
SET		@dbCreator = 'hsta'
SET		@WorkstationTime = GetDate()

	-- t_PatientLocation	
	;WITH EHR_PatientLocation (CenterID, Location, [Description], CreateBy)
	AS (
		SELECT CenterID, 'Reg       ', 'Registration', @dbCreator
		FROM	t_EHR_CenterConfiguration		
	)
	MERGE INTO	t_PatientLocation AS T
	USING		EHR_PatientLocation AS S
	ON			T.CenterID = S.CenterID 
	AND			T.Location = S.Location 
	WHEN		MATCHED
			THEN	UPDATE		SET  T.[RowColor] = -32513, T.ChangeBy = @dbCreator, T.ChangeDate = @WorkstationTime
	WHEN		NOT MATCHED BY TARGET
			THEN	INSERT		(CenterID, Location, [Description], CreateBy) 
					VALUES		(S.CenterID, S.Location, S.[Description], @dbCreator);
GO



/*****************************************************************************************************************************
* Mark BLOCs as having a back-end completion handler, and optionally whether they are self-refreshing                        *
******************************************************************************************************************************/
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='001'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='002'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='003'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='004'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='005'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='006'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='007'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='008'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='009'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='010'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='011'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='012'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='013'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='014'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='015'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='016'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='017'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='018'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='019'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='020'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='021'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='022'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='023'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='024'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='025'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='026'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='027'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='028'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='029'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='030'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='031'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='032'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='034'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='035'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='036'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='037'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='038'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='039'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='040'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='041'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='042'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='043'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='044'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='045'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='046'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='047'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='048'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='049'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='050'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='051'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='052'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='053'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='054'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='055'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='056'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='057'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='058'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='059'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='060'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='061'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='062'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='063'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='064'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='065'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='066'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='067'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='068'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='069'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='070'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='071'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='074'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='076'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='077'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='078'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='080'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='081'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='082'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='083'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='084'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='085'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='086'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='087'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='088'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='089'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='090'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='091'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='092'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='093'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='094'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='095'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='096'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='097'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1					 	WHERE ModuleDesignID='098'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1					 	WHERE ModuleDesignID='099'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='100'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='101'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='102'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='103'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='105'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='106'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='107'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='108'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='109'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1			 			WHERE ModuleDesignID='110'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1			 			WHERE ModuleDesignID='111'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1			 			WHERE ModuleDesignID='112'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1			 			WHERE ModuleDesignID='113'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='114'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='115'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='116'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='117'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1			 			WHERE ModuleDesignID='118'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='119'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='121'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='122'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='123'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='124'
--UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='125'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=0	WHERE ModuleDesignID='125'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='126'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='128'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1, SelfRefreshing=1	WHERE ModuleDesignID='129'
UPDATE t_EHR_ModuleTemplate SET HasCompletion=1						WHERE ModuleDesignID='130'

GO

--fix bug 1063
IF		EXISTS (SELECT * FROM syscolumns WHERE name = 'BodySide' AND OBJECT_NAME(id) = 't_EHR_XRayDetail')
BEGIN	
	UPDATE	t_EHR_XRayDetail
	SET		BodySide =	'L'
	WHERE   BodySide = '1'

	UPDATE	t_EHR_XRayDetail
	SET		BodySide =	'R'
	WHERE   BodySide = '2'

	UPDATE	t_EHR_XRayDetail
	SET		BodySide =	'N'
	WHERE   BodySide = '3'

	UPDATE	t_EHR_XRayDetail
	SET		BodySide =	'B'
	WHERE   BodySide = '4'

END

--fix bug 1086
UPDATE t_EHR_QuestionTemplate SET QuestionTypeID = 3 WHERE QuestionID = '082A-5'

--fix bug 1088 begin
DECLARE @ChartKey INT
,@ModuleKey INT
,@WorkflowKey INT
,@QuestionnaireTemplateKey INT
,@QuestionTemplateKey INT
,@BundleKey INT
,@dbCreator NVARCHAR(60)
,@WorkstationTime DATETIME
SET	@dbCreator = 'hsta'
SET	@WorkstationTime = GetDate()

DECLARE questionCursor CURSOR FOR
SELECT  m.ChartKey
,m.ModuleKey
,m.WorkflowKey
,m.QuestionnaireTemplateKey
,qt.QuestionTemplateKey
FROM t_EHR_QuestionTemplate qt
JOIN t_EHR_QuestionnaireQuestionTemplate qqt
ON qt.QuestionTemplateKey = qqt.QuestionTemplateKey
AND qt.DataScope = 'B'
JOIN t_EHR_Module m
ON qqt.QuestionnaireTemplateKey = m.QuestionnaireTemplateKey
AND m.BundleKey IS NULL
	
OPEN questionCursor;

FETCH NEXT FROM questionCursor INTO @ChartKey, @ModuleKey, @WorkflowKey, @QuestionnaireTemplateKey, @QuestionTemplateKey

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @BundleKey = dbo.f_EHR_GetBundleKeyByWorkflowKey(@WorkflowKey, 1)
	IF NOT EXISTS(SELECT 1 FROM v_EHR_QuestionResponse WHERE QuestionnaireTemplateKey = @QuestionnaireTemplateKey AND QuestionTemplateKey = @QuestionTemplateKey AND BundleKey = @BundleKey)
	BEGIN
		EXEC p_EHR_ProvisionQuestionResponses @ChartKey, NULL, @WorkflowKey, @ModuleKey, @dbCreator, @WorkstationTime;
	END

	FETCH NEXT FROM questionCursor INTO @ChartKey, @ModuleKey, @WorkflowKey, @QuestionnaireTemplateKey, @QuestionTemplateKey
END 

CLOSE questionCursor
DEALLOCATE questionCursor

DELETE qr FROM t_EHR_QuestionResponse qr
JOIN t_EHR_QuestionTemplate qt
ON qr.QuestionTemplateKey = qt.QuestionTemplateKey
AND qt.DataScope = 'B'
AND qr.ChartKey IS NULL
AND qr.BundleKey IS NULL
AND qr.WorkflowKey IS NULL
AND qr.ModuleKey IS NULL

----fix bug 1088 end

--new site-side control

IF	 object_id(N't_EHR_Side',N'U') is not null and not EXISTS (SELECT 1 FROM t_EHR_Side )
BEGIN	
INSERT INTO [dbo].[t_EHR_Side]
           ([SideCode]
           ,[SideName]
           ,[Ordinal]
           ,[CreateDate]
           ,[CreateBy])

     VALUES
           ('L'
           ,'Left'
           ,1
           ,@WorkstationTime
           ,@dbCreator
           )

INSERT INTO [dbo].[t_EHR_Side]
           ([SideCode]
           ,[SideName]
           ,[Ordinal]
           ,[CreateDate]
           ,[CreateBy])

     VALUES
           ('R'
           ,'Right'
           ,2
           ,@WorkstationTime
           ,@dbCreator
           )
INSERT INTO [dbo].[t_EHR_Side]
           ([SideCode]
           ,[SideName]
           ,[Ordinal]
           ,[CreateDate]
           ,[CreateBy])

     VALUES
           ('B'
           ,'Bilateral'
           ,3
           ,@WorkstationTime
           ,@dbCreator
           )
INSERT INTO [dbo].[t_EHR_Side]
           ([SideCode]
           ,[SideName]
           ,[Ordinal]
           ,[CreateDate]
           ,[CreateBy])

     VALUES
           ('N'
           ,'N/A'
           ,4
           ,@WorkstationTime
           ,@dbCreator
           )


END




