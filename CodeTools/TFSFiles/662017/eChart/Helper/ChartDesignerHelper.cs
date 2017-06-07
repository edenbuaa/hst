using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using eChart.ChartDesigner;
using Hst.Core;
using EHRProxy.Updates;
using Newtonsoft.Json;
using System.Xml;
using System.Text;
using System.IO;
using System.Xml.Serialization;
using eChartWCF;
using System.Collections;
using System.Dynamic;

namespace eChart.Helper
{
    public class ChartDesignerHelper
    {        
        public static readonly string AnesthesiaHistoryModuleName = "Anesthesia History"; //113
        public static readonly string PatientEducationModuleName = "Patient Education"; //082
        public static readonly string PreOpQuestionnaiareTemplateName = "Pre-op Patient Education";
        public static readonly string IntraOpQuestionnaiareTemplateName = "Intra-op Patient Education";
        public static readonly string PACUQuestionnaiareTemplateName = "PACU Patient Education";
        public static readonly string PostOpQuestionnaiareTemplateName = "Post-op Patient Education";
        public static readonly string AnesthesiaQuestionnaiareTemplateName = "Anesthesia Patient Education";
        public static readonly string PatientSafetyMeasuresModuleName = "Patient Safety Measures";
        public static readonly string PatientSafetyMeasuresQuestionnaiareTemplateName = "Patient Safety Measures";
        public static readonly string AnesthesiaHistoryQuestionnaiareTemplateName = "Previous Surgeries";

        public static byte[] GetBytes(string content)
        {

            using (var ms = new MemoryStream())
            {
                using (TextWriter tw = new StreamWriter(ms))
                {
                    tw.Write(content);
                    tw.Flush();
                    byte[] bytes = ms.ToArray();
                    return bytes;
                }
            }

        }

        public static T JSONDeserialize<T>(string json)
        {
            return JsonConvert.DeserializeObject<T>(json);
        }

        public static string ToXml(Object target)
        {
            //this avoids xml document declaration
            XmlWriterSettings settings = new XmlWriterSettings()
            {
                Indent = false,
                OmitXmlDeclaration = true
            };

            //this avoids xml namespace declaration
            XmlSerializerNamespaces ns = new XmlSerializerNamespaces(
                               new[] { XmlQualifiedName.Empty });

            var serializer = new XmlSerializer(target.GetType());
            using (var stream = new StringWriter())
            using (var writer = XmlWriter.Create(stream, settings))
            {
                serializer.Serialize(writer, target, ns);
                return stream.ToString();
            }
        }

        public static T XmlToObject<T>(string xml)
        {
            XmlSerializer x = new XmlSerializer(typeof(T), "");
            return (T)x.Deserialize(new StringReader(xml));
        }

        public static string ToChartTemplateJSON(DataSet ds,List<ConsentQuestionnaireTemplateMappingTypeRequest> consentTypes)
        {
            var chartTemplate = ChartDesignerHelper.ToChartTemplate(ds.Tables["ChartTemplate"]);
            if (chartTemplate != null)
            {
                chartTemplate = getDesignerFriendlyTemplate(chartTemplate,consentTypes);
                return JsonConvert.SerializeObject(chartTemplate);
            }
            return "";
        }

        public static AnesthesiaGraphModuleConfig ToAnesthesiaGraphModuleConfig(DataSet ds)
        {
            return ChartDesignerHelper.ToAnesthesiaGraphModuleConfig(0,ds.Tables["AnesthesiaGraphGasConfig"], ds.Tables["AnesthesiaGraphMedicationConfig"]);
        }

        public static ChartTemplate ToChartTemplate(DataSet ds)
        {
            return ChartDesignerHelper.ToChartTemplate(ds.Tables["ChartTemplate"]);
        }

