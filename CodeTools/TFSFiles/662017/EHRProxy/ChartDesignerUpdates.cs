using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Serialization;

namespace EHRProxy.Updates
{
        [DataContract(Namespace = "eChartWCF")]
        public class ConsentQuestionnaireTemplate
        {
            [DataMember]
            public int ConsentQuestionnaireTemplateId { get; set; }

            [DataMember]
            public string MappingName { get; set; }

            [DataMember]
            public int ConsentTypeId { get; set; }

            [DataMember]
            public string ConsentTypeName { get; set; }

            [DataMember]
            public int QuestionnaireTemplateKey { get; set; }

            [DataMember]
            public string QuestionnaireTemplateName { get; set; }

        }

        [DataContract(Namespace = "eChartWCF")]
        public class UnitOfMeasureType
        {
            [DataMember]
            public string UnitOfMeasure { get; set; }

            [DataMember]
            public string UnitOfMeasureDescription { get; set; }

        }


        [DataContract(Namespace = "eChartWCF")]
        public class AnesthesiaGraphMedicationTypeConfig
        {
            [DataMember]
            public int MedicationId { get; set; }

            [DataMember]
            public string MedicationIdType { get; set; }

            [DataMember]
            public string MedicationName { get; set; }

            [DataMember]
            public string FormName { get; set; }

            [DataMember]
            public int MedicationOrder { get; set; }

            [DataMember]
            public int? RouteKey { get; set; }

            [DataMember]
            public string Route { get; set; }

            [DataMember]
            public string UnitOfMeasure { get; set; }

            [DataMember]
            public string UnitOfMeasureDescription { get; set; }

            [DataMember]
            public decimal DoseIncrement { get; set; }

            [DataMember]
            public decimal Dose { get; set; }

            [DataMember]
            public int? ItemCode { get; set; }

        }

        [DataContract(Namespace = "eChartWCF")]
        public class AnesthesiaGraphGasTypeConfig
        {
            [DataMember]
            public int GasKey { get; set; }

            [DataMember]
            public string GasName { get; set; }

            [DataMember]
            public int GasOrder { get; set; }

        }


        [DataContract(Namespace = "eChartWCF")]
        public class AnesthesiaGraphModuleConfig
        {
            //Obsolete: Publish will generate a new Chart Template Key every time, so config should be tied to the Chart Master Key
            [DataMember]
            public int ChartTemplateKey { get; set; }

            [DataMember]
            public int ChartMasterKey { get; set; }

            [DataMember]
            public List<AnesthesiaGraphMedicationTypeConfig> MedicationConfig { get; set; }

            [DataMember]
            public List<AnesthesiaGraphGasTypeConfig> GasConfig { get; set; }



        }

        [DataContract(Namespace = "eChartWCF")]
        public class ChartTemplateType
        {
            [DataMember]
            public int ChartTemplateKey { get; set; }

            [DataMember]
            public string ChartTemplateName { get; set; }

        }

        [DataContract(Namespace = "eChartWCF")]
        public class AreaSelectRequest
        {
            [DataMember]
            public int AreaKey { get; set; }

            [DataMember]
            public string AreaName { get; set; }
        }

        [DataContract(Namespace = "eChartWCF")]
        public class ConsentQuestionnaireTemplateMappingTypeRequest
        {
            [DataMember]
            public string MappingName { get; set; }

            [DataMember]
            public Tuple<int, int> ConsentIdQuestionnaireTemplateKey { get; set; }

            [DataMember]
            public string QuestionnaireTemplateName { get; set; }

        }

        [DataContract(Namespace = "eChartWCF")]
        public class ConsentTypeRequest
        {
            [DataMember]
            public int ConsentTypeId { get; set; }

            [DataMember]
            public string ConsentTypeName { get; set; }

            [DataMember]
            public string ConsentTypeDescription { get; set; }
        }

        [DataContract(Namespace = "eChartWCF")]
        public class QuestionnaireTypeRequest
        {
            [DataMember]
            public int QuestionnaireTemplateKey { get; set; }

            [DataMember]
            public string QuestionnaireTemplateName { get; set; }
        }

        [DataContract(Namespace = "eChartWCF")]
        public class PrintSetTypeRequest
        {
            [DataMember]
            public int PrintSetKey { get; set; }

            [DataMember]
            public string PrintSetName { get; set; }           

            [DataMember]
            public string AreaName { get; set; }
        }

        [DataContract(Namespace = "eChartWCF")]
        public class PrintSetRequest
        {
            [DataMember]
            public int PrintSetKey { get; set; }

            [DataMember]
            public string PrintSetName { get; set; }

