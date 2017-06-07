using Hst.DataAccess;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using EHRProxy;
using Hst.Core;

namespace eChartWCF
{
    public partial class ChartFacade : IChartFacade
    {
        /// <summary>
        /// Get Chart Header information
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="chartKey"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public GenericResponse GetChartHeaderInfos(int centerID, int chartKey, string requestingUserID)
        {
            var ds = new DataSet();

            var procedureParameters = new SqlParameter[7];
            procedureParameters[0] = new SqlParameter("@action", "T");
            procedureParameters[1] = new SqlParameter("@centerID", centerID);
            procedureParameters[2] = new SqlParameter("@chartKey", chartKey);
            procedureParameters[3] = new SqlParameter("@workflowKey", 0);
            procedureParameters[4] = new SqlParameter("@moduleKey", 0);
            procedureParameters[5] = new SqlParameter("@userID", requestingUserID);
            procedureParameters[6] = new SqlParameter("@actionDate", DateTime.Now);

            var result = Dalc.ExecuteDataSet("p_EHR_CRUD_Chart", ds, procedureParameters,
                                                new[] { "TableNames" },
                                                centerID, requestingUserID);
            var tableNames = new List<string>();

            if (result)
            {
                foreach (DataRow item in ds.Tables[0].Rows)
                {
                    tableNames.Add(item["TableName"].ToString());
                }

                procedureParameters[0] = new SqlParameter("@action", "R");

                var resp = Dalc.ExecuteDataSet("p_EHR_CRUD_Chart", ds, procedureParameters,
                                                    tableNames.ToArray(),
                                                    centerID, requestingUserID);

                return !resp
                    ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                    : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };
            }
            else
                return new GenericResponse { Code = 1, Messages = "Error message", DataSet = null };
        }

