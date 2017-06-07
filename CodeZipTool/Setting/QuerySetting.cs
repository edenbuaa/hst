using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeZipTool.Setting
{
    public class QuerySetting
    {
        #region setting params
        //const properies
        public const string tfsServer = "http://192.168.1.201:8080/tfs";
        public const string eChartCollection = "hstprojects7.0";
        public const string eChartProjectPath = "$/eChart/Development/eChart/";

        //setting params
        public string SavePathDir;
        public DateTime QueryFrom;
        public DateTime QueryTo;
        public string QueryUser;

        #endregion
        private static QuerySetting _querySetting;
        private QuerySetting()
        {
            InitParam();
        }

        public static QuerySetting Instance()
        {
            if (null == _querySetting)
            {
                _querySetting = new QuerySetting();
            }
            return _querySetting;
        }

        private void InitParam()
        {

        }


        public Tuple<bool,string> Validation()
        {
            Tuple<bool, string> valided = new Tuple<bool, string>(true, string.Empty);
            if (string.IsNullOrEmpty(SavePathDir))
            {
                valided = new Tuple<bool, string>(false, "Select the save path first!");
            }

            if (null == QueryFrom || null == QueryTo || QueryTo < QueryFrom)
            {
                valided = new Tuple<bool, string>(false, "Query Date mustn't empty,and from date must be after to date");
            }

            return valided;
        }


    }
}