            [DataMember]
            public int CenterId { get; set; }
            
            [DataMember]
            public List<PrintSetBlocRequest> Blocs { get; set; }

            [DataMember]
            public List<AreaSelectRequest> Areas { get;set; }

            [DataMember]
            public char Status { get; set; }

            [DataMember]
            public bool InUse { get; set; }  // true if some workfow is printing with this printset
        }

        [DataContract(Namespace = "eChartWCF")]
        public class PrintSetBlocRequest
        {
            [DataMember]
            public int CenterID{ get; set; }

            [DataMember]
            public string ModuleDesignID { get; set; }

            [DataMember]
            public string ModuleName { get; set; }

            [DataMember]
            public string QuestionnaireDesignID { get; set; }

            [DataMember]
            public string QuestionnaireName { get; set; }

            [DataMember]
            public int ConsentID { get; set; }

            [DataMember]
            public string SignatureType { get; set; }

            [DataMember]
            public string Areas { get; set; }

            [DataMember]
            public int? Ordinal { get; set; }
        }

        [DataContract(Namespace = "eChartWCF")]
        public class ChartTemplate
        {
            [DataMember]
            public string Name { get; set; }

            [DataMember]
            public string Description { get; set; }

            [DataMember]
            public string Version { get; set; }

            [DataMember]
            public int CenterId { get; set; }

            [DataMember]
            public List<WorkflowTemplate> WorkflowTemplates { get; set; }

            [DataMember]
            public List<BundleTemplate> BundleTemplates { get; set; }

            [DataMember]
            public List<Object> ChartBundleWorkflowTemplates { get; set; }
        }

        [DataContract(Namespace = "eChartWCF")]
        public class WorkflowTemplate
        {
            [DataMember]
            public string Name { get; set; }

            [DataMember]
            public string Description { get; set; }

            [DataMember]
            public int WorkflowOrder { get; set; }

            [DataMember]
            public int AreaKey { get; set; }

            [DataMember]
            public string DesignerId { get; set; }

            [DataMember]
            public List<ModuleTemplate> ModuleTemplates { get; set; }

        }

        [DataContract(Namespace = "eChartWCF")]
        public class ModuleTemplate
        {
            [DataMember]
            public string ModuleDesignId { get; set; }

            [DataMember]
            public int ModuleTemplateKey { get; set; }

            [DataMember]
            public int? AreaFilter { get; set; }

            [DataMember]
            public string Name { get; set; }

            [DataMember]
            public string Alias { get; set; }

            [DataMember]
            public bool Mandatory { get; set; }

            [DataMember]
            public bool Singleton { get; set; }

            [DataMember]
            public string QuestionnaireTemplateName { get; set; }

            [DataMember]
            public int QuestionnaireTemplateKey { get; set; }

            [DataMember]
            public string QuestionnaireDesignID { get; set; }

            [DataMember]
            public int ConsentID { get; set; }

            [DataMember]
            public string TitleOverride { get; set; }

            [DataMember]
            public int ModuleOrder { get; set; }

            [DataMember]
            public string ConsentName { get; set; }

            [DataMember]
            public bool RequiresBundle { get; set; }
        }

        [DataContract(Namespace = "eChartWCF")]
        public class RouteType
        {
            [DataMember]
            public int? RouteKey { get; set; }

            [DataMember]
            public string Route { get; set; }

        }

        [DataContract(Namespace = "eChartWCF")]
        public class QuestionCategoryType
        {
            [DataMember]
            public int QuestionCategoryKey { get; set; }

            [DataMember]
            public string QuestionCategoryName { get; set; }
        }

        [DataContract(Namespace = "eChartWCF")]
        public class SearchCriteria
        {
            [DataMember]
            public string SearchText { get; set; }

            [DataMember]
            public int CategoryKey { get; set; }

            [DataMember]
            public int AreaKey { get; set; }

        }

        [DataContract(Namespace = "eChartWCF")]
        public class QuestionTemplateRequest
        {
            [DataMember]
            public int QuestionTemplateKey { get; set; }

            [DataMember]
            public int? ParentQuestionTemplateKey { get; set; }

            [DataMember]
            public string QuestionID { get; set; }

            [DataMember]
            public string QuestionText { get; set; }

            [DataMember]
            public string ShortName { get; set; }

            [DataMember]
            public int QuestionTypeId { get; set; }

            [DataMember]
            public string QuestionTypeName { get; set; }

            [DataMember]
            public int? RhetoricalId { get; set; }

            [DataMember]
            public string RhetoricalName { get; set; }

