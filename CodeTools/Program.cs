/*----------------------------------------------------------------
 * Install-Package Microsoft.TeamFoundationServer.ExtendedClient
 ----------------------------------------------------------------*/
using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Framework.Client;
using Microsoft.TeamFoundation.Framework.Common;
using Microsoft.TeamFoundation.VersionControl.Client;
using System;
using System.Collections.ObjectModel;

namespace CodeTools
{
    class Program
    {
        static void Main(string[] args)
        {

            Uri tfsUri = new Uri("http://192.168.1.201:8080/tfs");//http://192.168.1.201:8080/tfs/HSTProjects7.0


            TfsConfigurationServer configruationServer = TfsConfigurationServerFactory.GetConfigurationServer(tfsUri);

            ReadOnlyCollection<CatalogNode> collectionNodes = configruationServer.CatalogNode.QueryChildren(
                new[] { CatalogResourceTypes.ProjectCollection },
                false, CatalogQueryOptions.None);

            foreach (CatalogNode collectionNode in collectionNodes)
            {
                Guid collectionId = new Guid(collectionNode.Resource.Properties["InstanceId"]);
                TfsTeamProjectCollection teamProjectCollection = configruationServer.GetTeamProjectCollection(collectionId);

                Console.WriteLine("collection: " + teamProjectCollection.Name);
                if (!teamProjectCollection.Name.Equals("http://192.168.1.201:8080/tfs/hstprojects7.0")) continue;

                teamProjectCollection.EnsureAuthenticated();
                var vcs = teamProjectCollection.GetService<VersionControlServer>();
                var localFileBaseDir = @"E:\AutoTest\eChartRobot\CodeTools\TFSFiles\"+ System.DateTime.Now.ToShortDateString().Replace("/", "");



                var changesetlist = vcs.QueryHistory(
                                                     "$/eChart/Development/eChart",
                                                     VersionSpec.Latest,
                                                     0,
                                                     RecursionType.Full,
                                                     null,                  //all user
                                                     new DateVersionSpec(Convert.ToDateTime("6/01/2017")),
                                                     new DateVersionSpec(System.DateTime.Now),
                                                     int.MaxValue,                    
                                                     true,
                                                     false); 

                //filter



                foreach (Changeset changeset in changesetlist)
                {
                    foreach (Change change in changeset.Changes)
                    {
                        Item item = change.Item;
                        Console.WriteLine(string.Format("{0} {1} {2} {3} {4}", change.ChangeType,item.CheckinDate, changeset.CommitterDisplayName, item.ServerItem, changeset.Comment));
                        var localFile = System.IO.Path.Combine(localFileBaseDir, item.ServerItem.Replace(@"$/eChart/Development/eChart/", ""));
                        item.DownloadFile(localFile); 
                    }
                }




                //print project info
                ReadOnlyCollection<CatalogNode> projectNodes = collectionNode.QueryChildren(
                    new[] { CatalogResourceTypes.TeamProject },
                    false, CatalogQueryOptions.None);

                // List the team projects in the collection
                foreach (CatalogNode projectNode in projectNodes)
                {
                    Console.WriteLine(" Team Project: " + projectNode.Resource.DisplayName);
                    
                }

            }            


            Console.ReadLine();
            
        }
    }
}
