IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_CRUD_OperativeReport') AND TYPE in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_CRUD_OperativeReport;
GO

-- =============================================================================================================
-- Author:			Peter
-- Create date:		07/20/16
-- Description:		Creates/Reads/Deactivates data row for the Operative Report module
--				  
-- Parameters		action:					'T' -> Return list of tables that this proc returns
--
--											'C' -> Create a new record
--
--											'R' -> Reads the moudle data into result set. This can return more 
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
CREATE PROCEDURE p_EHR_CRUD_OperativeReport
	 @action			CHAR(1)
	,@centerID			INT
	,@chartKey			INT
	,@workflowKey		INT
	,@moduleKey			INT
	,@userID			VARCHAR(60)
	,@actionDate		SMALLDATETIME
--WITH ENCRYPTION

AS
	
SET NOCOUNT ON;

SET QUOTED_IDENTIFIER ON;

DECLARE	@SignatureKey				INT
DECLARE	@bundleKey					INT
DECLARE @PersonKey					INT
DECLARE @visitKey					INT	
DECLARE @primaryPhysicianId			INT
DECLARE @primaryPhysicianName		VARCHAR(120)
DECLARE @admitDate					SMALLDATETIME		
DECLARE @patientName				VARCHAR(120)	
DECLARE @dateOfBirth				SMALLDATETIME	
DECLARE @scheduledAnesthesiaType	CHAR(3)		
DECLARE @anesthesiaTypeDesc			VARCHAR(40)
BEGIN TRY
	
	SELECT	@PersonKey = PersonKey							
	,@visitKey = VisitKey
	FROM	t_EHR_Chart 
	WHERE	ChartKey = @chartKey 
	AND	[Status] ='A'
	

	SELECT  
	@primaryPhysicianId=vp.PhysicianID
	,@visitKey=v.VisitKey
	,@admitDate=v.AdmitDate
	,@patientName=CONCAT(p.FirstName ,' ',p.LastName)
	,@dateOfBirth=p.BirthDate
	,@scheduledAnesthesiaType = a.AnesthesiaType
	,@anesthesiaTypeDesc = at.Description
	FROM	t_VisitService vs -- make sure there is a procedure/service
	JOIN	t_Visit v
	ON		v.VisitKey = vs.VisitKey
	JOIN	t_VisitPhysician vp -- make sure there is a physician for the procedure/service
	ON		vp.VisitKey = vs.VisitKey
	AND		vp.VisitServiceKey = vs.VisitServiceKey
	JOIN    t_EHR_Chart ch
	ON		ch.VisitKey = v.VisitKey
	JOIN	t_Person p				
	ON		v.PersonKey = p.PersonKey
	LEFT JOIN	t_Appointment a
	ON		a.VisitKey = v.VisitKey
	LEFT JOIN	t_AnesthesiaType at
	ON		a.AnesthesiaType =  at.AnesthesiaType
	AND		a.CenterID = v.CenterID
	WHERE	vs.PrimaryProcedure = 1 -- the primary procedure
	AND		vp.PrimaryRole = 1 -- the primary physician
	AND		vp.PhysicianRole = 1 -- the performing physician
	AND		v.VisitStatus = 1 -- not cancelled
	AND   	 ch.ChartKey = @chartKey


	SELECT @primaryPhysicianName = CASE
										WHEN p.Salutation IS NOT NULL THEN CONCAT( p.FirstName,' ' ,p.LastName , ', ' , p.Salutation)
										ELSE CONCAT(p.FirstName,' ' ,p.LastName )
									END 
	FROM t_Physician p
	WHERE PhysicianID =@PrimaryPhysicianId 
	AND CenterID=@centerID

	DECLARE @AssociatedBundleKey INT
	DECLARE @AssociatedPhysicianID INT
	DECLARE @PhysicianText VARCHAR(5120)
	SELECT  
	@AssociatedPhysicianID= AssociatedPhysicianID				
	,@AssociatedBundleKey = AssociatedBundleKey
	,@PhysicianText = PhysicianText
	FROM	t_EHR_OperativeReport 
	WHERE	ChartKey = @chartKey 
	AND ModuleKey=@moduleKey
	AND Status='A'
	
	
	IF @scheduledAnesthesiaType IS NULL OR @scheduledAnesthesiaType=''
	SET @scheduledAnesthesiaType = NULL

	IF @action = 'T'
	
		SELECT	*
		FROM(VALUES
		    ('t_EHR_EventTime',							NULL,			0)	
			,('t_EHR_OperativeReport',					NULL,			1)			
			,('t_EHR_OperativeReportDocumentDetail',	NULL,			0)
			,('t_EHR_Signature',						NULL,			1) 
			,('v_EHR_Physician',						NULL,			0)
			,('v_EHR_Bundle',							NULL,			0)
			)
		AS	temp (TableName, ResultName, SingleRow)
		

	-- Create a new row for this module
	ELSE IF @action = 'C'
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM t_EHR_OperativeReport WHERE ChartKey = @chartKey AND ModuleKey = @moduleKey AND [Status] = 'A')
				BEGIN			
					-- Create signature						
					INSERT INTO t_EHR_Signature (
								ChartKey
								, BundleKey
								, WorkflowKey
								, AreaKey
								, ModuleKey
								, ModuleTemplateKey
								, CreateBy
								, CreateDate
								, SignaturePrompt
								, Mode)
						SELECT	m.ChartKey
								,NULL
								,m.WorkflowKey
								,w.AreaKey
								,m.ModuleKey
								,m.ModuleTemplateKey
								,@userID
								,@actionDate
								,'Signature of Physician'
								,'3'
						FROM	t_EHR_Module m
						JOIN	t_EHR_Workflow w
						ON		m.WorkflowKey = w.WorkflowKey
						WHERE	m.ModuleKey = @moduleKey

					SET	@SignatureKey = SCOPE_IDENTITY();

						SELECT		@bundleKey	= BundleKey
						FROM		t_EHR_Bundle 
						WHERE		ChartKey = @chartKey -- Grab the first Bundle in the Chart


					--First check if a Module exists for the Primary Physician/Primary Bundle
					--If it doesn't, create a Module for the Primary Physician/Primary Bundle, if not create a Module with Bundle, Physician associated to NULL
					IF NOT EXISTS
					(
					SELECT op.ModuleKey 
					FROM t_EHR_OperativeReport  op
					JOIN t_EHR_Module m 
					ON m.ModuleKey=op.ModuleKey
					WHERE op.ChartKey=@chartKey 
					AND op.AssociatedPhysicianID=@primaryPhysicianId
					AND m.Status='A'
					)
					BEGIN
						INSERT 
						t_EHR_OperativeReport 
						(ChartKey,
						WorkflowKey,
						ModuleKey,
						BundleKey,
						SignatureKey,
						AssociatedPhysicianID,
						AssociatedPhysicianName,
						AssociatedBundleKey,
						DateOfService,
						Patient,
						CreateBy,
						CreateDate,
						AnesthesiaType , 
						AnesthesiaTypeDescription
						)
						VALUES
						 (
						@chartKey,
						@workflowKey,
						@moduleKey,
						@bundleKey,
						@SignatureKey,
						@primaryPhysicianId,
						@primaryPhysicianName,
						@bundleKey,
						@admitDate,
						@patientName,
						@userID,
						@actionDate,
						@scheduledAnesthesiaType,
						@anesthesiaTypeDesc
						)
					END
					ELSE
					BEGIN
						INSERT t_EHR_OperativeReport 
						(
						ChartKey,
						WorkflowKey,
						ModuleKey,
						BundleKey,
						SignatureKey,
						AssociatedPhysicianID,
						AssociatedPhysicianName,
						AssociatedBundleKey,
						CreateBy,
						CreateDate,
						AnesthesiaType,
						AnesthesiaTypeDescription
						)
						VALUES 
						(@chartKey,
						@workflowKey,
						@moduleKey,
						@bundleKey,
						@SignatureKey,
						NULL,
						NULL,
						NULL,
						@userID, 
						@actionDate,
						@scheduledAnesthesiaType, 
						@anesthesiaTypeDesc
						)
					END

				

				END
		END

	
	ELSE IF @action ='V'
	BEGIN		
			DECLARE @SigningPhysicianUserID VARCHAR(120)
			DECLARE @SigningPhysicianID INT
			DECLARE @ProcedureIncisionTimeSET BIT
			DECLARE @IsSigned BIT
			DECLARE @DocumentPresent BIT
			
			SET @DocumentPresent =0
			SET @ProcedureIncisionTimeSet =0
			
			IF EXISTS(
			SELECT 1 FROM t_EHR_OperativeReportDocumentDetail 
				WHERE 
				--(PreSigned = 1 OR Signed=1)
				ChartKey = @chartKey				
				AND	ModuleKey = @moduleKey
				AND Status='A'
			)
			SET @DocumentPresent =1

			SELECT
			@SigningPhysicianUserID=
			CASE 
			WHEN MODE=2
			THEN ISNULL(LTRIM(RTRIM(SignUserID)),'')
			ELSE 
			ISNULL(LTRIM(RTRIM(ChangeBy)),'')
			
			END
			,@IsSigned=IsSigned			
			FROM	t_EHR_Signature
			WHERE	ChartKey = @chartKey
			AND		Status ='A'
			AND		ModuleKey = @moduleKey

			SELECT
			@SigningPhysicianID=PhysicianID
			FROM
			v_EHR_Physician
			WHERE CenterID=@centerID
			AND UserID = @SigningPhysicianUserID
						

			IF EXISTS
			(
				SELECT 
				1 
				FROM	t_EHR_EventTime  et
				JOIN    t_EHR_ModuleTemplate mdlt
				ON      et.ModuleTemplateKey = mdlt.ModuleTemplateKey
				where   mdlt.ModuleDesignID in ('048','094')
				and		et.ChartKey = @chartKey 			
				AND     et.BundleKey =@AssociatedBundleKey
				AND 	et.EventTime IS NOT NULL
			)
			SET @ProcedureIncisionTimeSet =1
			
			IF @AssociatedPhysicianID IS NULL
			BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 't_EHR_OperativeReport', 'Physician responsible for the Operative Report must be chosen'
			END

			ELSE IF @AssociatedBundleKey IS NULL
			BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 't_EHR_OperativeReport', 'Operative Event must be chosen'
			END

			ELSE IF (@PhysicianText IS  NULL OR LEN(@PhysicianText) < 200) AND NOT EXISTS 
			(
				SELECT 1 FROM t_EHR_OperativeReportDocumentDetail 
				WHERE (PreSigned = 1 OR Signed=1)
				AND	ChartKey = @chartKey				
				AND	ModuleKey = @moduleKey
				AND Status='A'
			)
			BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 't_EHR_OperativeReport', 'Description of operation must be at least 200 characters in length';
			END
			
			ELSE IF @SigningPhysicianID IS  NULL AND  @PhysicianText IS NOT NULL AND LEN(LTRIM(RTRIM(@PhysicianText)))<>0
			BEGIN
				IF @ProcedureIncisionTimeSet=0 AND LEN(RTRIM(@PhysicianText)) < 200 
				BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 't_EHR_OperativeReport', 'Physician Signature is required, Procedure/Incision time must be set and Physician comments (> 200 characters long) must be entered to enable signature';
				END
				ELSE IF @ProcedureIncisionTimeSet =0
				BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 't_EHR_OperativeReport', 'Physician Signature is required, Procedure/Incision time must be set to enable signature';
				END
				ELSE IF LEN(RTRIM(@PhysicianText)) < 200 
				EXEC p_EHR_Incomplete @moduleKey, 't_EHR_OperativeReport', 'Physician Signature is required, Physician comments (> 200 characters long) must be entered to enable signature '
				ELSE
				BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 't_EHR_OperativeReport', 'Physician Signature is required';
				END
			END
			ELSE IF @SigningPhysicianID IS NOT NULL AND @SigningPhysicianID <> @AssociatedPhysicianID
			BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 't_EHR_OperativeReport', 'Must be signed by the Physician responsible';
			END
			
			ELSE IF EXISTS 
			(
				SELECT 1 FROM t_EHR_OperativeReportDocumentDetail 
				WHERE PreSigned = 0
				AND Signed=0
				AND	ChartKey = @chartKey				
				AND	ModuleKey = @moduleKey
				AND Status='A'
			)
			BEGIN				
				BEGIN
				IF @ProcedureIncisionTimeSet=0
				BEGIN
				EXEC p_EHR_Incomplete @moduleKey, 't_EHR_OperativeReport', 'Physician Signature is required, Procedure/Incision time must be set to enable signature';
				END
				ELSE
				EXEC p_EHR_Incomplete @moduleKey, 't_EHR_OperativeReport', 'All Documents (dictated) must be reviewed and signed';
				END
			END


	END

	ELSE IF @action = 'R' OR @action = 'A'
		BEGIN								
			
			SELECT 
			et.EventTime, 
			et.EventKey			
			FROM	t_EHR_EventTime  et
			JOIN    t_EHR_ModuleTemplate mdlt
			ON      et.ModuleTemplateKey = mdlt.ModuleTemplateKey
			where     mdlt.ModuleDesignID in ('048','094')
			and	et.ChartKey = @chartKey 			
			AND    et.BundleKey =@AssociatedBundleKey
			
			SELECT	*					
			FROM	t_EHR_OperativeReport 
			WHERE	ChartKey = @chartKey 
			AND ModuleKey=@moduleKey
			AND		((@action='R' AND Status IN ('A', 'D')) 
			OR (@action='A'))
						
			
			SELECT	*					
			FROM	t_EHR_OperativeReportDocumentDetail 
			WHERE	ChartKey = @chartKey 
			AND ModuleKey=@moduleKey
			AND Status='A'
			AND		((@action='R' AND Status IN ('A', 'D')) 
			OR (@action='A'))				

			SELECT	*
			FROM	t_EHR_Signature
			WHERE	ChartKey = @chartKey
			AND		Status IN ('A','D')
			AND		ModuleKey = @moduleKey
						
			SELECT vp.PhysicianID,
			vp.PhysicianName,
			vp.UserID
			FROM t_VisitPhysician tvp
			JOIN v_EHR_Physician vp
			ON tvp.PhysicianID= vp.PhysicianID
			WHERE tvp.VisitKey=@visitKey 
			AND tvp.CenterID=@centerID
			AND 
			(
			tvp.PhysicianRole=1 
			OR tvp.PhysicianRole=2
			)
								

			SELECT * from v_EHR_Bundle
			WHERE	ChartKey = @chartKey
						
		END
	
	ELSE IF @action = 'S'
	BEGIN

					UPDATE  t_EHR_OperativeReport
					SET	Physician = @primaryPhysicianName,
					DateOfService = @admitDate,
					Patient=@patientName,
					DateOfBirth=@dateOfBirth,
					AnesthesiaType = ISNULL(AnesthesiaType,@scheduledAnesthesiaType),
					AnesthesiaTypeDescription = ISNULL(AnesthesiaTypeDescription,@anesthesiaTypeDesc)
					OUTPUT	'U', deleted.*, inserted.* 
					INTO	#t_EHR_OperativeReport_Audit
					OUTPUT	inserted.*
					WHERE  ChartKey = @chartKey  
					AND ModuleKey=@moduleKey

					INSERT INTO #UpdateLog VALUES (@moduleKey, @workflowKey,'t_EHR_OperativeReport', NULL, NULL, 'U')

					
					IF  @AssociatedBundleKey IS NOT NULL
					BEGIN

					-- update Pre/Post-op diaognsis
						DECLARE @DiagnosisPreOpKey			INT;
						DECLARE @DiagnosisPostOpKey			INT;
						DECLARE @ICD						VARCHAR(10);
						DECLARE @Diagnosis					VARCHAR(250);
						DECLARE @PreOpDiagnosisDefault		VARCHAR(MAX) = ''
						DECLARE @PostOpDiagnosisDefault		VARCHAR(MAX) = ''
						--PREOP
						DECLARE preOpCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
						SELECT	
						DiagnosisPreOpKey,
						ICD, 
						Diagnosis
						FROM	t_EHR_DiagnosisPreOp
						WHERE	ChartKey = @chartKey 
						AND		Status IN ('A')
						ORDER BY DiagnosisPreOpKey;
	
						OPEN preOpCursor;

						FETCH NEXT FROM preOpCursor INTO @DiagnosisPreOpKey, @ICD, @Diagnosis;

						WHILE @@FETCH_STATUS = 0
						BEGIN
							IF @ICD IS NOT NULL
								SET	@PreOpDiagnosisDefault = ISNULL(@PreOpDiagnosisDefault, '') + ISNULL(@ICD, '') + ' - ' + ISNULL(@Diagnosis, '') + char(13);
							ELSE
								SET	@PreOpDiagnosisDefault = ISNULL(@PreOpDiagnosisDefault, '') + ISNULL(@Diagnosis, '') + char(13);

							FETCH NEXT FROM preOpCursor INTO @DiagnosisPreOpKey, @ICD, @Diagnosis;
						END 

						CLOSE preOpCursor
						DEALLOCATE preOpCursor

						--POSTOP
						DECLARE postOpCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
						SELECT
						DiagnosisPostOpKey,
						ICD, 
						Diagnosis
						FROM	t_EHR_DiagnosisPostOp
						WHERE	ChartKey = @chartKey 
						AND		Status IN ('A')
						ORDER BY DiagnosisPostOpKey;
	
						OPEN postOpCursor;

						FETCH NEXT FROM postOpCursor INTO @DiagnosisPostOpKey, @ICD, @Diagnosis;

						WHILE @@FETCH_STATUS = 0
						BEGIN
							IF @ICD IS NOT NULL
								SET	@PostOpDiagnosisDefault = ISNULL(@PostOpDiagnosisDefault, '') + ISNULL(@ICD, '') + ' - ' + ISNULL(@Diagnosis, '') + char(13);
							ELSE
								SET	@PostOpDiagnosisDefault = ISNULL(@PostOpDiagnosisDefault, '') + ISNULL(@Diagnosis, '') + char(13);

							FETCH NEXT FROM postOpCursor INTO @DiagnosisPostOpKey, @ICD, @Diagnosis;
						END 

						CLOSE postOpCursor
						DEALLOCATE postOpCursor;

						UPDATE	t_EHR_OperativeReport 
						SET		[PreOpDiagnosis] =   ISNULL( NULLIF(RTRIM(PreOpDiagnosis),  ''), @PreOpDiagnosisDefault  )
								,[PostOpDiagnosis] = ISNULL( NULLIF(RTRIM(PostOpDiagnosis), ''), @PostOpDiagnosisDefault )
						OUTPUT	'U', deleted.*, inserted.* 
						INTO	#t_EHR_OperativeReport_Audit
						OUTPUT	inserted.*
						WHERE	ChartKey = @chartKey
						AND		Status ='A'
						AND		ModuleKey = @moduleKey

						INSERT INTO #UpdateLog VALUES (@moduleKey, @workflowKey,'t_EHR_OperativeReport', NULL, NULL, 'U')

					--Update procedures
					--prepare the temp table to reorganize the format: 
					-- |------scheduled----------|--performed--|				
					-- |cpt_procedure_modifer;..;|..;..;	   |

					--scheduled pro
						SELECT	*
						INTO	#t
						FROM	(
									SELECT	Concat(	CPTCode ,CASE WHEN CPTCode IS NULL THEN '' ELSE ' - ' END ,
													ProcedureDescription ,
													CASE vm.Description													
														WHEN 'L' THEN ' - Left'
														WHEN 'R' THEN ' - Right'
														WHEN 'B' THEN ' - Bilateral'
														WHEN 'U' THEN ' - Upper'
														WHEN 'W' THEN ' - Lower'
														ELSE '' 
													END ,
													CHAR(10) --line feed
													) as cpp,BundleKey
									FROM	t_EHR_ScheduledProcedure sp
									LEFT JOIN	v_EHR_Modifier vm
									ON		vm.Code = sp.ProcedureModifier
									WHERE	BundleKey = @AssociatedBundleKey
									AND		Status = 'A'
									) AS a 
				
					--performed pro
						SELECT	*
						INTO	#t2
						FROM	(
									SELECT	Concat(	CPTCode ,CASE WHEN CPTCode IS NULL THEN '' ELSE ' - ' END ,
													ProcedureDescription ,
													CASE vm.Description													
														WHEN 'L' THEN ' - Left'
														WHEN 'R' THEN ' - Right'
														WHEN 'B' THEN ' - Bilateral'
														WHEN 'U' THEN ' - Upper'
														WHEN 'W' THEN ' - Lower'
														ELSE '' 
													END,
													CHAR(10) --line feed
													) as cpp,BundleKey
									FROM	t_EHR_PerformedProcedure pp
									LEFT JOIN	v_EHR_Modifier vm
									ON		vm.Code = pp.ProcedureModifier
									WHERE	BundleKey =  @AssociatedBundleKey
									AND		Status = 'A'
									) AS b

									--Update implants
					--find all the modules belong to the bundle and distinct the data row
					SELECT	*
					INTO	#t3
					FROM	(
								SELECT DISTINCT
									CONCAT(ItemDescription,'_'
											,Manufacturer,'_'
											, ImplantSize, '_'
											, Quantity,'_'
											, bs.BodySiteDescription,'_'
											, ( CASE logd.BodySide													
													WHEN 'L' THEN 'Left'
													WHEN 'R' THEN 'Right'
													WHEN 'B' THEN 'Bilateral'
													WHEN 'U' THEN 'Upper'
													WHEN 'W' THEN 'Lower'
													ELSE '' 
											  END )											
											,'_'
											,SerialNumber,'_'
											,LotNumber,'_'
											,ExpireDate) AS Implants, @AssociatedBundleKey as BundleKey
									FROM	t_EHR_ImplantLogDetail logd
									LEFT JOIN t_EHR_BodySite bs
									ON	logd.BodySiteKey = bs.BodySiteKey
									WHERE ChartKey = @chartKey
									AND WorkflowKey IN
									(
										SELECT	WorkflowKey 
										FROM	t_EHR_Workflow
										WHERE	BundleKey = @AssociatedBundleKey
									)
									AND logd.Status='A'									
								) AS c

						 --step 5. update specimens
				   SELECT	*
					INTO	#t4
					FROM	(
								SELECT DISTINCT
										CONCAT(	SpecimenDescription,'_'
												,BodySiteName,'_',
												(	CASE 
														WHEN BodySide = 'L' THEN 'Left' 
														WHEN BodySide = 'R' THEN 'Right' 
														WHEN BodySide = 'N' THEN 'N/A' 
														ELSE BodySide
														END)) AS Specimens
										, @AssociatedBundleKey as BundleKey
										FROM t_EHR_SpecimenDetail
										WHERE ChartKey = @chartKey
										AND WorkflowKey IN
										(
											SELECT	WorkflowKey 
											FROM	t_EHR_Workflow
											WHERE	BundleKey =  @AssociatedBundleKey
										)
										AND Status='A'
										GROUP BY SpecimenDescription ,BodySiteName,BodySide
								) AS d

							UPDATE	t_EHR_OperativeReport
							SET		ScheduledProcedure = 
																(SELECT ai.Procedures
																FROM
																(			
																	SELECT	sdp.BundleKey,
																			STUFF((	SELECT  '' + sp.cpp
																					FROM #t sp
																					WHERE sp.BundleKey = sdp.BundleKey
																					ORDER BY BundleKey
																					FOR XML PATH('')), 1, 0, '') [Procedures]
																	FROM #t sdp
																	GROUP BY sdp.BundleKey
												
																) as ai),
									PerformedProcedure =
																( SELECT bi.Procedures
																	FROM
																	(			
																		SELECT	sdp.BundleKey,
																				STUFF((	SELECT '' + sp.cpp 
																						FROM #t2 sp
																						WHERE sp.BundleKey = sdp.BundleKey
																						ORDER BY BundleKey
																						FOR XML PATH('')), 1, 0, '') [Procedures]
																		FROM #t2 sdp
																		GROUP BY sdp.BundleKey
												
																	) as bi),
									Implants = (
											SELECT bi.Implants
											FROM
											(			
												SELECT	sdp.BundleKey,
														STUFF((	SELECT ';' + sp.Implants 
																FROM #t3 sp
																WHERE sp.BundleKey = sdp.BundleKey
																ORDER BY BundleKey
																FOR XML PATH('')), 1, 1, '') [Implants]
												FROM #t3 sdp
												GROUP BY sdp.BundleKey
										
											) as bi),
											Specimens = (
										SELECT bi.Specimens
											FROM
											(			
												SELECT	sdp.BundleKey,
														STUFF((	SELECT ';' + sp.Specimens 
																FROM #t4 sp
																WHERE sp.BundleKey = sdp.BundleKey
																ORDER BY BundleKey
																FOR XML PATH('')), 1, 1, '') [Specimens]
												FROM #t4 sdp
												GROUP BY sdp.BundleKey
										
											) as bi)
							
					OUTPUT	'U', deleted.*, inserted.* 
					INTO	#t_EHR_OperativeReport_Audit
					OUTPUT	inserted.*
					WHERE t_EHR_OperativeReport.ChartKey= @chartKey  
					AND t_EHR_OperativeReport.ModuleKey=@moduleKey

					INSERT INTO #UpdateLog VALUES (@moduleKey, @workflowKey,'t_EHR_OperativeReport', NULL, NULL, 'U')
					
					DROP TABLE #T,#T2

					--setp 3. update anesthsia provider
					UPDATE	t_EHR_OperativeReport
					SET		AnesthesiaProvider = InitialAnesthesiaProviderName
					OUTPUT	'U', deleted.*, inserted.* 
					INTO	#t_EHR_OperativeReport_Audit
					OUTPUT	inserted.*
					FROM	t_EHR_Anesthesia ans
					WHERE	ans.BundleKey =  @AssociatedBundleKey
					AND		t_EHR_OperativeReport.ChartKey= @chartKey  
					AND     t_EHR_OperativeReport.ModuleKey=@moduleKey

					INSERT INTO #UpdateLog VALUES (@moduleKey, @workflowKey,'t_EHR_OperativeReport', NULL, NULL, 'U')
				
										

				  DROP TABLE #T3
				  DROP TABLE #T4

				  -- Udpate anesthsia type (Vitals Anesthesia Graph)
				   UPDATE	orb
				   SET		AnesthesiaType = at.[Description]
				   OUTPUT	'U', deleted.*, inserted.* 
				   INTO	#t_EHR_OperativeReport_Audit
				   OUTPUT	inserted.*
				   FROM	t_EHR_OperativeReport orb 
				   JOIN t_EHR_VitalsAnesthesiaGraph va 
				   ON orb.ChartKey=va.ChartKey	
				   JOIN	 [t_AnesthesiaType]	at  
				   ON at.[AnesthesiaType]= va.AnesthesiaType
				   WHERE	orb.ChartKey= @chartKey  
				   AND orb.ModuleKey=@moduleKey 
					
					INSERT INTO #UpdateLog VALUES (@moduleKey, @workflowKey,'t_EHR_OperativeReport', NULL, NULL, 'U')
		
				END -- End of (If BundleTemplate Key is not NULL)
								
					
		
				IF @AssociatedPhysicianID IS NOT NULL AND  @AssociatedBundleKey IS NOT NULL
				BEGIN
				 
					 UPDATE odd 
					 SET PreSigned= od.PreSigned 
					 OUTPUT	'U', deleted.*, inserted.* 
					 INTO	#t_EHR_OperativeReportDocumentDetail_Audit
					 OUTPUT	inserted.*
					 FROM t_EHR_OperativeReportDocumentDetail odd 
					 JOIN t_EHR_OperativeReportDocument od 
					 ON od.PatientDocKey=odd.PatientDocKey 
					 WHERE od.VisitKey=@visitKey 
					 AND odd.PreSigned<>od.PreSigned

					 INSERT INTO #UpdateLog VALUES (@moduleKey, @workflowKey,'t_EHR_OperativeReportDocumentDetail', NULL, NULL, 'U')
				 
					 INSERT t_EHR_OperativeReportDocumentDetail 
					 (
					 ChartKey,
					 WorkflowKey,
					 ModuleKey,
					 PatientDocKey,
					 PatientDocDescription,
					 DatePerformed,
					 CreateBy,
					 CreateDate,
					 PreSigned
					 )
					 OUTPUT	'I', inserted.*,inserted.*	
					 INTO	#t_EHR_OperativeReportDocumentDetail_Audit
					 OUTPUT	inserted.*
					 SELECT
					 @ChartKey,
					 @WorkflowKey,
					 @ModuleKey,
					 PatientDocKey,
					 PatientDocDescription,
					 DatePerformed,
					 @userID,
					 getDate(),
					 PreSigned  
					 FROM  t_EHR_OperativeReportDocument 
					 WHERE AssignedPhysicianID=@AssociatedPhysicianID
					 AND AssignedBundle= @AssociatedBundleKey
					 AND Status='A'
					 AND VisitKey=@visitKey 
					 AND DocumentType IN ('Op Report','PostOpRpt') 
					 AND PatientDocKey NOT IN
					 (
					  Select PatientDocKey 
					  FROM t_EHR_OperativeReportDocumentDetail
					  WHERE ModuleKey=@moduleKey 
					  AND Status='A' 
					  AND ChartKey=@chartKey
					 )

					 INSERT INTO #UpdateLog VALUES (@moduleKey, @workflowKey,'t_EHR_OperativeReportDocumentDetail', NULL, NULL, 'I')

				 	--If documents have been unassigned from the Physicians from the Admin tab, set them to inactive here
					
					  UPDATE t_EHR_OperativeReportDocumentDetail 
					  SET Status='I' 
					  OUTPUT	'U', deleted.*, inserted.* 
					  INTO	#t_EHR_OperativeReportDocumentDetail_Audit
					  OUTPUT	inserted.*
					  WHERE ModuleKey=@moduleKey  
					  AND ChartKey=@chartKey AND 				
					  PatientDocKey NOT IN
					  (
					  Select PatientDocKey 
					  FROM t_EHR_OperativeReportDocument 
					  WHERE AssignedPhysicianID=@AssociatedPhysicianID
					  AND Status='A' 
					  AND VisitKey=@visitKey
					  )
					  INSERT INTO #UpdateLog VALUES (@moduleKey, @workflowKey,'t_EHR_OperativeReportDocumentDetail', NULL, NULL, 'U')
					 
				END
			
	END


	ELSE IF @action = 'D'
		BEGIN
		
			UPDATE	t_EHR_OperativeReport
			SET		Status = 'I'
					,DeactivateDate = @actionDate
					,DeactivateBy = @userID
			FROM	t_EHR_OperativeReport
			WHERE	ChartKey = @chartKey 
			AND		Status IN ('A','D')
			AND		ModuleKey = @moduleKey
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
     ,@value = N'Rev Date: 06/01/17'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_CRUD_OperativeReport'
GO