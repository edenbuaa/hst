using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EHRProxy;

namespace Hst.Core.Helpers
{
    public class ChartHelper
    {
        public const string CenterID = "centerId";
        public const string ChartKey = "chartKey";
        public const string WorkflowKey = "workflowKey";
        public const string ModuleKey = "moduleKey";

        public const int AreaKeyBase = 60000;
        public const int ModuleKeyBase = 61000;

        public static GenericResponse ErrorResponse(string errorMessage)
        {
            return new GenericResponse
            {
                Code = 2,
                errorMessage = errorMessage
            };
        }
    }
}
