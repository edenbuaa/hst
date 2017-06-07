DECLARE @w TABLE (WorkflowTemplateKey INT NOT NULL)

-- workflow template  is not loose in any chart and is not in a bundle and is not used in any charts
--  can totally get rid of these and their related workflowmoduletemplate records
INSERT @w
SELECT	wt.WorkflowTemplateKey
FROM	t_EHR_WorkflowTemplate wt
WHERE	wt.CenterID = 1
AND		wt.[Status] = 'A'
AND		NOT EXISTS (	SELECT	cwt.*
						FROM	t_EHR_ChartWorkflowTemplate cwt
						WHERE	cwt.WorkflowTemplateKey = wt.WorkflowTemplateKey)
AND		NOT EXISTS (	SELECT	bwt.*
						FROM	t_EHR_BundleWorkflowTemplate bwt
						WHERE	bwt.WorkflowTemplateKey = wt.WorkflowTemplateKey)
AND		NOT EXISTS	(	SELECT	w.*
						FROM	t_EHR_Workflow w
						WHERE	w.WorkflowTemplateKey = wt.WorkflowTemplateKey);


-- workflow template is in a bundle, but container is inactive
--   can toss
INSERT @w
SELECT	wt.WorkflowTemplateKey
FROM	t_EHR_WorkflowTemplate wt
JOIN	t_EHR_BundleWorkflowTemplate bwt
ON		bwt.WorkflowTemplateKey = wt.WorkflowTemplateKey
WHERE	wt.CenterID = 1
AND		wt.[Status] = 'A'
AND		bwt.Status = 'I'

-- workflow template is in a bundle, but container is inactive
--   can toss
INSERT @w
SELECT	wt.WorkflowTemplateKey
FROM	t_EHR_WorkflowTemplate wt
JOIN	t_EHR_BundleWorkflowTemplate bwt
ON		bwt.WorkflowTemplateKey = wt.WorkflowTemplateKey
JOIN	t_EHR_ChartBundleTemplate cbt
ON		cbt.BundleTemplateKey = bwt.BundleTemplateKey
WHERE	wt.CenterID = 1
AND		wt.[Status] = 'A'
AND		bwt.Status = 'A'
AND		cbt.Status = 'I'

-- workflow template is in a bundle, but container is inactive
--   can toss
INSERT @w
SELECT	wt.WorkflowTemplateKey
FROM	t_EHR_WorkflowTemplate wt
JOIN	t_EHR_BundleWorkflowTemplate bwt
ON		bwt.WorkflowTemplateKey = wt.WorkflowTemplateKey
JOIN	t_EHR_ChartBundleTemplate cbt
ON		cbt.BundleTemplateKey = bwt.BundleTemplateKey
JOIN	t_EHR_ChartTemplate ct
ON		ct.ChartTemplateKey = cbt.ChartTemplateKey
WHERE	wt.CenterID = 1
AND		wt.[Status] = 'A'
AND		bwt.Status = 'A'
AND		cbt.Status = 'A'
AND		ct.Status = 'I'

-- workflow template is loose in chart, but container is inactive
--   can toss
INSERT @w
SELECT	wt.WorkflowTemplateKey
FROM	t_EHR_WorkflowTemplate wt
JOIN	t_EHR_ChartWorkflowTemplate cwt
ON		cwt.WorkflowTemplateKey = wt.WorkflowTemplateKey
WHERE	wt.CenterID = 1
AND		wt.[Status] = 'A'
AND		cwt.Status = 'I'

-- workflow template is loose in chart, but container is inactive
--   can toss
INSERT @w
SELECT	wt.WorkflowTemplateKey
FROM	t_EHR_WorkflowTemplate wt
JOIN	t_EHR_ChartWorkflowTemplate cwt
ON		cwt.WorkflowTemplateKey = wt.WorkflowTemplateKey
JOIN	t_EHR_ChartTemplate ct
ON		ct.ChartTemplateKey = cwt.ChartTemplateKey
WHERE	wt.CenterID = 1
AND		wt.[Status] = 'A'
AND		cwt.Status = 'A'
AND		ct.Status = 'I'

-- workflow in a bundle but bundle not hooked to a chart
INSERT @w
SELECT	wt.WorkflowTemplateKey
FROM	t_EHR_WorkflowTemplate wt
JOIN	t_EHR_BundleWorkflowTemplate bwt
ON		bwt.WorkflowTemplateKey = wt.WorkflowTemplateKey
LEFT OUTER JOIN	t_EHR_ChartBundleTemplate cbt
ON		cbt.BundleTemplateKey = bwt.BundleTemplateKey
WHERE	wt.CenterID = 1
AND		wt.[Status] = 'A'
AND		bwt.Status = 'A'
AND		cbt.ChartBundleTemplateKey IS NULL

select * from @w

DECLARE workflowcursor CURSOR LOCAL FOR 
SELECT	workflowtemplatekey
FROM	@w

OPEN workflowcursor

DECLARE @WorkflowTemplateKey INT;

FETCH NEXT FROM workflowcursor INTO @WorkflowTemplateKey
WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE	t_EHR_WorkflowModuleTemplate
	SET		Status = 'I'
			,DeactivateBy = 'mshubat'
			,DeactivateDate = GETDATE()
	WHERE	WorkflowTemplateKey = @WorkflowTemplateKey

	UPDATE	t_EHR_WorkflowTemplate
	SET		Status = 'I'
			,DeactivateBy = 'mshubat'
			,DeactivateDate = GETDATE()
	WHERE	WorkflowTemplateKey = @WorkflowTemplateKey

	FETCH NEXT FROM workflowcursor INTO @WorkflowTemplateKey
END
CLOSE workflowcursor
DEALLOCATE workflowcursor