        /// <summary>
        /// Get Chart Workflow information
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="chartKey"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public GenericResponse GetChartWorkflowInfos(int centerID, int chartKey, int workflowKey, string requestingUserID)
        {
            var ds = new DataSet();

            var procedureParameters = new SqlParameter[7];
            procedureParameters[0] = new SqlParameter("@action", "T");
            procedureParameters[1] = new SqlParameter("@centerID", centerID);
            procedureParameters[2] = new SqlParameter("@chartKey", chartKey);
            procedureParameters[3] = new SqlParameter("@workflowKey", workflowKey);
            procedureParameters[4] = new SqlParameter("@moduleKey", 0);
            procedureParameters[5] = new SqlParameter("@userID", requestingUserID);
            procedureParameters[6] = new SqlParameter("@actionDate", DateTime.Now);

            var result = Dalc.ExecuteDataSet("p_EHR_CRUD_Chart", ds, procedureParameters,
                                                new[] { "TableNames" },
                                                centerID, requestingUserID);
            var tableNames = new List<string>();

            if (result)
            {
                foreach (DataRow item in ds.Tables[0].Rows)
                {
                    tableNames.Add(item["TableName"].ToString());
                }

                procedureParameters[0] = new SqlParameter("@action", "R");

                var resp = Dalc.ExecuteDataSet("p_EHR_CRUD_Chart", ds, procedureParameters,
                                                    tableNames.ToArray(),
                                                    centerID, requestingUserID);

                return !resp
                    ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                    : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };
            }
            else
                return new GenericResponse { Code = 1, Messages = "Error message", DataSet = null };
        }
        
        public DataSet GetWorkflowDataSet(int centerID, int chartKey, int workflowKey, int physicianID, string requestingUserID)
        {
            SqlParameter[] procedureParameters = new SqlParameter[6];

            procedureParameters[0] = new SqlParameter("@ChartKey", chartKey);
            procedureParameters[1] = new SqlParameter("@WorkflowKey", workflowKey);
            procedureParameters[2] = new SqlParameter("@CenterID", centerID);
            procedureParameters[3] = new SqlParameter("@physicianID", physicianID);
            procedureParameters[4] = new SqlParameter("@UserID", requestingUserID);
            procedureParameters[5] = new SqlParameter("@WorkstationTime", DateTime.Now);


            DataSet workflowDs = Dalc.ExecuteDataSet("p_EHR_CRUD_GetWorkflow", procedureParameters, centerID, requestingUserID);

            return workflowDs;
        }

        /// <summary>
        /// Get exist workflows by chartKey
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="chartKey"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public GenericResponse GetWorkflows(int centerID, int chartKey, string requestingUserID)
        {
            var ds = new DataSet();

            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@chartKey", chartKey);

            var result = Dalc.ExecuteDataSet("p_EHR_GetWorkflows", ds, sqlParams,
                                                new[] { "workflows",
                                                        "areas"
                                                      },
                                                centerID, requestingUserID);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };
        }

        /// <summary>
        /// Get workflow templates
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="workflowKey"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public GenericResponse GetWorkflowTemplates(int centerID, int areaKey, string requestingUserID)
        {
            var ds = new DataSet();

            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@centerID", centerID);
            sqlParams[1] = new SqlParameter("@areaKey", areaKey);

            var result = Dalc.ExecuteDataSet("p_EHR_GetWorkflowTemplates", ds, sqlParams,
                                                new[] { "WorkflowTemplates" },
                                                centerID, requestingUserID);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };
        }

        /// <summary>
        /// Add workflow to chart
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="chartKey"></param>
        /// <param name="bundleKey"></param>
        /// <param name="workflowTemplateKey"></param>
        /// <param name="areaKey"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public GenericResponse AddWorkflowFromTemplates(int centerID, int chartKey, int? bundleKey, int workflowTemplateKey, int areaKey, string requestingUserID)
        {
            var sqlParams = new SqlParameter[7];
            sqlParams[0] = new SqlParameter("@ChartKey", chartKey);
            sqlParams[1] = new SqlParameter("@BundleKey", bundleKey);
            sqlParams[2] = new SqlParameter("@WorkflowTemplateKey", workflowTemplateKey);
            sqlParams[3] = new SqlParameter("@AreaKey", areaKey);
            sqlParams[4] = new SqlParameter("@UserID", requestingUserID);
            sqlParams[5] = new SqlParameter("@ActionDate", DateTime.Now);

            sqlParams[6] = new SqlParameter("@WorkflowKey", SqlDbType.Int) { Direction = ParameterDirection.Output };

            var result = Dalc.ExecuteProcedure("p_EHR_CreateWorkflowFromTemplate", sqlParams, centerID, requestingUserID);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message" }
                : new GenericResponse { Code = 0, Messages = "Success message" };
        }

        /// <summary>
        /// Check the workflowTemplate with Bundles
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="chartKey"></param>
        /// <param name="workflowTemplateKey"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public GenericResponse IsWorkflowTemplateWithBundle(int centerID, int chartKey, int workflowTemplateKey, string requestingUserID)
        {
            var ds = new DataSet();

            var sqlParams = new SqlParameter[3];
            sqlParams[0] = new SqlParameter("@workflowTemplateKey", workflowTemplateKey);
            sqlParams[1] = new SqlParameter("@chartKey", chartKey);
            sqlParams[2] = new SqlParameter("@requiresBundle", SqlDbType.Bit) { Direction = ParameterDirection.Output };

            var result = Dalc.ExecuteDataSet("p_EHR_WorkflowTemplateRequiresBundle", ds, sqlParams,
                new[] { "WorkflowGroup" },
                centerID, requestingUserID);

            var isBundled = Convert.ToBoolean(sqlParams[2].Value);
            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message" }
                : (isBundled ? new GenericResponse { Code = 2, Messages = "Bundle", DataSet = ds } : new GenericResponse { Code = 0, Messages = "No Bundle", DataSet = ds });
        }

        /// <summary>
        /// Get BundleTemplates by CenterId
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public GenericResponse GetBundleTemplates(int centerID, string requestingUserID)
        {
            var ds = new DataSet();

            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@centerID", centerID);

            var result = Dalc.ExecuteDataSet("p_EHR_GETBundleTemplates", ds, sqlParams,
                                                new[] { "BundleTemplates" },
                                                centerID, requestingUserID);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };
        }

        /// <summary>
        /// Add new bundle to chart from a selected bundle template
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="chartKey"></param>
        /// <param name="bundleTemplateKey"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public GenericResponse AddBundleToChart(int centerID, int chartKey, int bundleTemplateKey, string requestingUserID)
        {
            var sqlParams = new SqlParameter[4];
            sqlParams[0] = new SqlParameter("@ChartKey", chartKey);
            sqlParams[1] = new SqlParameter("@bundleTemplateKey", bundleTemplateKey);
            sqlParams[2] = new SqlParameter("@userID", requestingUserID);
            sqlParams[3] = new SqlParameter("@actionDate", DateTime.Now);

            var result = Dalc.ExecuteProcedure("p_EHR_AddBundleToChart", sqlParams, centerID, requestingUserID);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message" }
                : new GenericResponse { Code = 0, Messages = "Success message" };
        }

        /// <summary>
        /// Remove the workflow
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="workflowKey"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public GenericResponse RemoveWorkflow(int centerID, int workflowKey, string requestingUserID)
        {
            var sqlParams = new SqlParameter[3];
            sqlParams[0] = new SqlParameter("@WorkflowKey", workflowKey);
            sqlParams[1] = new SqlParameter("@UserID", requestingUserID);
            sqlParams[2] = new SqlParameter("@ActionDate", DateTime.Now);

            var result = Dalc.ExecuteProcedure("p_EHR_RemoveWorkflow", sqlParams, centerID, requestingUserID);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message" }
                : new GenericResponse { Code = 0, Messages = "Success message" };
        }

        /// <summary>
        /// Get all questionnaire templates
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public GenericResponse GetQuestionnaireTemplates(BaseRequest request)
        {
            var ds = new DataSet();

            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@centerID", request.centerID);

            var result = Dalc.ExecuteDataSet("p_EHR_GetQuestionnaireTemplates", ds, sqlParams,
                                                new[] { "QuestionnaireTemplates" },
                                                request.centerID, request.requestingUserID);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };
        }

        /// <summary>
        /// Get all Consent Types
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public GenericResponse GetConsentTypes(GetConsentTypeRequest request)
        {
            var ds = new DataSet();

            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@centerID", request.centerID);
            sqlParams[1] = new SqlParameter("@workflowKey", request.workflowKey);

            var result = Dalc.ExecuteDataSet("p_EHR_GetConsentTypes", ds, sqlParams,
                                                new[] { "ConsentTypes" },
                                                request.centerID, request.requestingUserID);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };
        }

        /// <summary>
        /// Get all Center Consent List
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public GenericResponse GetConsentOptions(GetConsentTypeRequest request)
        {
            var ds = new DataSet();

            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@centerID", request.centerID);
            sqlParams[1] = new SqlParameter("@workflowKey", request.workflowKey);

            var result = Dalc.ExecuteDataSet("p_EHR_GetConsentOptions", ds, sqlParams,
                                                new[] { "ConsentOptions" },
                                                request.centerID, request.requestingUserID);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };
        }
        
        /// <summary>
        /// Get workflow's functionKey
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="workflowKey"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public string GetWorkflowFunctionKey(int centerID, int workflowKey, string requestingUserID)
        {
            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@workflowKey", workflowKey);
            sqlParams[1] = new SqlParameter("@functionKey", SqlDbType.Int) { Direction = ParameterDirection.Output };

            Dalc.ExecuteProcedure("p_EHR_GetWorkflowFunctionKey", sqlParams, centerID, requestingUserID);

            return sqlParams[1].Value.ToString();
        }

        /// <summary>
        /// Get Module's functionKey
        /// </summary>
        /// <param name="centerID"></param>
        /// <param name="moduleKey"></param>
        /// <param name="requestingUserID"></param>
        /// <returns></returns>
        public string GetModuleFunctionKey(int centerID, int moduleKey, string requestingUserID)
        {
            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@moduleKey", moduleKey);
            sqlParams[1] = new SqlParameter("@functionKey", SqlDbType.Int) { Direction = ParameterDirection.Output };

            Dalc.ExecuteProcedure("p_EHR_GetModuleFunctionKey", sqlParams, centerID, requestingUserID);

            return sqlParams[1].Value.ToString();
        }

        public DataSet GetChartImages(int centerId, int chartKey, string requestingUserID)
        {
            SqlParameter[] procedureParameters = new SqlParameter[3];

            procedureParameters[0] = new SqlParameter("@chartKey", chartKey);
            procedureParameters[1] = new SqlParameter("@centerID", centerId);
            procedureParameters[2] = new SqlParameter("@userID", requestingUserID);

            DataSet imagesDs = Dalc.ExecuteDataSet("p_EHR_CRUD_ChartImages", procedureParameters, centerId, requestingUserID);

            return imagesDs;
        }

        public DataSet GetChartDocuments(int centerId, int chartKey, string requestingUserID)
        {
            SqlParameter[] procedureParameters = new SqlParameter[3];

            procedureParameters[0] = new SqlParameter("@chartKey", chartKey);
            procedureParameters[1] = new SqlParameter("@centerID", centerId);
            procedureParameters[2] = new SqlParameter("@userID", requestingUserID);

            DataSet docDs = Dalc.ExecuteDataSet("p_EHR_CRUD_ChartDocuments", procedureParameters, centerId, requestingUserID);

            // get archive file if blob is null            
            foreach (DataRow dr in docDs.Tables[0].Rows)
            {
                var blob = dr["DocBlob"] ;

                dr["DocBlob"] = blob is DBNull ? GetPatientDocumentBlob((int)dr["PatientDocKey"],centerId,requestingUserID,System.DateTime.Now) : blob;
            }

            return docDs;
        }
    }
}