            [DataMember]
            public List<QuestionTemplateRequest> SubQuestions { get; set; }

            [DataMember]
            public bool Protected { get; set; }

            [DataMember]
            public bool Required { get; set; }

            [DataMember]
            public bool RequiredInQuestionnaire { get; set; }

            [DataMember]
            public int? Ordinal { get; set; }

            [DataMember]
            public bool InHouseLabResult { get; set; }

            [DataMember]
             public string CustomTemplate { get; set; }

            [DataMember]
            public List<AreaSelectRequest> Areas { get; set; }

            [DataMember]
            public List<QuestionCategoryType> Categories { get; set; }
        }

    [DataContract(Namespace = "eChartWCF")]
    public class CenterConfigurationRequest
    {
        [DataMember]
        public string DefaultAppointmentColor { get; set; }

        [DataMember]
        public string RightSideAppointmentColor { get; set; }

        [DataMember]
        public string LeftSideAppointmentColor { get; set; }

        [DataMember]
        public bool MergePreferenceCards { get; set; }

        [DataMember]
        public int? InactivityTimeOutMinutes { get; set; }

        [DataMember]
        public bool RequireProcConsentOverride { get; set; }

        [DataMember]
        public bool RequireHPAttestOverride { get; set; }

        [DataMember]
        public int? AvatarDays { get; set; }

        [DataMember]
        public int? PriorQuestionDays { get; set; }

        [DataMember]
        public bool AutoDeleteUnsignedOrders { get; set; }

        [DataMember]
        public bool AutoDeleteAnesthesiaUnsignedOrders { get; set; }

        [DataMember]
        public bool ShowSupervisingAnesthesiaProvider { get; set; }

        [DataMember]
        public bool NeedAnesStartTimeBackFillIntraOpRoomInTime { get; set; }

        [DataMember]
        public string RegistrationLocation { get; set; }

        [DataMember]
        public string RegistrationCompleteLocation { get; set; }

        [DataMember]
        public string DischargeLocation { get; set; }

        [DataMember]
        public bool UpdateVisitClinicalWithRoomTimesAtNight { get; set; }

        [DataMember]
        public bool CanRessignTaskToOthers { get; set; }

        [DataMember]
        public string DefaultPreferredLanguageCode { get; set; }

        [DataMember]
        public string DefaultSystemOfMeasure { get; set; }

        [DataMember]
        public bool TrackLateStart { get; set; }

        [DataMember]
        public int? DefaultLateStartThreshold { get; set; }

        [DataMember]
        public int? DefaultLabKey { get; set; }

        [DataMember]
        public bool UseRoomTimesForAnesthesia { get; set; }

        [DataMember]
        public bool AutoRemoveUnableToContact { get; set; }

        [DataMember]
        public byte DefaultTemperatureUnit { get; set; }

        [DataMember]
        public DateTime ChangeDate { get; set; }

        [DataMember]
        public int? ArchiveAuditLogWaitDays { get; set; }

        [DataMember]
        public int CenterId { get; set; }

        [DataMember]
        public List<PatientLocation> PatientLocations { get; set; }

        [DataMember]
        public bool AutoProcessSuppliesUsed { get; set; }
    }

        [DataContract(Namespace = "eChartWCF")]
        public class PatientLocation
        {
           [DataMember]
            public string Location{get;set;}

           [DataMember]
           public string Description { get; set; }
          
            [DataMember]
           public int CenterId { get; set; }
     
       }

        [DataContract(Namespace = "eChartWCF")]
        public class AnesthesiaGasRequest
        {
            [DataMember]
            public int AnesthesiaGasKey { get; set; }

            [DataMember]
            public string GasName { get; set; }

            [DataMember]
            public string UserID { get; set; }

            [DataMember]
            public DateTime CreateDate { get; set; }
        }

        [DataContract(Namespace = "eChartWCF")]
        public class AnesthesiaMedicationRequest
        {
            [DataMember]
            public int AnesthesiaMedicationKey { get; set; }

            [DataMember]
            public int MedicationID { get; set; }

            [DataMember]
            public string MedicationIDType { get; set; }

            [DataMember]
            public string MedicationName { get; set; }

            [DataMember]
            public string UserID { get; set; }

            [DataMember]
            public DateTime CreateDate { get; set; }

            [DataMember]
            public int?  ItemCode { get; set; }

        }

        [DataContract(Namespace = "eChartWCF")]
        public class QuestionnaireTemplateRequest
        {
            [DataMember]
            public int QuestionnaireTemplateKey { get; set; }

            [DataMember]
            public int CenterId { get; set; }

            [DataMember]
            public string QuestionnaireName { get; set; }

