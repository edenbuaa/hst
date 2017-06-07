using System;
using System.Collections.Generic;


namespace EHRProxy
{
    public class HSTUser
    {
        public string UserID { get; set; }
        public int CenterID { get; set; }
        public Dictionary<string, bool> UserPersonas { get; set; }
        public Dictionary<string, bool> SystemFunctions { get; set; }
        public Dictionary<string, string> HSTInfo { get; set; }

        public HSTUser()        // needed for serialization
        {

        }
        public HSTUser (int centerID, string userID, Dictionary<string, bool> personas, 
                                                        Dictionary<string, bool> systemFuncs, 
                                                        Dictionary<string, string> hstInfo)
        {
            CenterID = centerID;
            UserID = userID;
            UserPersonas = personas;
            SystemFunctions = systemFuncs;
            HSTInfo = hstInfo;
        }

        public bool hasPersona (string persona)
        {
            bool value;
            UserPersonas.TryGetValue(persona, out value);

            return value;
        }

        public bool isPhysician => hasPersona("Physician");
        public bool isAnesthesiologist => hasPersona("Anesthesiologist");
        public bool isCRNA => hasPersona("CRNA");
        public bool isCenterAdministrator => hasPersona("CenterAdmin");

        public bool hasSystemFunction(string sysFuncName)
        {
            bool value;
            SystemFunctions.TryGetValue(sysFuncName, out value);

            return value;
        }


        public string getHSTInfo(string name)
        {
            string value;
            HSTInfo.TryGetValue(name, out value);       // returns default value (null) if not present

            return value;
        }

        public int getHSTInt(string name)
        {
            string intString = getHSTInfo(name);
            if (intString == null) return 0;

            int intValue = 0;
            if (!int.TryParse(intString, out intValue)) return 0;

            return intValue;
        }


    }

}
