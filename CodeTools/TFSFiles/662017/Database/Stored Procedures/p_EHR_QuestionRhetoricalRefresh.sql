IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'p_EHR_QuestionRhetoricalRefresh ') AND type in (N'P', N'PC'))
	DROP PROCEDURE p_EHR_QuestionRhetoricalRefresh;
GO
-- =============================================================================================================
-- Author:			Bill Teng
-- Create date:		3/17/16
-- Description:		Create responses for question templates
--				  
-- Parameters		

-- =============================================================================================================
CREATE PROCEDURE p_EHR_QuestionRhetoricalRefresh 
    @ChartKey						INT
	,@BundleKey						INT -- pass null if not part of a bundle
	,@WorkflowKey					INT
	,@ModuleKey						INT
	,@UserID						VARCHAR(60)
	,@ActionDate					DATETIME
--WITH ENCRYPTION

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @personKey INT
	DECLARE @patientName VARCHAR(200)
	DECLARE @dob VARCHAR(10)
	DECLARE @gender VARCHAR(10)
	DECLARE @age VARCHAR(60)
	DECLARE @bmi VARCHAR(10)
	
	DECLARE @physicians VARCHAR(200)
	DECLARE @visitKey INT
	DECLARE @centerID INT

	DECLARE @anesthesiologist VARCHAR(200)
	DECLARE @implants VARCHAR(200)
	DECLARE @specimens VARCHAR(200)
	DECLARE @anesthesia VARCHAR(100)
	DECLARE @procedures VARCHAR(1024)
	DECLARE @procedures0 VARCHAR(1024)
	DECLARE @proceduresAll VARCHAR(1024)
	DECLARE @dos VARCHAR(50)
	DECLARE @patientIDVisit VARCHAR(20)
	DECLARE @allergies VARCHAR(512)
	DECLARE @questionnaireTemplateKey INT