            [DataMember]
            public string QuestionnaireDesignID { get; set; }

            [DataMember]
            public bool Protected { get; set; }

            [DataMember]
            public bool InUse { get; set; }

            [DataMember]
            public List<QuestionTemplateRequest> QuestionTemplates { get; set; }

            [DataMember]
            public int QuestionnaireVersionNumber { get; set; }

            [DataMember]
            public char Status { get; set; }

            [DataMember]
            public byte Category { get; set; }
        }

        [DataContract(Namespace = "eChartWCF")]
        public class ChartTemplateTypeRequest
        {
            [DataMember]
            public string ChartTemplateName { get; set; }

            [DataMember]
            public ChartTemplate ChartTemplateData { get; set; }

        }

        [DataContract(Namespace = "eChartWCF")]
        public class ChartTemplateRequest
        {
            [DataMember]
            public string Name { get; set; }

            [DataMember]
            public string PublishBy { get; set; }

            [DataMember]
            public DateTime? PublishDate { get; set; }

        }


        [DataContract(Namespace = "eChartWCF")]
        public class QuestionTypeRequest
        {
            [DataMember]
            public int QuestionTypeId { get; set; }

            [DataMember]
            public string QuestionTypeName { get; set; }

        }

        [DataContract(Namespace = "eChartWCF")]
        public class RhetoricalTypeRequest
        {
            [DataMember]
            public int RhetoricalId { get; set; }

            [DataMember]
            public string RhetoricalName { get; set; }
        }

        [DataContract(Namespace = "eChartWCF")]
        public class ModuleTemplateSelectRequest
        {
            [DataMember]
            public int ModuleTemplateKey { get; set; }

            [DataMember]
            public string ModuleTemplateName { get; set; }

            [DataMember]
            public string Alias { get; set; }
            
            [DataMember]
            public string ModuleDesignID { get; set; }

            [DataMember]
            public bool Singleton { get; set; }

            [DataMember]
            public bool RequiresBundle { get; set; }
        }

        [DataContract(Namespace = "eChartWCF")]
        public class BundleTemplate
        {
            [DataMember]
            public string Name { get; set; }

            [DataMember]
            public string Description { get; set; }

            [DataMember]
            public int BundleOrder { get; set; }

            [DataMember]
            public List<WorkflowTemplate> WorkflowTemplates { get; set; }

            [DataMember]
            public string DesignerId { get; set; }

    }

    [DataContract(Namespace = "eChartWCF")]
    public class DischargeInstructionUpdateRequest
    {
        [DataMember]
        public int DischargeInstructionKey { get; set; }

        [DataMember]
        public string Title { get; set; }

        [DataMember]
        public string Caption { get; set; }

        [DataMember]
        public string Instruction { get; set; }
    }

    [XmlRoot(ElementName = "instruction")]
    [DataContract(Namespace = "eChartWCF")]
    public class DischargeInstructionSetMember
    {
        [DataMember]
        [XmlElement(ElementName = "dischargeInstructionKey")]
        public int dischargeInstructionKey { get; set; }

        [DataMember]
        [XmlElement(ElementName = "ordinal")]
        public int ordinal { get; set; }
        }

    [DataContract(Namespace = "eChartWCF")]
    [XmlRoot(ElementName = "request")]
    public class UpdateDischargeInstructionSetRequest
    {
        public UpdateDischargeInstructionSetRequest()
        {
            this.instructions = new List<DischargeInstructionSetMember>();
    }

        [DataMember]
        [XmlElement(ElementName = "dischargeInstructionSetKey")]
        public int dischargeInstructionSetKey { get; set; }

        [DataMember]
        [XmlElement(ElementName = "setName")]
        public string setName { get; set; }

        [DataMember]
        [XmlElement(ElementName = "instructions")]
        public List<DischargeInstructionSetMember> instructions { get; set; }

        [DataMember]
        [XmlElement(ElementName = "actionDate")]
        public DateTime actionDate { get; set; }

        public string ToXML()
        {
            var settings = new XmlWriterSettings
            {
                Indent = true,
                OmitXmlDeclaration = true,
                Encoding = Encoding.GetEncoding("UTF-8")
            };

            var namespaces = new XmlSerializerNamespaces();

            namespaces.Add(string.Empty, string.Empty);

            var serializer = new XmlSerializer(this.GetType());

            using (var stringWriter = new StringWriter())
            {
                using (var xmlWriter = XmlWriter.Create(stringWriter, settings))
                {
                    serializer.Serialize(xmlWriter, this, namespaces);
                }
                return stringWriter.ToString();
            }
        }
    }
}
