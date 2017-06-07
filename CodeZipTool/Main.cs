using CodeZipTool.Setting;
using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.Framework.Client;
using Microsoft.TeamFoundation.Framework.Common;
using Microsoft.TeamFoundation.VersionControl.Client;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Windows.Threading;

namespace CodeZipTool
{
    public partial class Main : Form
    {
        private QuerySetting querySetting = QuerySetting.Instance();
        public Main()
        {
            InitializeComponent();
        }

        private void Main_Load(object sender, EventArgs e)
        {
            querySetting.QueryFrom = date_queryFrom.Value;
            querySetting.QueryTo = date_queryTo.Value;
        }

        private void menu_savepath_Click(object sender, EventArgs e)
        {
            if (folder_open.ShowDialog() == DialogResult.OK)
            {
                if (!String.IsNullOrEmpty(folder_open.SelectedPath))
                {
                    querySetting.SavePathDir = folder_open.SelectedPath;
                }
            }
        }

        private void date_queryFrom_ValueChanged(object sender, EventArgs e)
        {
            querySetting.QueryFrom = date_queryFrom.Value;
        }

        private void date_queryTo_ValueChanged(object sender, EventArgs e)
        {
            querySetting.QueryTo = date_queryTo.Value;
        }
        private void btn_zip_Click(object sender, EventArgs e)
        {
            Tuple<bool, string> valided = querySetting.Validation();
            if (!valided.Item1)
            {
                lbl_error.Text = valided.Item2;
                return;
            }
            lbl_error.Text = string.Empty;
            this.gbox_detail.Visible = true;
            this.progressbar_task.Value = 0;
            
            //run the task
            new Thread((ThreadStart)(delegate ()
            {
                try
                {
                    RunZip();
                }
                catch (Exception ex)
                {
                    lbl_error.Invoke((MethodInvoker)delegate () {
                        lbl_error.Text = ex.Message;
                    });
                }
            })).Start();
        }

        private void RunZip()
        {
            WriteTextToView("Initializing..connecting tfs!");

            Uri tfsUri = new Uri(QuerySetting.tfsServer);
            var eChartCollectionPath = QuerySetting.tfsServer + '/' + QuerySetting.eChartCollection;

            TfsConfigurationServer configruationServer = TfsConfigurationServerFactory.GetConfigurationServer(tfsUri);

            ReadOnlyCollection<CatalogNode> collectionNodes = configruationServer.CatalogNode.QueryChildren(
                new[] { CatalogResourceTypes.ProjectCollection },
                false, CatalogQueryOptions.None);

            foreach (CatalogNode collectionNode in collectionNodes)
            {
                Guid collectionId = new Guid(collectionNode.Resource.Properties["InstanceId"]);
                TfsTeamProjectCollection teamProjectCollection = configruationServer.GetTeamProjectCollection(collectionId);

                if (!teamProjectCollection.Name.Equals(eChartCollectionPath)) continue;

                teamProjectCollection.EnsureAuthenticated();

                var vcs = teamProjectCollection.GetService<VersionControlServer>();
                var localFileBaseDir = System.IO.Path.Combine(querySetting.SavePathDir , System.DateTime.Now.ToShortDateString().Replace("/", ""));



                var changesetlist = vcs.QueryHistory(
                                                     QuerySetting.eChartProjectPath,
                                                     VersionSpec.Latest,
                                                     0,
                                                     RecursionType.Full,
                                                     null,                  //all user
                                                     new DateVersionSpec(Convert.ToDateTime(querySetting.QueryFrom.ToShortDateString())),
                                                     new DateVersionSpec(Convert.ToDateTime(querySetting.QueryTo.ToShortDateString())),
                                                     int.MaxValue,
                                                     true,
                                                     false);


                WriteTextToView("Data reading..");

                int changeTotal = 0;
                StringBuilder sb = new StringBuilder();
                foreach (Changeset changeset in changesetlist)
                {
                    changeTotal += changeset.Changes.Count();
                }
                progressbar_task.Invoke((MethodInvoker)delegate () {
                    progressbar_task.Maximum = changeTotal;
                });

                WriteTextToView("Downloading..");
                sb.Append("Path            Comments\r\n");
                sb.Append("------------------------\r\n");

                foreach (Changeset changeset in changesetlist)
                {
                    foreach (Change change in changeset.Changes)
                    {
                        Item item = change.Item;
                        var log = string.Format("{0}            {1} {2} ,{3}", item.ServerItem,item.CheckinDate,  changeset.Comment, change.ChangeType);

                        WriteTextToView(log);

                        progressbar_task.Invoke((MethodInvoker)delegate () {
                            progressbar_task.Value++;
                        });

                        Tuple<bool, string> mergedHistory = IsEditedByEHRBuilder(vcs, item.ServerItem);

                        if (mergedHistory.Item1)
                        {
                            WriteTextToView("<Only by EHRBuilder, Drop!>");
                            continue;
                        }

                        sb.Append(log+" by " + mergedHistory.Item2 + " \r\n");

                        var localFile = System.IO.Path.Combine(localFileBaseDir, item.ServerItem.Replace(QuerySetting.eChartProjectPath, ""));

                        item.DownloadFile(localFile);
                    }
                }

                var logPath = System.IO.Path.Combine(localFileBaseDir, "Manifest.txt");
                System.IO.File.WriteAllText(logPath, sb.ToString());

                var zipPath = System.IO.Path.Combine(querySetting.SavePathDir,  System.DateTime.Now.ToShortDateString().Replace("/", "") + ".zip");
                WriteTextToView("Zipping..to "+ zipPath);

                ZipFile.CreateFromDirectory(localFileBaseDir, zipPath);

                WriteTextToView("Finish successfully!");
            }
        }

        protected void WriteTextToView(string text)
        {
            lbox_detail.Invoke((MethodInvoker)delegate ()
            {
                lbox_detail.Items.Add(text);
                lbox_detail.Refresh();
                lbox_detail.SelectedIndex = lbox_detail.Items.Count - 1;
            });
        }

        private void linklbl_showdetial_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            this.lbox_detail.Visible = true;
        }

        private void menu_openpath_Click(object sender, EventArgs e)
        {
            if(!string.IsNullOrEmpty(querySetting.SavePathDir))
            { 
                Process.Start(querySetting.SavePathDir);
            }
        }

        protected Tuple<bool,string> IsEditedByEHRBuilder(VersionControlServer server,string _filePath)
        {
            Tuple<bool, string> historyMerge = null;
            var queryParams = new QueryHistoryParameters(_filePath, RecursionType.Full)
            {
                ItemVersion = VersionSpec.Latest,
                DeletionId = 0,
                Author = null,
                VersionStart = new DateVersionSpec(Convert.ToDateTime(querySetting.QueryFrom.ToShortDateString())),
                VersionEnd = new DateVersionSpec(Convert.ToDateTime(querySetting.QueryTo.ToShortDateString())),
                MaxResults = Int32.MaxValue,
                IncludeChanges = true,
                SlotMode = false
            };

            List<string> cUser = new List<string>();

            foreach (Changeset cs in server.QueryHistory(queryParams))
            {
                if (!cUser.Contains(cs.CommitterDisplayName))
                {
                    cUser.Add(cs.CommitterDisplayName);
                }
                
            }
            
            historyMerge = new Tuple<bool, string>(cUser.Count == 1 && cUser[0].Equals("EHRBuilder") ? true : false, String.Join(",", cUser.ToArray()));

            return historyMerge;
        }
    }
}

        
  
