using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace eChartRobot.API
{
    public class test
    {
        public test()
        {

        }
        private static readonly HttpClient client = new HttpClient();
        public async void postreq()
        {
            char[] charname = { '1', '2' };
            var values = new Dictionary<string, string>{ { "loginName", "test"}, { "password", "test" } };
            var content = new FormUrlEncodedContent(values);
            var response = await client.PostAsync("http://tzyb2014.com/manage.html", content);
            var responseString = response.Content.ReadAsStringAsync();
            
        }
    }
}