BEGIN TRY
	
	SELECT	@centerID = c.CenterID
	FROM	t_EHR_Module m
	JOIN	t_EHR_Chart c
	ON		c.ChartKey = m.ChartKey
	WHERE	m.ModuleKey = @ModuleKey

	SELECT	@questionnaireTemplateKey = m.QuestionnaireTemplateKey
	FROM	t_EHR_Module m
	JOIN	t_EHR_QuestionnaireTemplate qnt
	ON		m.QuestionnaireTemplateKey = qnt.QuestionnaireTemplateKey
	WHERE	m.ModuleKey = @ModuleKey
	--AND		qnt.CenterID = @centerID -- see comment in consent crud proc
	--AND		qnt.[Status] = 'A' -- see comment in consent crud proc

	-- common
	SELECT 		@personKey = PersonKey
				,@visitKey = VisitKey
				,@centerID = CenterID				
	FROM		t_EHR_Chart
	WHERE		ChartKey = @ChartKey;
	
	-- 105-1,2,A,B
	SELECT		@patientName = p.LastName + ', ' + p.FirstName
				,@dob =  CONVERT(VARCHAR, p.BirthDate, 101) --mm/dd/yyyy
				,@gender = CASE WHEN p.Gender = 'M' THEN 'Male' ELSE 'Female' END 
				,@age =  CASE WHEN (CHARINDEX(' ', dbo.f_rptCalculateAge(p.BirthDate, v.AdmitDate)) = 0 AND
							LEN(dbo.f_rptCalculateAge(p.BirthDate, v.AdmitDate)) > 0) 
							THEN	dbo.f_rptCalculateAge(p.BirthDate, v.AdmitDate) + ' year(s)' 
							ELSE	dbo.f_rptCalculateAge(p.BirthDate, v.AdmitDate) END
	FROM 		t_visit v
	JOIN		t_Person p
	ON			p.PersonKey = v.PersonKey
	WHERE		v.VisitKey = @visitKey

	

	-- 105-C
	SELECT 		@bmi = Convert(varchar, BMI)
	FROM 		t_EHR_HeightWeightBMI
	WHERE		ChartKey = @ChartKey;	
	SET @bmi = ISNULL(@bmi, 'N/A');

	-- 105-D
	SELECT 		@patientIDVisit = dbo.f_EHR_PatientIdVisit(@ChartKey);

	-- 105-E
	SELECT 		@allergies = dbo.f_EHR_Allergies(@ChartKey);

	-- 105-3
	SELECT		@dos = dbo.f_EHR_GetDOS(@ChartKey, @WorkflowKey, @visitKey);

	-- call this to self refresh the scheduled procedures
	EXEC p_EHR_SyncSchedProcPathways @chartKey,@bundleKey,@userID

	-- 105-4/15/16
	SELECT		@procedures = dbo.f_EHR_GetProcedures(@ChartKey, @visitKey, 1);
	SELECT		@procedures0 = ISNULL(dbo.f_EHR_GetProcedures(@ChartKey, @visitKey, 0), 'N/A');
	SELECT		@proceduresAll = dbo.f_EHR_GetProcedures(@ChartKey, @visitKey, NULL);

	-- 105-5
	-- need to decide where best source of information is.  could use preopanesthesiaassessment or even the anesthesia module.  both have timing issues: when the patient signs is in preop but best data not avaiable until intraop.
	SELECT		@anesthesia = at.[Description]
	FROM		t_VisitClinical vc
	JOIN		t_AnesthesiaType at
	ON			vc.AnesTypePrim = at.AnesthesiaType
	WHERE		vc.VisitKey = @visitKey;

	-- 105-6
	SELECT		@physicians = dbo.f_EHR_GetPhysicians(@visitKey, @centerID, 1);

	-- 105-7
	-- they rarely schedule the anesthesiologist in pathways.  the most definitive point where we know who the anesthesiologist is
	-- is when they tap the Anesthesia Start time picker.  creates timing issues: can't present them with the anesthesiologist's name on 
	-- the consent form until they are unconsious
	SELECT		@anesthesiologist = dbo.f_EHR_GetPhysicians(@visitKey, @centerID, 3);
	SET @anesthesiologist = ISNULL(@anesthesiologist, 'N/A');

	-- 105-8
	-- timeing issue: at time of consent signing, would only know what the implants are if they are on the preference card.
	SELECT		@implants = COALESCE(@implants + ',', '') + ItemDescription + ' - '+ [Description]
	FROM		t_EHR_ImplantLogDetail
	WHERE		ChartKey = @ChartKey 
	--AND			ModuleKey = @ModuleKey
	AND			[status] = 'A';
	SET @implants = ISNULL(@implants, 'N/A');

	-- 105-9
	-- big timing problem.  specimens only known at intra-op time.  nothing to show in preop when patient signs consent.
	SELECT		@specimens = COALESCE(@specimens + ',', '') + SpecimenDescription
	FROM		t_EHR_SpecimenDetail
	WHERE		ChartKey = @ChartKey 
	--AND			ModuleKey = @ModuleKey
	AND			[status] = 'A';
	SET @specimens = ISNULL(@specimens, 'N/A');


	WITH EHR_RhetoricalResponse (RhetoricalID, TextResponse)
	AS (
	SELECT	*
		FROM(VALUES
		 ( 1, @patientName )
		,( 2, @dob )
		,( 3, @dos )
		,( 4, @procedures )
		,( 5, @anesthesia )
		,( 6, @physicians )
		,( 7, @anesthesiologist )
		,( 8, @implants )
		,( 9, @specimens )
		,( 10, @gender )
		,( 11, @age )
		,( 12, @bmi )
		,( 13, @patientIDVisit )
		,( 14, @allergies )
		,( 15, @procedures0 )
		,( 16, @proceduresAll )
		)
		AS	temp (QuestionID, TextResponse)
	)
	Update t_EHR_QuestionResponse
	SET		TextResponse = 	i.TextResponse
	FROM  (
		SELECT 	qr.ResponseKey, r.TextResponse
		FROM 	EHR_RhetoricalResponse r
		JOIN	t_EHR_QuestionTemplate qt
		ON		r.RhetoricalID = qt.RhetoricalID
		JOIN	t_EHR_QuestionnaireQuestionTemplate qnqt
		ON		qt.QuestionTemplateKey = qnqt.QuestionTemplateKey
		JOIN	t_EHR_QuestionResponse qr
		ON		qr.QuestionTemplateKey = qt.QuestionTemplateKey	
		WHERE	qr.ChartKey = @ChartKey
		AND		qr.[Status] = 'A'
		AND		qnqt.QuestionnaireTemplateKey = @questionnaireTemplateKey
		AND		qt.RhetoricalID IS NOT NULL
		AND		qt.CenterID = @centerID
		) i
	WHERE	i.ResponseKey = t_EHR_QuestionResponse.ResponseKey	
	

END TRY
BEGIN CATCH
	EXEC p_RethrowError;

	RETURN -1;
END CATCH

END

GO

EXEC sp_addextendedproperty 
     N'VSS-Version'
     ,@value = N'Rev Date: 3/17/16'
     ,@level0type = N'Schema', @level0name = dbo
     ,@level1type = N'PROCEDURE' ,  @level1name = 'p_EHR_QuestionRhetoricalRefresh '
GO
