using eChartWCF.SQL;
using eChartWCF.Utilities;
using EHRProxy.Updates;
using Hst.DataAccess;
using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using EHRProxy;
using Hst.Core;
using System.Collections;
namespace eChartWCF
{
    public partial class ChartFacade : IChartFacade
    {
        public GenericResponse PublishChartTemplate(ChartTemplateRequest chartTemplate, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[4];
            sqlParams[0] = new SqlParameter("@ChartTemplateName", chartTemplate.Name);
            sqlParams[1] = new SqlParameter("@CenterID", centerId);
            sqlParams[2] = new SqlParameter("@UserID", userId);
            sqlParams[3] = new SqlParameter("@Now", chartTemplate.PublishDate);
            var result = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_PublishChartTemplate", sqlParams, centerId, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message" }
               : new GenericResponse { Code = 0, Messages = "Successfully published the Chart Template" };
        }

        public GenericResponse SaveChartTemplate(string chartTemplateName, string chartTemplateXML, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[4];
            sqlParams[0] = new SqlParameter("@ChartTemplateName", chartTemplateName);
            sqlParams[1] = new SqlParameter("@ChartTemplateXML", chartTemplateXML);
            sqlParams[2] = new SqlParameter("@CenterId", centerId);
            sqlParams[3] = new SqlParameter("@UserId", userId);
            var result = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_SaveChartTemplate", sqlParams, centerId, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message" }
               : new GenericResponse { Code = 0, Messages = "Successfully saved the Chart Template" };
        }

        public GenericResponse DeActivateChartTemplate(string chartTemplateName, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[3];
            sqlParams[0] = new SqlParameter("@ChartTemplateName", chartTemplateName);
            sqlParams[1] = new SqlParameter("@CenterId", centerId);
            sqlParams[2] = new SqlParameter("@UserID", userId);
            var result = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_ChartTemplate_DeActivate", sqlParams, centerId, userId);
            if (!result)
                return new GenericResponse { Code = 1, Messages = "Error message" };
            DataSet ds;
            result = getSavedChartTemplates(centerId, userId, out ds);
            if (!result)
                return new GenericResponse { Code = 1, Messages = "Failed to load Chart Templates after deleting" };
            return new GenericResponse { Code = 0, Messages = "Successfully deleted the Chart Template", DataSet = ds };
        }

        public GenericResponse GetSavedChartTemplates(int centerId, string userId
            )
        {
            DataSet ds;
            var result = getSavedChartTemplates(centerId, userId, out ds);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        private bool getSavedChartTemplates(int centerId, string userId, out DataSet ds)
        {
            ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterId", centerId);
            return Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetSavedChartTemplates", ds, sqlParams, new[] { "ChartTemplates" }, centerId, userId);
        }

        public GenericResponse GetSavedChartTemplate(string chartTemplateName, int centerId, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@ChartTemplateName", chartTemplateName);
            sqlParams[1] = new SqlParameter("@CenterId", centerId);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetSavedChartTemplate", ds, sqlParams, new[] { "ChartTemplate" }, centerId, userId);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };

        }

        public GenericResponse GetQuestionCategories(int centerId, string userId)
        {
            var ds = new DataSet();
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetQuestionCategories", ds, new SqlParameter[] { }, new[] { "QuestionCategories" }, centerId, userId);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse GetAreas(int centerId, string userId)
        {
            var ds = new DataSet();
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetAreas", ds, new SqlParameter[] { }, new[] { "Areas" }, centerId, userId);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse GetConsentQuestionnaireTemplateMappingTypes(int centerId, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterId", centerId);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetConsentQuestionnaireTemplateMappingTypes", ds, sqlParams, new[] { "ConsentQuestionnaireTemplateMappingTypes" }, centerId, userId);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };

        }

        public GenericResponse GetChartDesignerModuleTemplates(int centerId, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterId", centerId);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetModuleTemplates", ds, sqlParams, new[] { "ModuleTemplates" }, centerId, userId);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse GetChartDesignerConsentTypes(int centerId, string userId)
        {

            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterId", centerId);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetConsentTypes", ds, sqlParams, new[] { "ConsentTypes" }, centerId, userId);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        bool addCategoryToQuestionTemplate(int questionTemplateKey, int categoryKey, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@QuestionTemplateKey", questionTemplateKey);
            sqlParams[1] = new SqlParameter("@CategoryKey", categoryKey);
            return Dalc.ExecuteProcedure("p_EHR_ChartDesigner_AddCategoryToQuestionTemplate", sqlParams, centerId, userId);

        }

        bool deleteCategoryFromQuestionTemplate(int questionTemplateKey, int categoryKey, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@QuestionTemplateKey", questionTemplateKey);
            sqlParams[1] = new SqlParameter("@CategoryKey", categoryKey);
            return Dalc.ExecuteProcedure("p_EHR_ChartDesigner_DeleteCategoryFromQuestionTemplate", sqlParams, centerId, userId);
        }

        public GenericResponse AddQuestionTemplate(QuestionTemplateRequest questionTemplate, int centerId, string userId)
        {
            int parentQuestionTemplateKey;
            bool success;
            success = addQuestionTemplate(questionTemplate, centerId, userId, out parentQuestionTemplateKey);
            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to add the Question Template" };

            int questionTemplateKey;
            questionTemplate.SubQuestions.ForEach((subQuestion) =>
            {
                subQuestion.ParentQuestionTemplateKey = parentQuestionTemplateKey;
                success = addQuestionTemplate(subQuestion, centerId, userId, out questionTemplateKey);
                if (!success)
                    return;
            });

            questionTemplate.Categories.ForEach((category) => addCategoryToQuestionTemplate(parentQuestionTemplateKey, category.QuestionCategoryKey, centerId, userId));

            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to add subquestions to the Question Template" };
            return new GenericResponse { Code = 0, Messages = "Successfully added the Question Template" };
        }

        bool addQuestionTemplate(QuestionTemplateRequest questionTemplate, int centerId, string userId, out int questionTemplateKey)
        {
            var sqlParams = new SqlParameter[13];
            questionTemplate.QuestionID = Guid.NewGuid().ToString();
            sqlParams[0] = new SqlParameter("@QuestionText", questionTemplate.QuestionText);
            sqlParams[1] = new SqlParameter("@ShortName", questionTemplate.ShortName);
            sqlParams[2] = new SqlParameter("@QuestionTypeID", questionTemplate.QuestionTypeId);
            sqlParams[3] = new SqlParameter("@RhetoricalID", questionTemplate.RhetoricalId.GetValueOrDefault() == 0 ? null : questionTemplate.RhetoricalId);
            sqlParams[4] = new SqlParameter("@Required", questionTemplate.Required);
            sqlParams[5] = new SqlParameter("@Protected", questionTemplate.Protected);
            sqlParams[6] = new SqlParameter("@InHouseLabResult", questionTemplate.InHouseLabResult);
            sqlParams[7] = new SqlParameter("@QuestionID", questionTemplate.QuestionID);
            sqlParams[8] = new SqlParameter("@CenterID", centerId);
            sqlParams[9] = new SqlParameter("@UserID", userId);
            sqlParams[10] = new SqlParameter("@ParentQuestionTemplateKey", questionTemplate.ParentQuestionTemplateKey.GetValueOrDefault() == 0 ? null : questionTemplate.ParentQuestionTemplateKey);
            sqlParams[11] = new SqlParameter("@Ordinal", questionTemplate.Ordinal);
            sqlParams[12] = new SqlParameter("@QuestionTemplateKey", SqlDbType.Int) { Direction = ParameterDirection.Output };

            var result = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_AddQuestionTemplate", sqlParams, centerId, userId);
            questionTemplateKey = sqlParams[12].Value.SafeDbNull<int>();
            return result;

        }

        public GenericResponse DeleteQuestionnaireTemplate(int questionnaireTemplateKey, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@QuestionnaireTemplateKey", questionnaireTemplateKey);
            sqlParams[1] = new SqlParameter("@UserId", userId);
            var success = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_DeactivateQuestionnaireTemplate", sqlParams, centerId, userId);
            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to delete the Questionnaire Template" };

            DataSet ds;
            success = getAllQuestionnaireTemplates(centerId, userId, "Date", "", out ds);
            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to retreive the Questionnaire Templates after deletion", DataSet = null };
            return new GenericResponse { Code = 0, Messages = "Success", DataSet = ds };
        }

        public GenericResponse DeleteQuestionTemplate(int questionTemplateKey, int centerId, string userId)
        {
            DataSet ds;
            bool success;
            success = getQuestionnairesForQuestionTemplate(questionTemplateKey, centerId, userId, out ds);
            if (!success)
            return new GenericResponse { Code = 1, Messages = "Failed to delete the Question Template" };
            if(ds.Tables["QuestionnaireTemplates"].Rows.Count>0)
            {
                return new GenericResponse { Code = 1, Messages = "Question Template is in use in a Questionnaire Template. It must be deleted from the Questionnaire Template before it can be deleted" };
            }
             success = deleteQuestionTemplate(questionTemplateKey, centerId, userId);
            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to delete the Question Template" };
            
            success = getQuestionTemplates(centerId, "", userId, out ds);

            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to retreive the Question Templates after deletion", DataSet = null };
            return new GenericResponse { Code = 0, Messages = "Success", DataSet = ds };
        }

        bool getQuestionnairesForQuestionTemplate(int questionTemplateKey, int centerId, string userId, out DataSet ds)
        {
            var sqlParams = new SqlParameter[1];
            ds = new DataSet();
            sqlParams[0] = new SqlParameter("@QuestionTemplateKey", questionTemplateKey);
             return Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetQuestionnairesForQuestionTemplate", ds, sqlParams, new[] { "QuestionnaireTemplates" }, centerId, userId);            

        }

        protected bool deleteQuestionTemplate(int questionTemplateKey, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@QuestionTemplateKey", questionTemplateKey);
            sqlParams[1] = new SqlParameter("@UserId", userId);
            return Dalc.ExecuteProcedure("p_EHR_ChartDesigner_DeactivateQuestionTemplate", sqlParams, centerId, userId);

        }

        public GenericResponse UpdateQuestionTemplate(QuestionTemplateRequest questionTemplate, QuestionTemplateRequest questionTemplateOld, int centerId, string userId)
        {
            bool success;
            success = updateQuestionTemplate(questionTemplate, centerId, userId);
            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to update the Question Template" };

            var subQuestionsToAdd = new List<QuestionTemplateRequest>();
            var subQuestionsToDelete = new List<QuestionTemplateRequest>();
            var subQuestionsToUpdate= new List<QuestionTemplateRequest>();
            var categoriesToAdd = new List<QuestionCategoryType>();
            var categoriesToDelete = new List<QuestionCategoryType>();

            questionTemplate.SubQuestions.ForEach(x =>
            {
                if (questionTemplateOld.SubQuestions.Where(y => y.QuestionTemplateKey == x.QuestionTemplateKey).Select(y => y).Count() == 0)
                {
                    subQuestionsToAdd.Add(x);
                }

            });

            questionTemplate.SubQuestions.ForEach(x =>
           {
               if (questionTemplateOld.SubQuestions.Where(y => y.QuestionTemplateKey == x.QuestionTemplateKey).Select(y => y).Count() > 0)
               {
                   subQuestionsToUpdate.Add(x);
               }
           });

            questionTemplateOld.SubQuestions.ForEach(x =>
            {
                if (questionTemplate.SubQuestions.Where(y => y.QuestionTemplateKey == x.QuestionTemplateKey).Select(y => y).Count() == 0)
                {
                    subQuestionsToDelete.Add(x);
                }

            });

            questionTemplate.Categories.ForEach(x =>
            {
                if (questionTemplateOld.Categories.Where(y => y.QuestionCategoryKey == x.QuestionCategoryKey).Select(y => y).Count() == 0)
                {
                    categoriesToAdd.Add(x);
                }

            });

            questionTemplateOld.Categories.ForEach(x =>
            {
                if (questionTemplate.Categories.Where(y => y.QuestionCategoryKey == x.QuestionCategoryKey).Select(y => y).Count() == 0)
                {
                    categoriesToDelete.Add(x);
                }

            });


            subQuestionsToAdd.ForEach(question =>
            {
                int key;
                question.ParentQuestionTemplateKey = questionTemplate.QuestionTemplateKey;
                addQuestionTemplate(question, centerId, userId, out key);

            });
            subQuestionsToDelete.ForEach(question =>
            {              
                deleteQuestionTemplate(question.QuestionTemplateKey, centerId, userId);

            });

            subQuestionsToUpdate.ForEach(question =>
            {
                 updateQuestionTemplate(question, centerId, userId);
             });

            categoriesToAdd.ForEach(category =>
             {
                 addCategoryToQuestionTemplate(questionTemplate.QuestionTemplateKey, category.QuestionCategoryKey, centerId, userId);
             });

            categoriesToDelete.ForEach(category =>
             {
                 deleteCategoryFromQuestionTemplate(questionTemplate.QuestionTemplateKey, category.QuestionCategoryKey, centerId, userId);
             });

           
            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to update the Sub-Question in the Question Template", DataSet = null };

            if (subQuestionsToAdd.Count > 0 || subQuestionsToDelete.Count > 0)//If Sub Questions have changed, then we need to update the Questionnaire Templates that use them
            {
                DataSet ds;
                getQuestionnairesForQuestionTemplate(questionTemplate.QuestionTemplateKey, centerId, userId, out ds);
                return new GenericResponse { Code = 0, Messages = "Successfully updated the Question Template", DataSet = ds };
            }
            else
            {
                return new GenericResponse { Code = 0, Messages = "Successfully updated the Question Template", DataSet = null };
            }
        }

       

        bool updateQuestionTemplate(QuestionTemplateRequest questionTemplate, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[6];
            sqlParams[0] = new SqlParameter("@QuestionTemplateKey", questionTemplate.QuestionTemplateKey);
            sqlParams[1] = new SqlParameter("@QuestionText", questionTemplate.QuestionText);
            sqlParams[2] = new SqlParameter("@Required", questionTemplate.Required);
            sqlParams[3] = new SqlParameter("@InHouseLabResult", questionTemplate.InHouseLabResult);
            sqlParams[4] = new SqlParameter("@Ordinal", questionTemplate.Ordinal);
            sqlParams[5] = new SqlParameter("@UserID", userId);
            var result = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_UpdateQuestionTemplate", sqlParams, centerId, userId);
            return result;
        }

        public GenericResponse AddQuestionnaireTemplate(QuestionnaireTemplateRequest questionnaireTemplateRequest, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[9];
            if (string.IsNullOrEmpty(questionnaireTemplateRequest.QuestionnaireDesignID))
                questionnaireTemplateRequest.QuestionnaireDesignID = Guid.NewGuid().ToString();
            sqlParams[0] = new SqlParameter("@QuestionnaireName", questionnaireTemplateRequest.QuestionnaireName);
            sqlParams[1] = new SqlParameter("@OldQuestionnaireTemplateKey", questionnaireTemplateRequest.QuestionnaireTemplateKey);
            sqlParams[2] = new SqlParameter("@QuestionnaireDesignID", questionnaireTemplateRequest.QuestionnaireDesignID);
            sqlParams[3] = new SqlParameter("@CenterID", centerId);
            sqlParams[4] = new SqlParameter("@UserID", userId);
            sqlParams[5] = new SqlParameter("@Protected", questionnaireTemplateRequest.Protected);
            sqlParams[6] = new SqlParameter("@Status", questionnaireTemplateRequest.Status);
            sqlParams[7] = new SqlParameter("@Category", questionnaireTemplateRequest.Category);
            sqlParams[8] = new SqlParameter("@QuestionnaireTemplateKey", SqlDbType.Int) { Direction = ParameterDirection.Output };

            var result = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_AddQuestionnaireTemplate", sqlParams, centerId, userId);
            int questionnaireTemplateKey = sqlParams[8].Value.SafeDbNull<int>();
            if (!result)
                return new GenericResponse { Code = 1, Messages = "Failed to add the Questionniare Template" };

            /* Note : The t_EHR_QuestionnaireQuestion table expects the questions and subQuestions all to be inserted.
             This is how the Questions Module expects the Questions in  a Questionnaire to be stored
             So, iterating over the Questions and inserting the Sub-Questions along with the ordinals.*/
            var ordinal = 1;
            questionnaireTemplateRequest.QuestionTemplates.ForEach((question) => {
                question.Ordinal = ordinal;
             result = addQuestionToQuestionnaireTemplate(questionnaireTemplateKey, question, centerId, userId); 
                if (!result)return;
              
                question.SubQuestions.OrderBy(x=>x.Ordinal).ToList().ForEach((subQuestion) => { 
                    subQuestion.Ordinal = ++ordinal;
                result = addQuestionToQuestionnaireTemplate(questionnaireTemplateKey, subQuestion, centerId, userId);
                if (!result) return;
                });
                ordinal++;
            });

            if (!result)
                return new GenericResponse { Code = 1, Messages = "Failed to add Question to the Questionniare Template" };
            return new GenericResponse { Code = 0, Messages = "Successfully added Question to Questionniare Template" };
        }

        bool addQuestionToQuestionnaireTemplate(int questionnaireTemplateKey, QuestionTemplateRequest questionTemplate, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[5];
            sqlParams[0] = new SqlParameter("@QuestionnaireTemplateKey", questionnaireTemplateKey);
            sqlParams[1] = new SqlParameter("@QuestionTemplateKey", questionTemplate.QuestionTemplateKey);
            sqlParams[2] = new SqlParameter("@Ordinal", questionTemplate.Ordinal);
            sqlParams[3] = new SqlParameter("@Required", questionTemplate.RequiredInQuestionnaire);
            sqlParams[4] = new SqlParameter("@CustomTemplate", questionTemplate.CustomTemplate);
            return Dalc.ExecuteProcedure("p_EHR_ChartDesigner_AddQuestionToQuestionnaireTemplate", sqlParams, centerId, userId);

        }

        public GenericResponse UpdateQuestionnaireTemplate(QuestionnaireTemplateRequest questionnaireTemplateRequest, int centerId, string userId)
        {
            bool success = updateQuestionnaireTemplate(questionnaireTemplateRequest, centerId, userId);

            questionnaireTemplateRequest.QuestionTemplates.ForEach(question => { success = updateQuestionInQuestionnaireTemplate(questionnaireTemplateRequest.QuestionnaireTemplateKey, question, centerId, userId); if (!success)return; });
            return !success
                ? new GenericResponse { Code = 1, Messages = "Failed to update the Questionnaire Template" }
                : new GenericResponse { Code = 0, Messages = "Successfully updated the Questionnaire Template" };
        }

        bool updateQuestionnaireTemplate(QuestionnaireTemplateRequest questionnaireTemplateRequest, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[3];
            sqlParams[0] = new SqlParameter("@QuestionnaireTemplateKey", questionnaireTemplateRequest.QuestionnaireTemplateKey);
            sqlParams[1] = new SqlParameter("@Category", questionnaireTemplateRequest.Category);
            sqlParams[2] = new SqlParameter("@UserID", userId);
            return Dalc.ExecuteProcedure("p_EHR_ChartDesigner_UpdateQuestionnaireTemplate", sqlParams, centerId, userId);
        }

        bool updateQuestionInQuestionnaireTemplate(int questionnaireTemplateKey, QuestionTemplateRequest questionTemplateRequest, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[4];
            sqlParams[0] = new SqlParameter("@QuestionnaireTemplateKey", questionnaireTemplateKey);
            sqlParams[1] = new SqlParameter("@QuestionTemplateKey", questionTemplateRequest.QuestionTemplateKey);
            sqlParams[2] = new SqlParameter("@Required", questionTemplateRequest.RequiredInQuestionnaire);
            sqlParams[3] = new SqlParameter("@Ordinal", questionTemplateRequest.Ordinal);
            sqlParams[4] = new SqlParameter("@CustomTemplate", questionTemplateRequest.CustomTemplate);
            return Dalc.ExecuteProcedure("p_EHR_ChartDesigner_UpdateQuestionInQuestionnaireTemplate", sqlParams, centerId, userId);
        }

        public GenericResponse GetCenterConfiguration(int centerId, string userId)
        {
            var ds = new DataSet();
           
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetCenterConfiguration", ds, new  SqlParameter[]{}, 
                new[]{ "CenterConfiguration", "ChartConfiguration" ,"PatientLocations"}, centerId, userId);

            return !result
            ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
            : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };

        }

        public GenericResponse UpdateCenterConfiguration(CenterConfigurationRequest centerConfiguration, int centerId, string userId)
        {
            bool success = false;

            var sqlParams = new SqlParameter[31];
            sqlParams[0] = new SqlParameter("@AutoDeleteUnsignedOrders", centerConfiguration.AutoDeleteUnsignedOrders);
            sqlParams[1] = new SqlParameter("@AutoRemoveUnableToContact", centerConfiguration.AutoRemoveUnableToContact);
            sqlParams[2] = new SqlParameter("@AvatarDays", centerConfiguration.AvatarDays == null ? 30 : centerConfiguration.AvatarDays);
            sqlParams[3] = new SqlParameter("@CanRessignTaskToOthers", centerConfiguration.CanRessignTaskToOthers);
            sqlParams[4] = new SqlParameter("@DefaultAppointmentColor", centerConfiguration.DefaultAppointmentColor);
            sqlParams[5] = new SqlParameter("@DefaultLabKey", centerConfiguration.DefaultLabKey);
            sqlParams[6] = new SqlParameter("@DefaultLateStartThreshold", centerConfiguration.DefaultLateStartThreshold == null ? 7 : centerConfiguration.DefaultLateStartThreshold);
            sqlParams[7] = new SqlParameter("@DefaultPreferredLanguageCode", centerConfiguration.DefaultPreferredLanguageCode);
            sqlParams[8] = new SqlParameter("@DefaultSystemOfMeasure", centerConfiguration.DefaultSystemOfMeasure);
            sqlParams[9] = new SqlParameter("@DefaultTemperatureUnit", centerConfiguration.DefaultTemperatureUnit);
            sqlParams[10] = new SqlParameter("@DischargeLocation", centerConfiguration.DischargeLocation);
            sqlParams[11] = new SqlParameter("@InactivityTimeOutMinutes", centerConfiguration.InactivityTimeOutMinutes == null ? 480 : centerConfiguration.InactivityTimeOutMinutes);
            sqlParams[12] = new SqlParameter("@LeftSideAppointmentColor", centerConfiguration.LeftSideAppointmentColor);
            sqlParams[13] = new SqlParameter("@PriorQuestionDays", centerConfiguration.PriorQuestionDays == null ? 90 : centerConfiguration.PriorQuestionDays);
            sqlParams[14] = new SqlParameter("@NeedAnesStartTimeBackFillIntraOpRoomInTime", centerConfiguration.NeedAnesStartTimeBackFillIntraOpRoomInTime);
            sqlParams[15] = new SqlParameter("@MergePreferenceCards", centerConfiguration.MergePreferenceCards);
            sqlParams[16] = new SqlParameter("@RegistrationCompleteLocation", centerConfiguration.RegistrationCompleteLocation);
            sqlParams[17] = new SqlParameter("@RegistrationLocation", centerConfiguration.RegistrationLocation);
            sqlParams[18] = new SqlParameter("@RequireHPAttestOverride", centerConfiguration.RequireHPAttestOverride);
            sqlParams[19] = new SqlParameter("@RequireProcConsentOverride", centerConfiguration.RequireProcConsentOverride);
            sqlParams[20] = new SqlParameter("@RightSideAppointmentColor", centerConfiguration.RightSideAppointmentColor);
            sqlParams[21] = new SqlParameter("@ShowSupervisingAnesthesiaProvider", centerConfiguration.ShowSupervisingAnesthesiaProvider);
            sqlParams[22] = new SqlParameter("@UpdateVisitClinicalWithRoomTimesAtNight", centerConfiguration.UpdateVisitClinicalWithRoomTimesAtNight);
            sqlParams[23] = new SqlParameter("@UseRoomTimesForAnesthesia", centerConfiguration.UseRoomTimesForAnesthesia);
            sqlParams[24] = new SqlParameter("@UserID", userId);
            sqlParams[25] = new SqlParameter("@Now", centerConfiguration.ChangeDate);
            sqlParams[26] = new SqlParameter("@ArchiveAuditLogWaitDays", centerConfiguration.ArchiveAuditLogWaitDays == null ? 30 : centerConfiguration.ArchiveAuditLogWaitDays);
            sqlParams[27] = new SqlParameter("@CenterID", centerConfiguration.CenterId);
            sqlParams[28] = new SqlParameter("@TrackLateStart", centerConfiguration.TrackLateStart);
            sqlParams[29] = new SqlParameter("@AutoDeleteAnesthesiaUnsignedOrders", centerConfiguration.AutoDeleteAnesthesiaUnsignedOrders);
            sqlParams[30] = new SqlParameter("@AutoProcessSuppliesUsed", centerConfiguration.AutoProcessSuppliesUsed);
            success = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_UpdateCenterConfiguration", sqlParams, centerId, userId);

            var dsConfiguration = GetCenterConfiguration(centerId, userId).DataSet;

            return !success
                ? new GenericResponse { Code = 1, Messages = "Failed to update the Center Configuration" }
                : new GenericResponse { Code = 0, Messages = "Successfully updated the Center Configuration", DataSet = dsConfiguration };
        }

        public GenericResponse SearchQuestionnaireTemplates(int centerId, string userId, SearchCriteria qtsc)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[2];

            sqlParams[0] = new SqlParameter("@CenterID", centerId);
            sqlParams[1] = new SqlParameter("@searchText", qtsc.SearchText);

            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_SearchQuestionnaireTemplates", ds, sqlParams, new[] { "QuestionnaireTemplates" }, centerId, userId);

            return !result
            ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
            : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };

        }

        public GenericResponse SearchQuestionTemplates(int centerId, string userId, SearchCriteria qtsc)
        {
            DataSet ds;
            var result = searchQuestionTemplates(centerId, userId, qtsc, out ds);

            return !result
             ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
             : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };
        }

        bool searchQuestionTemplates(int centerId, string userId, SearchCriteria qtsc, out DataSet ds)
        {
            ds = new DataSet();
            var sqlParams = new SqlParameter[4];

            sqlParams[0] = new SqlParameter("@CenterID", centerId);
            sqlParams[1] = new SqlParameter("@searchText", qtsc.SearchText);
            sqlParams[2] = new SqlParameter("@categoryKey", qtsc.CategoryKey);
            sqlParams[3] = new SqlParameter("@areaKey", qtsc.AreaKey);
            return Dalc.ExecuteDataSet("p_EHR_ChartDesigner_SearchQuestionTemplates", ds, sqlParams, new[] { "QuestionTemplates", "SubQuestions" }, centerId, userId);
        }

        public GenericResponse GetQuestionTemplates(int centerId, string searchText, string userId)
        {
            DataSet ds;
            var result = getQuestionTemplates(centerId, searchText, userId, out ds);

            return !result
             ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
             : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };
        }

        bool getQuestionTemplates(int centerId, string searchText, string userId, out DataSet ds)
        {
            ds = new DataSet();
            var sqlParams = new SqlParameter[2];

            sqlParams[0] = new SqlParameter("@CenterID", centerId);
            sqlParams[1] = new SqlParameter("@searchText", searchText);

            return Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetQuestionTemplates", ds, sqlParams, new[] { "QuestionTemplates", "SubQuestions" }, centerId, userId);
        }

        public GenericResponse GetFilteredQuestionnaireTemplates(int centerId, string userId, int? categoryKey)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[2];

            sqlParams[0] = new SqlParameter("@CenterID", centerId);
            sqlParams[1] = new SqlParameter("@Category", categoryKey);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetFilteredQuestionnaireTemplates", ds, sqlParams, new[] { "QuestionnaireTemplates" }, centerId, userId);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse GetAllQuestionnaireTemplates(int centerId, string userId, string sort, string search)
        {
            DataSet ds;
            var result = getAllQuestionnaireTemplates(centerId, userId, sort, search, out ds);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        bool getAllQuestionnaireTemplates(int centerId, string userId, string sort, string search, out DataSet ds)
        {
            ds = new DataSet();
            var sqlParams = new SqlParameter[3];

            sqlParams[0] = new SqlParameter("@CenterID", centerId);
            sqlParams[1] = new SqlParameter("@sort", sort);
            sqlParams[2] = new SqlParameter("@searchText", search);
            return Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetQuestionnaireTemplates", ds, sqlParams, new[] { "QuestionnaireTemplates" }, centerId, userId);
        }

        bool getAllConsentMappings(int centerId, string userId, out DataSet ds)
        {
            ds = new DataSet();
            var sqlParams = new SqlParameter[1];

            sqlParams[0] = new SqlParameter("@CenterID", centerId);

            return Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetConsentQuestionnaireTemplates", ds, sqlParams, new[] { "ConsentQuestionnaireTemplates" }, centerId, userId);
        }

        public GenericResponse GetQuestionTemplate(int centerID, int questionTemplateKey, string userId)
        {
            var sqlParams = new SqlParameter[1];
            var ds = new DataSet();
            sqlParams[0] = new SqlParameter("@QuestionTemplateKey", questionTemplateKey);

            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetQuestionTemplate", ds, sqlParams, new[] { "QuestionTemplate", "SubQuestions", "Categories" }, centerID, userId);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse GetQuestionnaireTemplate(int centerID, int questionnaireTemplateKey, string userId)
        {
            DataSet ds = new DataSet();
            var result = getQuestionnaireTemplate(centerID, questionnaireTemplateKey, userId, out ds);
            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }
        protected bool getQuestionnaireTemplate(int centerID, int questionnaireTemplateKey, string userId,out DataSet ds)
        {
            var sqlParams = new SqlParameter[1];
            ds = new DataSet();
            sqlParams[0] = new SqlParameter("@QuestionnaireTemplateKey", questionnaireTemplateKey);

            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetQuestionnaireTemplate", ds, sqlParams, new[] { "QuestionnaireTemplate", "QuestionTemplates", "SubQuestions" }, centerID, userId);
            return result;            
        }

        public bool IsQuestionnaireTemplateInUse(int questionnaireTemplateKey, int centerID, string userId)
        {
            var sqlParams = new SqlParameter[2];

            sqlParams[0] = new SqlParameter("@QuestionnaireTemplateKey", questionnaireTemplateKey);
            sqlParams[1] = new SqlParameter("@Status", SqlDbType.Bit) { Direction = ParameterDirection.Output };
            Dalc.ExecuteProcedure("p_EHR_ChartDesigner_IsQuestionnaireTemplateInUse", sqlParams, centerID, userId);
            return sqlParams[1].Value.SafeDbNull<bool>(false);
        }

        public GenericResponse GetQuestionTypes(int centerID, string userId)
        {
            var ds = new DataSet();
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetQuestionTypes", ds, new SqlParameter[] { }, new[] { "QuestionTypes" }, centerID, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse GetQuestionRhetoricalTypes(int centerID, string userId)
        {
            var ds = new DataSet();
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetQuestionRhetoricalTypes", ds, new SqlParameter[] { }, new[] { "QuestionRhetoricalTypes" }, centerID, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse GetConsentQuestionnaireTemplateMap(string name, int centerID, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            sqlParams[1] = new SqlParameter("@MappingName", name);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetConsentQuestionnaireTemplate", ds, new SqlParameter[] { }, new[] { "ConsentQuestionnaireTemplate" }, centerID, userId);
            return !result
             ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
             : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse AddConsentQuestionnaireTemplateMap(ConsentQuestionnaireTemplate consentQuestionnaireTemplateMap, int centerID, string userId)
        {
            var sqlParams = new SqlParameter[5];
            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            sqlParams[1] = new SqlParameter("@MappingName", consentQuestionnaireTemplateMap.MappingName);
            sqlParams[2] = new SqlParameter("@ConsentTypeID", consentQuestionnaireTemplateMap.ConsentTypeId);
            sqlParams[3] = new SqlParameter("@QuestionnaireTemplateKey", consentQuestionnaireTemplateMap.QuestionnaireTemplateKey);
            sqlParams[4] = new SqlParameter("@User", userId);
            bool success = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_AddConsentQuestionnaireTemplate", sqlParams, centerID, userId);
            return !success
               ? new GenericResponse { Code = 1, Messages = "Failed to add the Consent-Questionnaire Template Mapping" }
               : new GenericResponse { Code = 0, Messages = "Successfully added the Consent-Questionnaire Template Mapping" };
        }

        public GenericResponse DeActivateConsentQuestionnaireTemplateMap(ConsentQuestionnaireTemplate consentQuestionnaireTemplateMap, int centerID, string userId)
        {
            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@ConsentQuestionnaireTemplateID", consentQuestionnaireTemplateMap.ConsentQuestionnaireTemplateId);
            sqlParams[1] = new SqlParameter("@UserId",userId);

            bool success = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_DeActivateConsentQuestionnaireTemplate", sqlParams, centerID, userId);
            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to delete the Consent-Questionnaire Template Mapping" };
            DataSet ds;
            success = getAllConsentMappings(centerID, userId, out ds);
            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to retreive the Consent Mappings after deletion", DataSet = null };
            return new GenericResponse { Code = 0, Messages = "Successfully deleted the Consent-Questionnaire Template Mapping", DataSet = ds };

        }

        public GenericResponse GetConsentQuestionnaireTemplates(int centerID, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetConsentQuestionnaireTemplates", ds, sqlParams, new[] { "ConsentQuestionnaireTemplates" }, centerID, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse UpdateAnesthesiaGraphModuleConfig(int chartMasterKey, AnesthesiaGraphModuleConfig moduleConfig, AnesthesiaGraphModuleConfig oldConfig, int centerID, string userId)
        {
            bool bResult = true;

            bResult = DeleteAnesthesiaGraphModuleConfig(chartMasterKey, centerID, userId);

            if (bResult == false)
                return new GenericResponse { Code = 1, Messages = "Failed to update Anesthesia Module Configuration" };

            moduleConfig.GasConfig.ForEach(x =>
            {             
                if (AddAnesthesiaGraphGasConfig(chartMasterKey, new AnesthesiaGraphGasTypeConfig { GasKey = x.GasKey, GasName =x.GasName,GasOrder=x.GasOrder }, centerID, userId) == false)
                    bResult = false;
            });
                     
            
            moduleConfig.MedicationConfig.ForEach(x =>
            {
                if (AddAnesthesiaGraphMediationConfig(chartMasterKey, new AnesthesiaGraphMedicationTypeConfig
                {
                    MedicationId = x.MedicationId, 
                    MedicationIdType = x.MedicationIdType, 
                    MedicationName = x.MedicationName,
                    MedicationOrder=x.MedicationOrder,
                    RouteKey=x.RouteKey,
                    Route=x.Route,
                    UnitOfMeasure=x.UnitOfMeasure,
                    UnitOfMeasureDescription=x.UnitOfMeasureDescription
                    ,ItemCode=x.ItemCode
                    ,Dose=x.Dose
                    ,DoseIncrement=x.DoseIncrement
                }, centerID, userId) == false)
                    bResult = false;
                   
            });
           

            if(bResult==false)
            return new GenericResponse { Code = 1, Messages = "Failed to update Anesthesia Module Configuration" };
                      
            return new GenericResponse { Code = 0, Messages = "Successfully updated the Anesthesia Medication Configuration" };
        }

        public bool DeleteAnesthesiaGraphModuleConfig(int chartMasterKey, int centerID, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@ChartMasterKey", chartMasterKey);
            return Dalc.ExecuteProcedure("p_EHR_ChartDesigner_DeleteAnesthesiaGraphModuleConfig", sqlParams, centerID, userId);
            
        }

        public GenericResponse GetRouteTypes(int centerID, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterId", centerID);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetRoutes", ds, sqlParams, new[] { "Routes" }, centerID, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse GetUnitOfMeasureTypes(int centerID, string userId)
        {
            var ds = new DataSet();
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetUnitsOfMeasure", ds, new SqlParameter[] { }
                , new[] { "UnitsOfMeasure" }, centerID, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse GetAnesthesiaGraphModuleConfig(int chartMasterKey, int centerID, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@ChartMasterKey", chartMasterKey);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetAnesthesiaGraphConfig", ds, sqlParams, new[] { "AnesthesiaGraphGasConfig", "AnesthesiaGraphMedicationConfig" }, centerID, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse GetAllAnesthesiaMedications(int centerID, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            var result = getAllAnesthesiaMedications(centerID, userId, out ds);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public bool getAllAnesthesiaMedications(int centerID, string userId, out DataSet ds)
        {
            ds= new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetAllAnesthesiaMedications", ds, sqlParams, new[] { "AnesthesiaMedications" }, centerID, userId);
            return result;
        }

        public GenericResponse AddAnesthesiaGas(AnesthesiaGasRequest gas, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[4];
            sqlParams[0] = new SqlParameter("@GasName",gas.GasName);            
            sqlParams[1] = new SqlParameter("@CenterID", centerId);
            sqlParams[2] = new SqlParameter("@UserID", userId);
            sqlParams[3] = new SqlParameter("@Now", gas.CreateDate);
            var result = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_AddAnesthesiaGas", sqlParams, centerId, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error adding" }
               : new GenericResponse { Code = 0, Messages = "Successfully added the Gas" };
        }

        public GenericResponse DeleteAnesthesiaGas(int anesthesiaGasKey, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[3];
            sqlParams[0] = new SqlParameter("@AnesthesiaGasKey", anesthesiaGasKey);
            sqlParams[1] = new SqlParameter("@UserID", userId);
            sqlParams[2] = new SqlParameter("@Now", DateTime.Now);
            var success = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_DeleteAnesthesiaGas", sqlParams, centerId, userId);
            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to delete the Anesthesia Gas" };

            DataSet ds;
            success = getAnesthesiaGases(centerId, userId, out ds);
            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to retreive the Anesthesia Gases after deletion", DataSet = null };
            return new GenericResponse { Code = 0, Messages = "Success", DataSet = ds };
        }

        public GenericResponse AddAnesthesiaMedication(AnesthesiaMedicationRequest med, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[7];
            sqlParams[0] = new SqlParameter("@MedicationID",med.MedicationID);
            sqlParams[1]= new SqlParameter("@MedicationIDType",med.MedicationIDType);
            sqlParams[2] =new SqlParameter("@MedicationName",med.MedicationName);
            sqlParams[3] = new SqlParameter("@ItemCode", med.ItemCode);
            sqlParams[4] = new SqlParameter("@CenterID", centerId);         
            sqlParams[5] = new SqlParameter("@UserID", userId);
            sqlParams[6] = new SqlParameter("@Now", med.CreateDate);
            var result=Dalc.ExecuteProcedure("p_EHR_ChartDesigner_AddAnesthesiaMedication", sqlParams, centerId, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error adding"}
               : new GenericResponse { Code = 0, Messages = "Successfully added the Medication" };
        }

        public GenericResponse  DeleteAnesthesiaMediation(int anesthesiaMedicationKey, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[3];
            sqlParams[0] = new SqlParameter("@AnesthesiaMedicationKey", anesthesiaMedicationKey);
            sqlParams[1] = new SqlParameter("@UserID", userId);
            sqlParams[2] = new SqlParameter("@Now",DateTime.Now);
                var success= Dalc.ExecuteProcedure("p_EHR_ChartDesigner_DeleteAnesthesiaMedication", sqlParams, centerId, userId);
             if (!success)
                 return new GenericResponse { Code = 1, Messages = "Failed to delete the Anesthesia Medication" };

             DataSet ds;
             success =getAllAnesthesiaMedications(centerId, userId, out ds);
             if (!success)
                 return new GenericResponse { Code = 1, Messages = "Failed to retreive the Anesthesia Medications after deletion", DataSet = null };
             return new GenericResponse { Code = 0, Messages = "Success", DataSet = ds };
        }

        protected bool AddAnesthesiaGraphGasConfig(int chartMasterKey, AnesthesiaGraphGasTypeConfig gasConfig, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[5];
            sqlParams[0] = new SqlParameter("@ChartMasterKey", chartMasterKey);
            sqlParams[1] = new SqlParameter("@AnesthesiaGasKey", gasConfig.GasKey);
            sqlParams[2] = new SqlParameter("@AnesthesiaGasName", gasConfig.GasName);
            sqlParams[3] = new SqlParameter("@AnesthesiaGasOrder",gasConfig.GasOrder);
            sqlParams[4] = new SqlParameter("@User", userId);
            return Dalc.ExecuteProcedure("p_EHR_ChartDesigner_AddAnesthesiaGraphGasConfig", sqlParams, centerId, userId);
        }

        protected bool AddAnesthesiaGraphMediationConfig(int chartMasterKey, AnesthesiaGraphMedicationTypeConfig medConfig, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[14];
            sqlParams[0] = new SqlParameter("@ChartMasterKey", chartMasterKey);
            sqlParams[1] = new SqlParameter("@MedicationName", medConfig.MedicationName);
            sqlParams[2] = new SqlParameter("@MedicationId", medConfig.MedicationId);
            sqlParams[3] = new SqlParameter("@MedicationIdType", medConfig.MedicationIdType);
            sqlParams[4] = new SqlParameter("@ItemCode", medConfig.ItemCode);
            sqlParams[5] = new SqlParameter("@FormName", medConfig.FormName);
            sqlParams[6] = new SqlParameter("@MedicationOrder", medConfig.MedicationOrder);            
            sqlParams[7] = new SqlParameter("@RouteKey", medConfig.RouteKey);
            sqlParams[8] = new SqlParameter("@Route", medConfig.Route);
            sqlParams[9] = new SqlParameter("@UnitOfMeasure", medConfig.UnitOfMeasure);
            sqlParams[10] = new SqlParameter("@UnitOfMeasureDescription", medConfig.UnitOfMeasureDescription);
            sqlParams[11] = new SqlParameter("@Dose", medConfig.Dose);
            sqlParams[12] = new SqlParameter("@DoseIncrement", medConfig.DoseIncrement);
            sqlParams[13] = new SqlParameter("@User", userId);
            return Dalc.ExecuteProcedure("p_EHR_ChartDesigner_AddAnesthesiaGraphMedicationConfig", sqlParams, centerId, userId);

        }

        protected bool DeleteAnesthesiaGraphGasConfig(int chartMasterKey, int gasConfigKey, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@ChartMasterKey", chartMasterKey);
            sqlParams[1] = new SqlParameter("@AnesthesiaGasKey", gasConfigKey);            
            return Dalc.ExecuteProcedure("p_EHR_ChartDesigner_DeleteAnesthesiaGraphGasConfig", sqlParams, centerId, userId);

        }

        protected bool DeleteAnesthesiaGraphMediationConfig(int chartMasterKey, int medicationID, string medicationIDType, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[3];
            sqlParams[0] = new SqlParameter("@ChartMasterKey", chartMasterKey);
            sqlParams[1] = new SqlParameter("@MedicationId", medicationID);
            sqlParams[2] = new SqlParameter("@MedicationIdType", medicationIDType);
           
            return Dalc.ExecuteProcedure("p_EHR_ChartDesigner_DeleteAnesthesiaGraphMedicationConfig", sqlParams, centerId, userId);
        }

        public GenericResponse GetChartMasterTemplateTypes(int centerID, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetChartMasterTemplates", ds, sqlParams, new[] { "ChartMasterTemplates" }, centerID, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }


        public GenericResponse GetChartTemplateTypes(int centerID, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetChartTemplates", ds, sqlParams, new[] { "ChartTemplates" }, centerID, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse GetAnesthesiaGasTypes(int centerID, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            var result = getAnesthesiaGases(centerID, userId, out ds);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        private bool getAnesthesiaGases(int centerID, string userId, out DataSet ds)
        {
            ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetAnesthesiaGases", ds, sqlParams, new[] { "AnesthesiaGases" }, centerID, userId);
            return result;          
         }
        public GenericResponse GetAnesthesiaMedicationTypes(int centerID, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetAnesthesiaMedications", ds, sqlParams, new[] { "AnesthesiaMedications" }, centerID, userId);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse UpdateModuleTemplateAlias(ModuleTemplateSelectRequest moduleTemplate,  int centerId, string userId)
        {
           var sqlParams = new SqlParameter[3];
           sqlParams[0] = new SqlParameter("@ModuleTemplateKey", moduleTemplate.ModuleTemplateKey);
           sqlParams[1] = new SqlParameter("@Alias", moduleTemplate.Alias);
           sqlParams[2] = new SqlParameter("@UserID", userId);
           var result= Dalc.ExecuteProcedure("p_EHR_ChartDesigner_UpdateModuleTemplateAlias", sqlParams, centerId, userId);
                       
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error updating"}
               : new GenericResponse { Code = 0, Messages = "Successfully updated the BLOC Alias Configuration" };
           
        }

        public GenericResponse GetModuleTemplate(int moduleTemplateKey, int centerId, string userId)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[1];
            sqlParams[0] = new SqlParameter("@ModuleTemplateKey", moduleTemplateKey);

            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetModuleTemplate", ds,sqlParams,new[] { "ModuleTemplates" },  centerId, userId);

            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };

        }

        public GenericResponse GetAllPrintSets(int centerID, string requestingUserID, string sort, string search)
        {
            DataSet ds = new DataSet();
            var sqlParams = new SqlParameter[3];

            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            sqlParams[1] = new SqlParameter("@sort", sort);
            sqlParams[2] = new SqlParameter("@searchText", search);
            var result = getAllPrintSets(centerID,requestingUserID,sort,search,out ds);

            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        bool getAllPrintSets(int centerId, string userId, string sort, string search, out DataSet ds)
        {
            ds = new DataSet();
            var sqlParams = new SqlParameter[3];

            sqlParams[0] = new SqlParameter("@CenterID", centerId);
            sqlParams[1] = new SqlParameter("@sort", sort);
            sqlParams[2] = new SqlParameter("@searchText", search);
            return Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetPrintSets", ds, sqlParams, new[] { "PrintSets" }, centerId, userId);
        }

        public GenericResponse GetPrintSetBlocs(int centerID, string searchText, string requestingUserID)
        {
            DataSet ds = new DataSet();
            var sqlParams = new SqlParameter[2];

            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            sqlParams[1] = new SqlParameter("@searchText", searchText);

            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetPrintSetBlocs", ds, sqlParams, new[] { "PrintSetBlocs" }, centerID, requestingUserID);
            return !result
                ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
                : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }


        public GenericResponse AddPrintSet(PrintSetRequest printSetRequest, int centerId, string userId)
        {
            var sqlParams = new SqlParameter[6];

            sqlParams[0] = new SqlParameter("@OldPrintSetKey", printSetRequest.PrintSetKey);
            sqlParams[1] = new SqlParameter("@PrintSetName", printSetRequest.PrintSetName);
            sqlParams[2] = new SqlParameter("@CenterID", centerId);
            sqlParams[3] = new SqlParameter("@UserID", userId);
            sqlParams[4] = new SqlParameter("@Status", printSetRequest.Status);
            sqlParams[5] = new SqlParameter("@PrintSetKey", SqlDbType.Int) { Direction = ParameterDirection.Output };

            var result = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_AddPrintSet", sqlParams, centerId, userId);
            int printSetKey = sqlParams[5].Value.SafeDbNull<int>();
            if (!result)
                return new GenericResponse { Code = 1, Messages = "Failed to add the Print Set" };

            //Now , we need to constuct to Areas and Blocs with the New Print Set
            result = AddPrintSetBlocsToPrintSet(printSetRequest, printSetKey, centerId, userId) &
                     AddPrintSetAreasToPrintset(printSetRequest, printSetKey, centerId, userId);
            
            if (!result)
                return new GenericResponse { Code = 1, Messages = "Failed to add Bloc to the Print Set" };
            return new GenericResponse { Code = 0, Messages = "Successfully added Bloc to Print Set" };
        }

        bool AddPrintSetBlocsToPrintSet(PrintSetRequest printSetRequest, int printSetKey, int centerId, string userId)
        {
            var result = true;
            var ordinal = 1;
            printSetRequest.Blocs.ForEach(b => {
                var sqlParams = new SqlParameter[6];
                sqlParams[0] = new SqlParameter("@PrintSetKey", printSetKey);
                sqlParams[1] = new SqlParameter("@ModuleDesignID", b.ModuleDesignID);
                sqlParams[2] = new SqlParameter("@QuestionnaireDesignID", b.QuestionnaireDesignID);
                sqlParams[3] = new SqlParameter("@ConsentID", b.ConsentID);
                sqlParams[4] = new SqlParameter("@Ordinal", ordinal++);
                sqlParams[5] = new SqlParameter("@UserID", userId);
                result = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_AddBlocToPrintSet", sqlParams, centerId, userId);
                if (!result) return;
            });
            return result;
        }

        bool AddPrintSetAreasToPrintset(PrintSetRequest printSetRequest, int printSetKey, int centerId, string userId)
        {
            var result = true;
            printSetRequest.Areas.ForEach(a =>
            {
                var sqlParams = new SqlParameter[3];
                sqlParams[0] = new SqlParameter("@PrintSetKey", printSetKey);
                sqlParams[1] = new SqlParameter("@AreaKey", a.AreaKey);               
                sqlParams[2] = new SqlParameter("@UserID", userId);
                result = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_AddAreaToPrintSet", sqlParams, centerId, userId);
                if (!result) return;               
            });
            return result;
        }

        public GenericResponse DeletePrintSet(int printSetKey, int centerID, string userId)
        {
            var sqlParams = new SqlParameter[2];
            sqlParams[0] = new SqlParameter("@PrintSetKey", printSetKey);
            sqlParams[1] = new SqlParameter("@UserId", userId);
            var success = Dalc.ExecuteProcedure("p_EHR_ChartDesigner_DeactivatePrintSet", sqlParams, centerID, userId);
            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to delete the Print Set" };

            DataSet ds;
            success = getAllPrintSets(centerID, userId, "Date", "", out ds);
            if (!success)
                return new GenericResponse { Code = 1, Messages = "Failed to retreive the Questionnaire Templates after deletion", DataSet = null };
            return new GenericResponse { Code = 0, Messages = "Success", DataSet = ds };
        }


        public GenericResponse GetPrintSet(int centerID, int printSetkey, string userId)
        {
            DataSet ds = new DataSet();
            var result = getPrintSet(centerID, printSetkey, userId, out ds);
            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        protected bool getPrintSet(int centerID, int printSetkey, string userId, out DataSet ds)
        {
            var sqlParams = new SqlParameter[2];
            ds = new DataSet();
            sqlParams[0] = new SqlParameter("@PrintSetKey", printSetkey);
            sqlParams[1] = new SqlParameter("@CenterID", centerID);

            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_GetPrintSet", ds, sqlParams, new[] { "PrintSet", "PrintSetBlocs", "PrintSetAreas", "PrintSetWorkflowInUse" }, centerID, userId);
            return result;
        }

        public GenericResponse SearchPrintSetBlocs(int centerId, string userId, SearchCriteria qtsc)
        {
            DataSet ds;
            var result = searchPrintSetBlocs(centerId, userId, qtsc, out ds);

            return !result
             ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
             : new GenericResponse { Code = 0, Messages = string.Empty, DataSet = ds };
        }

        bool searchPrintSetBlocs(int centerId, string userId, SearchCriteria qtsc, out DataSet ds)
        {
            ds = new DataSet();
            var sqlParams = new SqlParameter[3];

            sqlParams[0] = new SqlParameter("@CenterID", centerId);
            sqlParams[1] = new SqlParameter("@searchText", qtsc.SearchText);
            sqlParams[2] = new SqlParameter("@AreaKey", qtsc.AreaKey);
            return Dalc.ExecuteDataSet("p_EHR_ChartDesigner_SearchPrintSetBlocs", ds, sqlParams, new[] { "PrintSetBlocs" }, centerId, userId);
        }

        #region Discharge Instruction Editor
        private GenericResponse InvokeDischargeInstructions(int centerID, char action, int? dischargeInstructionKey, string title, string caption, string instruction, string userID, string[] tables)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[8];

            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            sqlParams[1] = new SqlParameter("@Action", action);
            sqlParams[2] = new SqlParameter("@DischargeInstructionKey", dischargeInstructionKey);
            sqlParams[3] = new SqlParameter("@Title", title);
            sqlParams[4] = new SqlParameter("@Caption", caption);
            sqlParams[5] = new SqlParameter("@Instruction", instruction);
            sqlParams[6] = new SqlParameter("@UserID", userID);
            sqlParams[7] = new SqlParameter("@Now", DateTime.Now);

            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_DischargeInstruction", ds, sqlParams, tables, centerID, userID);

            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse CreateDischargeInstruction(int centerID, DischargeInstructionUpdateRequest request, string userID)
        {
            return InvokeDischargeInstructions(centerID, 'C', null, request.Title, request.Caption, request.Instruction, userID, new[] { "t_EHR_DischargeInstruction" });
        }

        public GenericResponse GetDischargeInstructions(int centerID, string userID)
        {
            return InvokeDischargeInstructions(centerID, 'R', null, null, null, null, userID, new[] { "t_EHR_DischargeInstruction" });
        }

        public GenericResponse GetDischargeInstruction(int centerID, int dischargeInstructionKey, string userID)
        {
            return InvokeDischargeInstructions(centerID, 'S', dischargeInstructionKey, null, null, null, userID, new[] { "t_EHR_DischargeInstruction" });
        }

        public GenericResponse UpdateDischargeInstruction(int centerID, DischargeInstructionUpdateRequest request, string userID)
        {
            return InvokeDischargeInstructions(centerID, 'U', request.DischargeInstructionKey, request.Title, request.Caption, request.Instruction, userID, new[] { "t_EHR_DischargeInstruction" });
        }

        public GenericResponse DeactivateDischargeInstruction(int centerID, int dischargeInstructionKey, string userID)
        {
            return InvokeDischargeInstructions(centerID, 'D', dischargeInstructionKey, null, null, null, userID, new[] { "t_EHR_DischargeInstruction" });
        }

        public GenericResponse GetDischargeInstructionUsage(int centerID, int dischargeInstructionKey, string userID)
        {
            return InvokeDischargeInstructions(centerID, 'V', dischargeInstructionKey, null, null, null, userID, new[] { "t_EHR_DischargeInstructionSet" });
        }
        #endregion

        #region Discharge Instruction Set Editor
        private GenericResponse InvokeDischargeInstructionSets(int centerID, char action, int? dischargeInstructionSetKey, string setName, string instructions, string userID, string[] tables)
        {
            var ds = new DataSet();
            var sqlParams = new SqlParameter[7];

            sqlParams[0] = new SqlParameter("@CenterID", centerID);
            sqlParams[1] = new SqlParameter("@Action", action);
            sqlParams[2] = new SqlParameter("@DischargeInstructionSetKey", dischargeInstructionSetKey);
            sqlParams[3] = new SqlParameter("@SetName", setName);
            sqlParams[4] = new SqlParameter("@Instructions", instructions);
            sqlParams[5] = new SqlParameter("@UserID", userID);
            sqlParams[6] = new SqlParameter("@Now", DateTime.Now);

            var result = Dalc.ExecuteDataSet("p_EHR_ChartDesigner_DischargeInstructionSet", ds, sqlParams, tables, centerID, userID);

            return !result
               ? new GenericResponse { Code = 1, Messages = "Error message", DataSet = null }
               : new GenericResponse { Code = 0, Messages = "Success message", DataSet = ds };
        }

        public GenericResponse CreateDischargeInstructionSet(int centerID, UpdateDischargeInstructionSetRequest request, string userID)
        {
            return InvokeDischargeInstructionSets(centerID, 'C', null, request.setName, request.ToXML(), userID, new[] { "t_EHR_DischargeInstructionSet" });
        }

        public GenericResponse GetDischargeInstructionSets(int centerID, string userID)
        {
            return InvokeDischargeInstructionSets(centerID, 'R', null, null, null, userID, new[] { "t_EHR_DischargeInstructionSet" });
        }

        public GenericResponse GetDischargeInstructionSet(int centerID, int dischargeInstructionSetKey, string userID)
        {
            return InvokeDischargeInstructionSets(centerID, 'S', dischargeInstructionSetKey, null, null, userID, new[] { "t_EHR_DischargeInstructionSet", "t_EHR_DischargeInstructionSetDetail" });
        }

        public GenericResponse UpdateDischargeInstructionSet(int centerID, UpdateDischargeInstructionSetRequest request, string userID)
        {
            return InvokeDischargeInstructionSets(centerID, 'U', request.dischargeInstructionSetKey, request.setName, request.ToXML(), userID, new[] { "t_EHR_DischargeInstructionSet" });
        }

        public GenericResponse DeactivateDischargeInstructionSet(int centerID, int dischargeInstructionSetKey, string userID)
        {
            return InvokeDischargeInstructionSets(centerID, 'D', dischargeInstructionSetKey, null, null, userID, new[] { "Usage" });
        }

        public GenericResponse GetDischargeInstructionSetUsage(int centerID, int dischargeInstructionSetKey, string userID)
        {
            return InvokeDischargeInstructionSets(centerID, 'V', dischargeInstructionSetKey, null, null, userID, new[] { "Usage" });
        }
        #endregion
    }
}