        public static string ToChartTemplatesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToChartTemplates(ds.Tables["ChartTemplates"]));
        }

        public static string ToChartTemplateTypesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToChartTemplateTypes(ds.Tables["ChartTemplates"]));
        }

        public static string ToConsentTypesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToConsentTypes(ds.Tables["ConsentTypes"]));
        }

        public static string ToModuleTemplateTypesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToModuleTemplateSelectTypes(ds.Tables["ModuleTemplates"]));
        }

        public static string ToModuleTemplateTypeJSON(DataSet ds)
        {
           var lst=ChartDesignerHelper.ToModuleTemplateSelectTypes(ds.Tables["ModuleTemplates"]);
           if(lst !=null && lst.Count>0)
            return JsonConvert.SerializeObject(lst[0]);
           return "";
        }

        public static string ToAnesthesiaMedicationsJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToAnesthesiaMedications(ds.Tables["AnesthesiaMedications"]));
        }

        public static string ToAreaTypesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToAreaSelectTypes(ds.Tables["Areas"]));
        }

        public static string ToQuestionCategoryTypesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToQuestionCategoryTypes(ds.Tables["QuestionCategories"]));
        }


        public static string ToConsentQuestionnaireTemplatesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToConsentQuestionnaireTemplates(ds.Tables["ConsentQuestionnaireTemplates"]));
        }

        public static string ToConsentQuestionnaireTemplateTypesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToConsentQuestionnaireTemplateMappingTypes(ds.Tables["ConsentQuestionnaireTemplateMappingTypes"]));
        }

        public static string ToQuestionnaireTemplateJSON(DataSet ds, bool bInUse)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToQuestionnaireTemplate(ds.Tables["QuestionnaireTemplate"], ds.Tables["QuestionTemplates"], ds.Tables["SubQuestions"], bInUse));
        }

        public static string ToQuestionTemplateJSON()
        {
            return JsonConvert.SerializeObject(new QuestionTemplateRequest { QuestionText = "", QuestionTypeId = 0, SubQuestions = new List<QuestionTemplateRequest>() , Categories= new List<QuestionCategoryType>()});
        }

        public static string ToQuestionnaireTemplateJSON()
        {
            return JsonConvert.SerializeObject(new QuestionnaireTemplateRequest { QuestionnaireName = "", InUse = false, Status = 'A',Category=1, QuestionTemplates = new List<QuestionTemplateRequest>() });
        }

        public static string ToChartTemplateJSON()
        {
            return JsonConvert.SerializeObject(new ChartTemplate { Name = "", BundleTemplates = new List<BundleTemplate>(), WorkflowTemplates = new List<WorkflowTemplate>(), ChartBundleWorkflowTemplates = new List<Object>() });
        }

        public static string ToQuestionTypesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToQuestionTypes(ds.Tables["QuestionTypes"]));
        }
        public static string ToQuestionTemplateJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToQuestionTemplate(ds.Tables["QuestionTemplate"], ds.Tables["SubQuestions"], ds.Tables["Categories"]));
        }

        public static string ToQuestionRhetoricalTypesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToQuestionRhetoricalTypes(ds.Tables["QuestionRhetoricalTypes"]));
        }

        public static string ToQuestionnaireTemplatesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToQuestionnaireTemplates(ds.Tables["QuestionnaireTemplates"]));
        }

        public static string ToQuestionTemplatesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToQuestionTemplates(ds.Tables["QuestionTemplates"], ds.Tables["SubQuestions"]));
        }

        public static string ToQuestionnaireTemplateTypesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToQuestionnaireTemplateTypes(ds.Tables["QuestionnaireTemplates"]));
        }

        public static string ToConsentQuestionnaireTemplateJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToConsentQuestionnaireTemplate(ds.Tables["ConsentQuestionnaireTemplate"]));
        }

        public static string ToPrintSetJSON()
        {
            return JsonConvert.SerializeObject(new PrintSetRequest { PrintSetName = "",  Status = 'A', Blocs = new List<PrintSetBlocRequest>() });
        }

        public static string ToPrintSetJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToPrintSet(ds.Tables["PrintSet"], ds.Tables["PrintSetBlocs"], ds.Tables["PrintSetAreas"], ds.Tables["PrintSetWorkflowInUse"]));
        }

        public static string ToPrintSetsJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToPrintSets(ds.Tables["PrintSets"]));
        }

        public static IEnumerable<PrintSetTypeRequest> ToPrintSets(DataTable dtPrintSet)
        {
            var qts = dtPrintSet.Rows.Cast<DataRow>().Select(qt => new PrintSetTypeRequest
            {
                PrintSetKey = qt["PrintSetKey"].SafeDbNull<int>(),
                PrintSetName = qt["PrintSetName"].SafeDbNull(string.Empty),
                AreaName = qt["AreaName"].SafeDbNull(string.Empty)
            }).ToList();
            return qts;
        }

        public static string ToPrintSetBlocsJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToPrintSetBlocs(ds.Tables["PrintSetBlocs"]));
        }

        public static IEnumerable<PrintSetBlocRequest> ToPrintSetBlocs(DataTable dtPrintSetBlocs)
        {
            var printsetBlocs = dtPrintSetBlocs.Rows.Cast<DataRow>().Select(qt => new PrintSetBlocRequest
            {
                CenterID = qt["CenterID"].SafeDbNull<int>(),
                ModuleDesignID = qt["ModuleDesignID"].SafeDbNull(string.Empty),
                ModuleName = qt["ModuleName"].SafeDbNull(string.Empty),
                QuestionnaireDesignID = qt["QuestionnaireDesignID"].SafeDbNull(string.Empty),             
                ConsentID = qt["ConsentID"].SafeDbNull<int>(),               
                Areas = qt["Areas"].SafeDbNull(string.Empty)
            }).ToList();

            return printsetBlocs;
        }

        public static PrintSetRequest ToPrintSet(DataTable dtPrintSet, DataTable dtPrintSetBlocs, DataTable dtPrintSetAreas,DataTable dtPrintSetWorkflowInUse)
        {
            var printSet = dtPrintSet.Rows.Cast<DataRow>().Select(ps =>
                new PrintSetRequest
                {
                    PrintSetKey = ps["PrintSetKey"].SafeDbNull<int>(),
                    PrintSetName = ps["PrintSetName"].SafeDbNull(string.Empty),
                    CenterId = ps["CenterId"].SafeDbNull<int>(),
                    Status = ps["Status"].SafeDbNull('A'),
                }).Single();

            var printSetBlocs = dtPrintSetBlocs.Rows.Cast<DataRow>().Select(psb => new PrintSetBlocRequest
            {
                ModuleDesignID = psb["ModuleDesignID"].SafeDbNull(string.Empty),
                ModuleName = psb["ModuleName"].SafeDbNull(string.Empty),
                QuestionnaireDesignID = psb["QuestionnaireDesignID"].SafeDbNull(string.Empty),
                QuestionnaireName = psb["QuestionnaireName"].SafeDbNull(string.Empty),
                ConsentID = psb["ConsentID"].SafeDbNull<int>(),
                Ordinal = psb["Ordinal"].SafeDbNull<int>(),
                Areas = psb["Areas"].SafeDbNull(string.Empty)

            }).ToList();

            var printSetAreas = dtPrintSetAreas.Rows.Cast<DataRow>().Select(psa => new AreaSelectRequest { 
                AreaKey = psa["AreaKey"].SafeDbNull<int>(),
                AreaName = psa["AreaName"].SafeDbNull(string.Empty)
            }).ToList();

            printSet.InUse = dtPrintSetWorkflowInUse.Rows.Count > 0;
            printSet.Blocs = printSetBlocs;
            printSet.Areas = printSetAreas;
            return printSet;
        }

        public static ConsentQuestionnaireTemplate ToConsentQuestionnaireTemplate(DataTable dtConsentQuestionnaireTemplate)
        {
            var cqt = dtConsentQuestionnaireTemplate.Rows[0];
            return new ConsentQuestionnaireTemplate
            {              
                MappingName = cqt["MappingName"].SafeDbNull<string>(string.Empty),
                QuestionnaireTemplateKey = cqt["QuestionnaireTemplateKey"].SafeDbNull<int>(),
               ConsentTypeId = cqt["ConsentID"].SafeDbNull<int>(),
            };
        }

        public static List<object> ToChartTemplates(DataTable dtChartTemplates)
        {
            return dtChartTemplates.Rows.Cast<DataRow>().Select(ct => new ChartTemplateRequest{ Name = ct["ChartTemplateName"].SafeDbNull<string>(string.Empty),
                PublishBy=ct["PublishBy"].SafeDbNull<string>(string.Empty),
                PublishDate =  ct["PublishDate"]!=DBNull.Value? Convert.ToDateTime(ct["PublishDate"]):(DateTime?)null
            }).ToList<object>();
        }

        public static List<QuestionCategoryType> ToQuestionCategoryTypes(DataTable dtQuestionCategoryTypes)
        {
            return dtQuestionCategoryTypes.Rows.Cast<DataRow>().Select(ct => new QuestionCategoryType
            {
                QuestionCategoryKey = ct["QuestionCategoryKey"].SafeDbNull<int>(),
                QuestionCategoryName = ct["QuestionCategoryName"].SafeDbNull(string.Empty)
            }).ToList();
        }

        public static List<ConsentQuestionnaireTemplate> ToConsentQuestionnaireTemplates(DataTable dtConsentQuestionnaireTemplate)
        {
            var cqts = dtConsentQuestionnaireTemplate.Rows.Cast<DataRow>().Select(cqt => new ConsentQuestionnaireTemplate
            {
                ConsentQuestionnaireTemplateId = cqt["ConsentQuestionnaireTemplateID"].SafeDbNull<int>(),
                MappingName = cqt["MappingName"].SafeDbNull<string>(string.Empty),
                QuestionnaireTemplateName = cqt["QuestionnaireTemplateName"].SafeDbNull(string.Empty),
                ConsentTypeName = cqt["ConsentTypeName"].SafeDbNull(string.Empty),
                QuestionnaireTemplateKey = cqt["QuestionnaireTemplateKey"].SafeDbNull<int>(),
                ConsentTypeId = cqt["ConsentId"].SafeDbNull<int>()

            }).ToList();
            return cqts;
        }

        public static List<ChartTemplateTypeRequest> ToChartTemplateTypes(DataTable dtChartTemplateTypes)
        {
            var cts = dtChartTemplateTypes.Rows.Cast<DataRow>().Select(ct => Tuple.Create<string, string>(
                ct["ChartTemplateName"].SafeDbNull<string>(string.Empty),
                ct["ChartTemplateXML"].SafeDbNull<string>(string.Empty)
            ));
            return cts.Select(ct =>
            {
                ChartTemplate template = XmlToObject<ChartTemplate>(ct.Item2);
                template = getDesignerFriendlyTemplate(template);
                return new ChartTemplateTypeRequest { ChartTemplateName = ct.Item1, ChartTemplateData = template };
            }).ToList();
        }

        private static ChartTemplate getDesignerFriendlyTemplate(ChartTemplate template, List<ConsentQuestionnaireTemplateMappingTypeRequest> consents=null)
        {
            var lstChartBundleWorkflowTemplates = new List<object>();

            var bundleWorkflowsLen = template.BundleTemplates.Count + template.WorkflowTemplates.Count;

            for (int order = 1; order <= bundleWorkflowsLen; order++)
            {
                var bundle = template.BundleTemplates.Find(bundleTemplate => bundleTemplate.BundleOrder == order);
                var workflow = template.WorkflowTemplates.Find(workflowTemplate => workflowTemplate.WorkflowOrder == order);
                if (bundle != null)
                {
                    lstChartBundleWorkflowTemplates.Add(bundle);
                    for(int i=0;i<bundle.WorkflowTemplates.Count;i++)
                    {
                        var w = bundle.WorkflowTemplates[i];
                        for(int j=0;j<w.ModuleTemplates.Count;j++)
                        {
                            var m = w.ModuleTemplates[j];
                            if(m.ConsentName!=null && m.ConsentName!="")
                            {
                                if (consents != null)
                                {
                                    var consent = consents.Find(c => c.MappingName == m.ConsentName);
                                    if (consent != null)
                                        m.QuestionnaireTemplateName = consent.QuestionnaireTemplateName;
                                }                      
                            }
                        }
                    }
                }
                else if (workflow != null)
                {
                    lstChartBundleWorkflowTemplates.Add(workflow);
                    for (int j = 0; j < workflow.ModuleTemplates.Count; j++)
                        {
                            var m = workflow.ModuleTemplates[j];
                            if(m.ConsentName!=null && m.ConsentName!="")
                            {
                                if (consents != null)
                                {
                                    var consent = consents.Find(c => c.MappingName == m.ConsentName);
                                    if (consent != null)
                                        m.QuestionnaireTemplateName = consent.QuestionnaireTemplateName;
                                }
                            }
                        }
                  }
            }
            template.ChartBundleWorkflowTemplates = lstChartBundleWorkflowTemplates;

            return template;
        }

        public static IEnumerable<QuestionnaireTypeRequest> ToQuestionnaireTemplateTypes(DataTable dtQuestionnaireTemplate)
        {
            var qts = dtQuestionnaireTemplate.Rows.Cast<DataRow>().Select(qt => new QuestionnaireTypeRequest
            {
                QuestionnaireTemplateKey = qt["QuestionnaireTemplateKey"].SafeDbNull<int>(),
                QuestionnaireTemplateName = qt["QuestionnaireName"].SafeDbNull(string.Empty)
            }).ToList();
            return qts;
        }

        public static IEnumerable<AnesthesiaMedicationRequest> ToAnesthesiaMedications(DataTable dtAnesthesiaMedication)
        {
            var ams = dtAnesthesiaMedication.Rows.Cast<DataRow>().Select(am => new AnesthesiaMedicationRequest
            {
                AnesthesiaMedicationKey = am["AnesthesiaMedicationKey"].SafeDbNull<int>(),
                MedicationID = am["MedicationID"].SafeDbNull<int>(),
                MedicationIDType = am["MedicationIDType"].SafeDbNull(string.Empty),
                MedicationName = am["MedicationName"].SafeDbNull(string.Empty),
                ItemCode = am["ItemCode"].SafeDbNull<int>()
            }).ToList();
            return ams;
        }

        public static IEnumerable<AnesthesiaGasRequest> ToAnesthesiaGases(DataTable dtAnesthesiaGas)
        {
            var ags = dtAnesthesiaGas.Rows.Cast<DataRow>().Select(ag => new AnesthesiaGasRequest
            {
                AnesthesiaGasKey = ag["AnesthesiaGasKey"].SafeDbNull<int>(),
                GasName = ag["GasName"].SafeDbNull<string>(),
               
            }).ToList();
            return ags;
        }
        

        public static IEnumerable<QuestionnaireTemplateRequest> ToQuestionnaireTemplates(DataTable dtQuestionnaireTemplate)
        {
            var qts = dtQuestionnaireTemplate.Rows.Cast<DataRow>().Select(qt => new QuestionnaireTemplateRequest
            {
                QuestionnaireDesignID = qt["QuestionnaireDesignID"].SafeDbNull(string.Empty),
                QuestionnaireTemplateKey = qt["QuestionnaireTemplateKey"].SafeDbNull<int>(),
                QuestionnaireName = qt["QuestionnaireName"].SafeDbNull(string.Empty),
                QuestionnaireVersionNumber = int.Parse(qt["QuestionnaireVersionNumber"].ToString()),
                Protected = qt["Protected"].SafeDbNull<bool>()
            }).ToList();
            return qts;
        }

        public static IEnumerable<QuestionTemplateRequest> ToQuestionTemplates(DataTable dtQuestionTemplates, DataTable dtSubQuestions)
        {
            var questionTemplates = dtQuestionTemplates.Rows.Cast<DataRow>().Select(qt => new QuestionTemplateRequest
            {
                QuestionTemplateKey = qt["QuestionTemplateKey"].SafeDbNull<int>(),
                QuestionID = qt["QuestionID"].SafeDbNull(string.Empty),
                ShortName = qt["ShortName"].SafeDbNull(string.Empty),
                QuestionTypeId = qt["QuestionTypeID"].SafeDbNull<int>(),
                QuestionText = qt["QuestionText"].SafeDbNull(string.Empty),
                Protected = qt["Protected"].SafeDbNull<bool>(),
                Required = qt["Required"].SafeDbNull<bool>(),
                QuestionTypeName = qt["QuestionTypeName"].SafeDbNull(string.Empty)
            }).ToList();


            questionTemplates.ForEach(q =>
            {
                var subQuestions = dtSubQuestions.Rows.Cast<DataRow>().
                    Select(subQ => new QuestionTemplateRequest
                    {
                        QuestionTemplateKey = subQ["QuestionTemplateKey"].SafeDbNull<int>(),
                        ParentQuestionTemplateKey = subQ["ParentQuestionTemplateKey"].SafeDbNull<int>(),
                        QuestionText = subQ["QuestionText"].SafeDbNull(string.Empty)
                    }).Where(sub => sub.ParentQuestionTemplateKey == q.QuestionTemplateKey);
                q.SubQuestions = subQuestions.ToList();               

            });
            
            return questionTemplates;
        }

        public static string ToPublishedChartMasterTemplateTypesJSON(DataSet ds)
        {
            var dtChartTemplateType = ds.Tables["ChartMasterTemplates"];
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToPublishedChartMasterTemplateTypes(dtChartTemplateType));
        }

        public static List<ChartTemplateType> ToPublishedChartMasterTemplateTypes(DataTable dt)
        {           
            var chartTemplateTypes = dt.Rows.Cast<DataRow>().Select(ct => new ChartTemplateType
            {
                ChartTemplateKey = ct["ChartMasterKey"].SafeDbNull<int>(),
                ChartTemplateName = ct["ChartTemplateName"].SafeDbNull(string.Empty)
            });
            return chartTemplateTypes.ToList();
        }

        public static List<ChartTemplateType> ToPublishedChartTemplateType(DataTable dtChartTemplateType)
        {
            var chartTemplateTypes = dtChartTemplateType.Rows.Cast<DataRow>().Select(ct => new ChartTemplateType
            {
                ChartTemplateKey = ct["ChartTemplateKey"].SafeDbNull<int>(),
                ChartTemplateName = ct["ChartTemplateName"].SafeDbNull(string.Empty)
            });
            return chartTemplateTypes.ToList();
        }


        public static List<AnesthesiaGraphGasTypeConfig> ToAnesthesiaGasType(DataTable dtGasType)
        {
            var gasTypes = dtGasType.Rows.Cast<DataRow>().Select(gt => new AnesthesiaGraphGasTypeConfig
            {
                GasKey = gt["AnesthesiaGasKey"].SafeDbNull<int>(),
                GasName = gt["GasName"].SafeDbNull(string.Empty)
            });
            return gasTypes.ToList();
        }

        public static List<RouteType> ToRouteType(DataTable dtRouteType)
        {
            var routeTypes = dtRouteType.Rows.Cast<DataRow>().Select(rt => new RouteType
            {
                RouteKey = rt["RouteKey"].SafeDbNull<int>(),
                Route= rt["Route"].SafeDbNull(string.Empty)
            });
            return routeTypes.ToList();
        }

        public static List<UnitOfMeasureType> ToUnitOfMeasureType(DataTable dtUnitOfMeasureType)
        {
            var uomTypes = dtUnitOfMeasureType.Rows.Cast<DataRow>().Select(um => new UnitOfMeasureType
            {
                UnitOfMeasure = um["UnitOfMeasure"].SafeDbNull(string.Empty),
                UnitOfMeasureDescription = um["UnitOfMeasureDescription"].SafeDbNull(string.Empty)
            });
            return uomTypes.ToList();
        }
            
        
        public static List<AnesthesiaGraphMedicationTypeConfig> ToAnesthesiaMedicationType(DataTable dtMedicationType)
        {
            var medicationTypes = dtMedicationType.Rows.Cast<DataRow>().Select(mt => new AnesthesiaGraphMedicationTypeConfig
            {
                MedicationId = mt["MedicationID"].SafeDbNull<int>(),
                MedicationIdType = mt["MedicationIdType"].SafeDbNull(string.Empty),
                MedicationName = mt["MedicationName"].SafeDbNull(string.Empty),
                FormName = mt["FormName"].SafeDbNull(string.Empty),
                ItemCode=mt["ItemCode"].SafeDbNull<int>(),
                RouteKey=mt["RouteKey"].SafeDbNull<int>(),
                Route= mt["Route"].SafeDbNull(string.Empty),
                UnitOfMeasure = mt["UnitOfMeasure"].SafeDbNull(string.Empty),
                UnitOfMeasureDescription = mt["UnitOfMeasureDescription"].SafeDbNull(string.Empty)
            });
            return medicationTypes.ToList();
        }
        

        public static string ToRouteTypesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToRouteType(ds.Tables["Routes"]));
        }

        public static string ToUnitOfMeasureTypesJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToUnitOfMeasureType(ds.Tables["UnitsOfMeasure"]));
        }   

        public static string ToAnesthesiaMedicationTypeJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToAnesthesiaMedicationType(ds.Tables["AnesthesiaMedications"]));
        }

        public static string ToAnesthesiaGasTypeJSON(DataSet ds)
        {
            return JsonConvert.SerializeObject(ChartDesignerHelper.ToAnesthesiaGasType(ds.Tables["AnesthesiaGases"]));
        }

        public static List<int> ToQuestionnaireTemplateKeys(DataSet ds)
        {
            var questionnaireTemplateKeys = new List<int>();
            var questionnaireTemplates = ds.Tables["QuestionnaireTemplates"].Rows.Cast<DataRow>();

            foreach (var qt in questionnaireTemplates)
            {
                int questionniareTemplateKey = qt["QuestionnaireTemplateKey"].SafeDbNull<int>();
                questionnaireTemplateKeys.Add(questionniareTemplateKey);
            }
            return questionnaireTemplateKeys;
        }

        public static AnesthesiaGraphModuleConfig ToAnesthesiaGraphModuleConfig(int chartTemplateKey,DataTable dtAnesthesiaGraphGasConfig, DataTable dtAnesthesiaGraphMedicationConfig)
        {
            var lstGasConfig = dtAnesthesiaGraphGasConfig.Rows.Cast<DataRow>().Select(gc => new AnesthesiaGraphGasTypeConfig
            {
                GasKey = gc["AnesthesiaGasKey"].SafeDbNull<int>(),
                GasName = gc["GasName"].SafeDbNull(string.Empty)
            }).ToList();
            var lstMedConfig = dtAnesthesiaGraphMedicationConfig.Rows.Cast<DataRow>().Select(mc => new AnesthesiaGraphMedicationTypeConfig
            {
                MedicationName = mc["MedicationName"].SafeDbNull(string.Empty),
                MedicationId = mc["MedicationID"].SafeDbNull<int>(),
                MedicationIdType = mc["MedicationIDType"].SafeDbNull(string.Empty),               
                RouteKey = mc["RouteKey"].SafeDbNull<int>(),
                Route = mc["Route"].SafeDbNull(string.Empty) ,
                UnitOfMeasure = mc["UnitOfMeasure"].SafeDbNull(string.Empty),
                UnitOfMeasureDescription = mc["UnitOfMeasureDescription"].SafeDbNull(string.Empty),
                Dose = mc["Dose"].SafeDbNull<decimal>(1),
                DoseIncrement=mc["DoseIncrement"].SafeDbNull<decimal>(1),
                ItemCode = mc["ItemCode"].SafeDbNull<int>()
                
            }).ToList();
            return new AnesthesiaGraphModuleConfig { ChartTemplateKey = chartTemplateKey,GasConfig = lstGasConfig, MedicationConfig = lstMedConfig };

        }

         public static QuestionTemplateRequest ToQuestionTemplate(DataSet ds)
        {
            return ToQuestionTemplate(ds.Tables["QuestionTemplate"], ds.Tables["SubQuestions"],ds.Tables["Categories"]);
        }

        public static QuestionTemplateRequest ToQuestionTemplate(DataTable dtQuestionTemplate, DataTable dtSubQuuestions,DataTable dtCategories)
        {
            var questionTemplate = dtQuestionTemplate.Rows.Cast<DataRow>().Select(qt => new QuestionTemplateRequest
            {
                QuestionTemplateKey = qt["QuestionTemplateKey"].SafeDbNull<int>(),
                QuestionText = qt["QuestionText"].SafeDbNull(string.Empty),
                QuestionID = qt["QuestionID"].SafeDbNull(string.Empty),
                ShortName = qt["ShortName"].SafeDbNull(string.Empty),
                QuestionTypeId = qt["QuestionTypeID"].SafeDbNull<int>(),
                QuestionTypeName = qt["QuestionTypeName"].SafeDbNull(string.Empty),
                Protected = qt["Protected"].SafeDbNull<bool>(),
                Required = qt["Required"].SafeDbNull<bool>(),
                RhetoricalId = qt["RhetoricalID"].SafeDbNull<int>(),
                RhetoricalName = qt["RhetoricalName"].SafeDbNull(string.Empty),
                InHouseLabResult = qt["InHouseLabResult"].SafeDbNull<bool>()
            }).Single();


            var subQuestions = dtSubQuuestions.Rows.Cast<DataRow>().Select(qt => new QuestionTemplateRequest
            {
                QuestionTemplateKey = qt["QuestionTemplateKey"].SafeDbNull<int>(),
                QuestionText = qt["QuestionText"].SafeDbNull(string.Empty),
                QuestionID = qt["QuestionID"].SafeDbNull(string.Empty),
                ShortName = qt["ShortName"].SafeDbNull(string.Empty),
                QuestionTypeId = qt["QuestionTypeID"].SafeDbNull<int>(),
                QuestionTypeName = qt["QuestionTypeName"].SafeDbNull(string.Empty),
                Required = qt["Required"].SafeDbNull<bool>(),
                Ordinal = qt["Ordinal"].SafeDbNull<int>()
            });

             var categories = dtCategories.Rows.Cast<DataRow>().
                    Select(c => new QuestionCategoryType
                    {
                        QuestionCategoryKey = c["QuestionCategoryKey"].SafeDbNull<int>(),
                        QuestionCategoryName = c["QuestionCategoryName"].SafeDbNull(string.Empty)
                    });

            questionTemplate.SubQuestions = subQuestions.ToList();
            questionTemplate.Categories=categories.ToList();
            return questionTemplate;
        }

        public static QuestionnaireTemplateRequest ToQuestionnaireTemplate(DataTable dtQuestionnaireTemplate, DataTable dtQuestionTemplates, DataTable dtSubQuestions, bool bUse)
        {
            var questionnaireTemplate = dtQuestionnaireTemplate.Rows.Cast<DataRow>().Select(qt =>
                new QuestionnaireTemplateRequest
                {
                    QuestionnaireTemplateKey = qt["QuestionnaireTemplateKey"].SafeDbNull<int>(),
                    QuestionnaireName = qt["QuestionnaireName"].SafeDbNull(string.Empty),
                    QuestionnaireDesignID = qt["QuestionnaireDesignID"].SafeDbNull(string.Empty),
                    Protected = qt["Protected"].SafeDbNull<bool>(),
                    Status = qt["Status"].SafeDbNull('A'),
                    Category = qt["Category"].SafeDbNull<byte>(1),
                }).Single();

            var questionTemplates = dtQuestionTemplates.Rows.Cast<DataRow>().Select(qt => new QuestionTemplateRequest
            {
                QuestionTemplateKey = qt["QuestionTemplateKey"].SafeDbNull<int>(),
                QuestionText = qt["QuestionText"].SafeDbNull(string.Empty),
                QuestionID = qt["QuestionID"].SafeDbNull(string.Empty),
                ShortName = qt["ShortName"].SafeDbNull(string.Empty),
                QuestionTypeId = qt["QuestionTypeID"].SafeDbNull<int>(),
                QuestionTypeName = qt["QuestionTypeName"].SafeDbNull(string.Empty),
                Protected = qt["Protected"].SafeDbNull<bool>(),
                RequiredInQuestionnaire = qt["RequiredInQuestionnaire"].SafeDbNull<bool>(),
                Ordinal = int.Parse(qt["Ordinal"].ToString()),
                CustomTemplate = qt["CustomTemplate"].SafeDbNull(string.Empty)
            }).ToList();

            questionTemplates.ForEach(q =>
            {
                var subQuestions = dtSubQuestions.Rows.Cast<DataRow>().
                    Select(subQ => new QuestionTemplateRequest
                    {
                        QuestionTemplateKey = subQ["QuestionTemplateKey"].SafeDbNull<int>(),
                        ParentQuestionTemplateKey = subQ["ParentQuestionTemplateKey"].SafeDbNull<int>(),
                        QuestionText = subQ["QuestionText"].SafeDbNull(string.Empty)
                    }).Where(sub => sub.ParentQuestionTemplateKey == q.QuestionTemplateKey);
                q.SubQuestions = subQuestions.ToList();

            });

            questionnaireTemplate.QuestionTemplates = questionTemplates;
            questionnaireTemplate.InUse = bUse;
            return questionnaireTemplate;

        }

        public static List<QuestionTypeRequest> ToQuestionTypes(DataTable dtQuestionTypes)
        {
            var questionTypes = dtQuestionTypes.Rows.Cast<DataRow>().Select(qt =>
                   new QuestionTypeRequest
                   {
                       QuestionTypeId = qt["QuestionTypeID"].SafeDbNull<int>(),
                       QuestionTypeName = qt["QuestionTypeName"].SafeDbNull(string.Empty)
                   });
            return questionTypes.ToList();
        }

        public static List<RhetoricalTypeRequest> ToQuestionRhetoricalTypes(DataTable dtRhetoricalTypes)
        {
            var rhetoricalTypes = dtRhetoricalTypes.Rows.Cast<DataRow>().Select(rt =>
                      new RhetoricalTypeRequest
                      {
                          RhetoricalId = rt["RhetoricalID"].SafeDbNull<int>(),
                          RhetoricalName = rt["RhetoricalName"].SafeDbNull(string.Empty)
                      });
            return rhetoricalTypes.ToList();
        }

        public static List<ModuleTemplateSelectRequest> ToModuleTemplateSelectTypes(DataTable dtModuleTemplates)
        {
            var moduleTemplateTypes = dtModuleTemplates.Rows.Cast<DataRow>().Select(mt =>
                   new ModuleTemplateSelectRequest
                   {
                       ModuleTemplateKey = mt["ModuleTemplateKey"].SafeDbNull<int>(),
                       ModuleTemplateName = mt["ModuleTemplateName"].SafeDbNull(string.Empty),
                       ModuleDesignID = mt["ModuleDesignID"].SafeDbNull(string.Empty),
                       Singleton = mt["Singleton"].SafeDbNull(false),
                       RequiresBundle = mt["RequiresBundle"].SafeDbNull(false),
                       Alias = mt["Alias"].SafeDbNull(string.Empty)
                   });
            return moduleTemplateTypes.ToList();

        }

        public static List<AreaSelectRequest> ToAreaSelectTypes(DataTable dtAreas)
        {
            var areas = dtAreas.Rows.Cast<DataRow>().Select(a =>
                   new AreaSelectRequest
                   {
                       AreaKey = a["AreaKey"].SafeDbNull<int>(),
                       AreaName = a["AreaName"].SafeDbNull(string.Empty)
                   });
            return areas.ToList();
        }

        public static List<ConsentQuestionnaireTemplateMappingTypeRequest> ToConsentQuestionnaireTemplateMappingTypes(DataTable dtConsentQuestionnaireTemplateMappingType)
        {
            var consentTypes = dtConsentQuestionnaireTemplateMappingType.Rows.Cast<DataRow>().Select(ct =>
                   new ConsentQuestionnaireTemplateMappingTypeRequest
                   {
                       MappingName = ct["MappingName"].SafeDbNull(string.Empty),
                       ConsentIdQuestionnaireTemplateKey = Tuple.Create<int, int>(ct["ConsentID"].SafeDbNull<int>(), ct["QuestionnaireTemplateKey"].SafeDbNull<int>()),
                       QuestionnaireTemplateName = ct["QuestionnaireName"].SafeDbNull(string.Empty)
                   });
            return consentTypes.ToList();
        }

        public static string ToCenterConfiguration(DataSet ds)
        {
            return  JsonConvert.SerializeObject(ToCenterConfiguration(ds.Tables["CenterConfiguration"], ds.Tables["ChartConfiguration"],ds.Tables["PatientLocations"]));

        }

        public static List<CenterConfigurationRequest> ToCenterConfiguration(DataTable dtCenterConfiguration,DataTable dtChartConfiguration, DataTable dtPatientLocations)
        {
               var config = dtCenterConfiguration.Rows.Cast<DataRow>().Select(ct =>
                  {                                           

                     var centerConfig=new CenterConfigurationRequest
                   {
                       CenterId = ct["CenterId"].SafeDbNull<int>(0),
                       DefaultAppointmentColor = ct.Field<string>("DefaultAppointmentColor"),
                       RightSideAppointmentColor = ct.Field<string>("RightSideAppointmentColor"),
                       LeftSideAppointmentColor = ct.Field<string>("LeftSideAppointmentColor"),
                       MergePreferenceCards = ct.Field<bool>("MergePreferenceCards"),
                       InactivityTimeOutMinutes = ct.Field<int>("InactivityTimeOutMinutes"),
                       RequireProcConsentOverride = ct.Field<bool>("RequireProcConsentOverride"),
                       RequireHPAttestOverride = ct.Field<bool>("RequireHPAttestOverride"),
                       AvatarDays = ct.Field<int>("AvatarDays"),
                       PriorQuestionDays = ct.Field<int>("PriorQuestionDays"),
                       AutoDeleteUnsignedOrders = ct.Field<bool>("AutoDeleteUnsignedOrders"),
                       AutoDeleteAnesthesiaUnsignedOrders=ct.Field<bool>("AutoDeleteAnesthesiaUnsignedOrders"),
                       ShowSupervisingAnesthesiaProvider = ct.Field<bool>("ShowSupervisingAnesthesiaProvider"),
                       NeedAnesStartTimeBackFillIntraOpRoomInTime = ct.Field<bool>("NeedAnesStartTimeBackFillIntraOpRoomInTime"),
                       RegistrationLocation = ct.Field<string>("RegistrationLocation"),
                       RegistrationCompleteLocation = ct.Field<string>("RegistrationCompleteLocation"),
                       CanRessignTaskToOthers = ct.Field<bool>("CanRessignTaskToOthers"),
                       DischargeLocation = ct.Field<string>("DischargeLocation"),
                       UpdateVisitClinicalWithRoomTimesAtNight = ct.Field<bool>("UpdateVisitClinicalWithRoomTimesAtNight"),
                       AutoProcessSuppliesUsed=ct.Field<bool>("AutoProcessSuppliesUsed")
                     };

                     var chartConfigRows = dtChartConfiguration.Rows.Cast<DataRow>().Where(cc => cc.Field<int>("CenterID") == centerConfig.CenterId);
                          if (chartConfigRows.Count()>0)
                          {
                              var chartConfig = chartConfigRows.Single();
                              centerConfig.DefaultPreferredLanguageCode = chartConfig.Field<string>("DefaultPreferredLanguageCode");
                              centerConfig.DefaultSystemOfMeasure = chartConfig.Field<string>("DefaultSystemOfMeasure");
                              centerConfig.TrackLateStart = chartConfig.Field<bool>("TrackLateStart");
                              centerConfig.DefaultLateStartThreshold = chartConfig.Field<int>("DefaultLateStartThreshold");
                              centerConfig.DefaultLabKey = chartConfig.Field<int?>("DefaultLabKey");
                              centerConfig.UseRoomTimesForAnesthesia = chartConfig.Field<bool>("UseRoomTimesForAnesthesia");
                              centerConfig.AutoRemoveUnableToContact = chartConfig.Field<bool>("AutoRemoveUnableToContact");
                              centerConfig.ArchiveAuditLogWaitDays = chartConfig.Field<int>("ArchiveAuditLogWaitDays");
                              centerConfig.DefaultTemperatureUnit = chartConfig.Field<byte>("DefaultTemperatureUnit");
                          }
                          
                          if(centerConfig.PatientLocations==null)
                              centerConfig.PatientLocations=new List<PatientLocation>();
                            var patientLocationRows = dtPatientLocations.Rows.Cast<DataRow>().Where(cc => cc.Field<int>("CenterID") == centerConfig.CenterId).ToList();
                          for(var index=0; index<patientLocationRows.Count();index++)
                          {
                              var loc = patientLocationRows[index];
                              centerConfig.PatientLocations.Add(new
                              PatientLocation
                              {
                                  Location = loc.Field<string>("Location"),
                                  Description = loc.Field<string>("Description"),
                                  CenterId = loc.Field<int>("CenterID")
                              });

                          }                           
                          
  
                     
                      return centerConfig; 
                  });
               return config.ToList();
         
        }

        public static List<ConsentTypeRequest> ToConsentTypes(DataTable dtConsentTypes)
        {
            var consentTypes = dtConsentTypes.Rows.Cast<DataRow>().Select(ct =>
                   new ConsentTypeRequest
                   {
                       ConsentTypeId = ct["ID"].SafeDbNull<int>(),
                       ConsentTypeName = ct["Name"].SafeDbNull(string.Empty),
                       ConsentTypeDescription=ct["Description"].SafeDbNull(string.Empty)
                   });
            return consentTypes.ToList();
        }

        public static ChartTemplate ToChartTemplate(DataTable dtChartTemplate)
        {
            ChartTemplate chartTemplate = null;

            if (dtChartTemplate.Rows.Count > 0)
            {
                var chartTemplateXML = dtChartTemplate.Rows[0]["ChartTemplateXML"].ToString();
                chartTemplate = XmlToObject<ChartTemplate>(chartTemplateXML);
            }
            return chartTemplate;
        }

        public static string ToChartTemplateXML(DataSet dsChartTemplate)
        {
            string chartTemplateXML = "";
            DataTable dtChartTemplate = dsChartTemplate.Tables["ChartTemplate"];

            if (dtChartTemplate.Rows.Count > 0)
            {
                chartTemplateXML = dtChartTemplate.Rows[0]["ChartTemplateXML"].ToString();
            }
            return chartTemplateXML;
        }

        public static string ToChartTemplateXML(ChartTemplate chartTemplate)
        {
            return ToXml(chartTemplate);
        }
        public static string ValidateChartTemplate(DataSet dsChartTemplate)
        {
            var chartTemplate = ToChartTemplate(dsChartTemplate.Tables["ChartTemplate"]);
            return ValidateChartTemplate(chartTemplate);
        }

        public static void InjectHardCodedQuestionnaireTemplates(ChartTemplate ct)
        {
            inject(ct.WorkflowTemplates);
            var lstBundleTemplates = ct.BundleTemplates;
            lstBundleTemplates.ForEach(b => { inject(b.WorkflowTemplates); });

        }

        private static void inject(List<WorkflowTemplate> lstWorkflowTemplates)
        {
                        
            lstWorkflowTemplates.ForEach(w =>
            {
                string questionnaireTemplate = string.Empty;
                switch (w.AreaKey)
                {
                    case 3:
                        questionnaireTemplate = PreOpQuestionnaiareTemplateName;
                        break;
                    case 4:
                        questionnaireTemplate = IntraOpQuestionnaiareTemplateName;
                        break;

                    case 5:
                        questionnaireTemplate = AnesthesiaQuestionnaiareTemplateName;
                        break;
                    case 6:
                        questionnaireTemplate = PACUQuestionnaiareTemplateName;
                        break;
                    case 7:
                        questionnaireTemplate = PostOpQuestionnaiareTemplateName;
                        break;
                }

                w.ModuleTemplates.ForEach(m =>
                {
                    if (m.Name == PatientEducationModuleName || m.ModuleDesignId=="082")
                    {
                        m.QuestionnaireTemplateName = questionnaireTemplate;
                    }
                    else if (m.Name == PatientSafetyMeasuresModuleName || m.ModuleDesignId == "101")
                    {
                        m.QuestionnaireTemplateName = PatientSafetyMeasuresQuestionnaiareTemplateName;
                    }
                    else if(m.Name == AnesthesiaHistoryModuleName || m.ModuleDesignId == "113")
                    {
                        m.QuestionnaireTemplateName = AnesthesiaHistoryQuestionnaiareTemplateName;
                    }
                });
               

            });
        }

        public static string ValidateChartTemplate(ChartTemplate chartTemplate)
        {
            var lstWorkflowTemplates = chartTemplate.WorkflowTemplates;
            var lstBundleTemplates = chartTemplate.BundleTemplates;
            var bExistsHeightWeightBMI = false;
            var bExistsASAClassification = false;
            var bExistsAnaesthesia = false;
            var bExistsAllergy = false;

            if (lstWorkflowTemplates.Exists(workflowTemplate =>
                lstWorkflowTemplates.Exists(x => x.Name == workflowTemplate.Name && x.WorkflowOrder != workflowTemplate.WorkflowOrder)))
                return "Chart Template has 2 or more Workflow Templates with same name";

            if (lstWorkflowTemplates.Find(w => w.AreaKey == 5) != null) //Anaeasthesia Workflow AreaKey is 5
                bExistsAnaesthesia = true;

            for (var i = 0; i < lstWorkflowTemplates.Count; i++)
            {
                var workflowTemplate = lstWorkflowTemplates[i];
                if (workflowTemplate.ModuleTemplates.Count == 0)
                {
                    return "Every Workflow Template in the Chart Template should have at least one BLOC";
                }
                else
                {
                    var moduleTemplates = workflowTemplate.ModuleTemplates;

                    if (moduleTemplates.Find(m => m.Name == "Height/Weight/BMI" || m.ModuleDesignId=="009") != null)
                    {
                        bExistsHeightWeightBMI = true;
                    }
                    if (moduleTemplates.Find(m => m.Name == "ASA Classification" || m.ModuleDesignId == "089" ||m.Name == "Pre-op Anesthesia Physical Assessment" || m.ModuleDesignId == "068" || m.Name == "Vitals Anesthesia - The Graph" || m.ModuleDesignId == "014") != null)
                    {
                        bExistsASAClassification = true;
                    }
                    if(moduleTemplates.Find(m => m.Name == "Allergy" || m.ModuleDesignId == "003") != null)
                    {
                        bExistsAllergy = true;
                    }


                    var modulesWithoutBundle = moduleTemplates.Where(moduleTemplate =>moduleTemplate.RequiresBundle==true).Select(m => m.Name).ToList();
                    
                    var moduleWithoutBundleNames = string.Empty;

                    if (modulesWithoutBundle != null && modulesWithoutBundle.Count > 0)
                    {
                        modulesWithoutBundle.ForEach(m => { moduleWithoutBundleNames = "  " + moduleWithoutBundleNames + m + ","; });
                        return "BLOC " + moduleWithoutBundleNames.TrimEnd(new char[] { ',' }) + " present in the Workflow Template " + workflowTemplate.Name + " requires to be in a Bundle Template";
                    }
                     
                    var multipleSingletons= moduleTemplates.Where(moduleTemplate => moduleTemplate.Singleton == true &&
                               moduleTemplates.Exists(x => x.Name == moduleTemplate.Name && x.ModuleOrder != moduleTemplate.ModuleOrder)).Select(m=>m).ToList();
                    if (multipleSingletons.Count>0)
                    {
                        var multiples="";
                        multipleSingletons.ForEach(x => { multiples += (x.Name + ","); });
                        return "Workflow Template " + workflowTemplate.Name + " has singleton BLOC(s) " +  multiples.TrimEnd(new char[]{','}) + " appearing more than once in the Workflow";

                    }
                }

            }

            for (var i = 0; i < lstBundleTemplates.Count; i++)
            {
                var bundleTemplate = lstBundleTemplates[i];
                var lstBundleWorkflowTemplates = bundleTemplate.WorkflowTemplates;

                if (lstBundleWorkflowTemplates.Find(w => w.AreaKey == 5) != null) //Anaeasthesia Workflow Area Key is 5
                    bExistsAnaesthesia = true;

                if (lstBundleWorkflowTemplates.Exists(workflowTemplate => lstBundleWorkflowTemplates.Exists(x => x.Name == workflowTemplate.Name && x.WorkflowOrder != workflowTemplate.WorkflowOrder)))
                    return string.Format("Bundle Template {0} has 2 or more Workflow Templates with same name", bundleTemplate.Name);

                if (lstBundleWorkflowTemplates.Count == 0)
                {
                    return "Every Bundle Template should have at least one Workflow Template";
                }
                else
                {
                    for (var j = 0; j < lstBundleWorkflowTemplates.Count; j++)
                    {
                        var bundleWorkflowTemplate = lstBundleWorkflowTemplates[j];
                        var moduleTemplates = bundleWorkflowTemplate.ModuleTemplates;
                        if (moduleTemplates.Find(m => m.Name == "Height/Weight/BMI" || m.ModuleDesignId == "009") != null)
                        {
                            bExistsHeightWeightBMI = true;
                        }
                        if (moduleTemplates.Find(m => m.Name == "ASA Classification" || m.ModuleDesignId == "089" || m.Name == "Pre-op Anesthesia Physical Assessment" || m.ModuleDesignId == "068" || m.Name == "Vitals Anesthesia - The Graph" || m.ModuleDesignId == "014") != null)
                        {
                            bExistsASAClassification = true;
                        }
                        if (moduleTemplates.Find(m => m.Name == "Allergy" || m.ModuleDesignId == "003") != null)
                        {
                            bExistsAllergy = true;
                        }

                        if (moduleTemplates.Count == 0)
                        {
                            return "Every Workflow Template in a Bundle Template should have at least one BLOC";
                        }
                        else
                        {
                            var lstDupes = moduleTemplates.Where(moduleTemplate => moduleTemplate.Singleton == true &&
                               moduleTemplates.Exists(x => x.Name == moduleTemplate.Name && x.ModuleOrder != moduleTemplate.ModuleOrder)).ToList();
                            if (lstDupes.Count > 0)
                            {
                                var dupWarning = String.Empty;
                                lstDupes.ForEach(m => { dupWarning += " " + m.Name + ","; });
                                return bundleWorkflowTemplate.Name + " has singleton BLOC " + dupWarning.TrimEnd(new char[] { ',' }) + "appearing more than once in the Workflow";

                            }
                        }
                    }
                }
            }
            if (bExistsAllergy == false)
                return "The Allergy BLOC must exist in the Chart";
            if (bExistsHeightWeightBMI == false)
                return "The Height/Weight/BMI BLOC must exist in the Chart";
            if (bExistsAnaesthesia && !bExistsASAClassification)
                return "The ASA Classification BLOC must exist for a Chart having a Anaesthesia Workflow";
            return null;
        }

        #region Discharge Instructions
        public static string ToSetUsageResponse(DataTable table)
        {
            return JsonConvert.SerializeObject(table.AsEnumerable().Select(r => new SetUsageResult(r.Field<string>("ServiceCode"), r.Field<string>("Physician"))).ToList());
        }

        private class SetUsageResult
        {
            public SetUsageResult(string serviceCode, string physician)
            {
                this.ServiceCode = serviceCode;

                this.Physician = physician;
            }

            [JsonProperty(PropertyName = "Service Code")]
            public string ServiceCode { get; set; }
            
            public string Physician { get; set; }
        }
        
        private class InstructionUsageResult
        {
            public InstructionUsageResult(string setName)
            {
                this.SetName = setName;
            }

            [JsonProperty(PropertyName = "SetName")]
            public string SetName { get; set; }
        }

        public static String ToInstructionUsageResponse(DataTable table)
        {
            return JsonConvert.SerializeObject(table.AsEnumerable().Select(r => new InstructionUsageResult(r.Field<string>("SetName"))).ToList());
        }
        #endregion
    }
}