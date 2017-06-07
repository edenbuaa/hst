using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Hst.Core.Entity
{
    public class Areakeys
    {
        public const int PatientSummary = 1;
        public const int PatientCommunications = 2;
        public const int PreOp = 3;
        public const int IntraOp = 4;
        public const int Anesthesia = 5;
        public const int PACU = 6;
        public const int PostOp = 7;
        public const int Physician = 8;
        public const int Hour23Stay = 9;
        public const int Discharge = 10;
        public const int Registration = 11;
        public const int PreOpCommunication = 12;
        public const int PostOpCommunication = 13;

        public static bool IsBundleArea(int areaKey)
        {
            return areaKey >= IntraOp && areaKey <= PostOp;
        }
    }
}
