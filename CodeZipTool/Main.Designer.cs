namespace CodeZipTool
{
    partial class Main
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Main));
            this.gbx_paramsetting = new System.Windows.Forms.GroupBox();
            this.label8 = new System.Windows.Forms.Label();
            this.date_queryTo = new System.Windows.Forms.DateTimePicker();
            this.btn_zip = new System.Windows.Forms.Button();
            this.label7 = new System.Windows.Forms.Label();
            this.date_queryFrom = new System.Windows.Forms.DateTimePicker();
            this.cmbox_queryUser = new System.Windows.Forms.ComboBox();
            this.label6 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.cmbox_collections = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.tbox_server = new System.Windows.Forms.TextBox();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.文件ToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.menu_savepath = new System.Windows.Forms.ToolStripMenuItem();
            this.menu_openpath = new System.Windows.Forms.ToolStripMenuItem();
            this.helpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.folder_open = new System.Windows.Forms.FolderBrowserDialog();
            this.lbl_error = new System.Windows.Forms.Label();
            this.gbox_detail = new System.Windows.Forms.GroupBox();
            this.lbox_detail = new System.Windows.Forms.ListBox();
            this.linklbl_showdetial = new System.Windows.Forms.LinkLabel();
            this.progressbar_task = new System.Windows.Forms.ProgressBar();
            this.gbx_paramsetting.SuspendLayout();
            this.menuStrip1.SuspendLayout();
            this.gbox_detail.SuspendLayout();
            this.SuspendLayout();
            // 
            // gbx_paramsetting
            // 
            this.gbx_paramsetting.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.gbx_paramsetting.Controls.Add(this.label8);
            this.gbx_paramsetting.Controls.Add(this.date_queryTo);
            this.gbx_paramsetting.Controls.Add(this.btn_zip);
            this.gbx_paramsetting.Controls.Add(this.label7);
            this.gbx_paramsetting.Controls.Add(this.date_queryFrom);
            this.gbx_paramsetting.Controls.Add(this.cmbox_queryUser);
            this.gbx_paramsetting.Controls.Add(this.label6);
            this.gbx_paramsetting.Controls.Add(this.label5);
            this.gbx_paramsetting.Controls.Add(this.label4);
            this.gbx_paramsetting.Controls.Add(this.label3);
            this.gbx_paramsetting.Controls.Add(this.cmbox_collections);
            this.gbx_paramsetting.Controls.Add(this.label2);
            this.gbx_paramsetting.Controls.Add(this.label1);
            this.gbx_paramsetting.Controls.Add(this.tbox_server);
            this.gbx_paramsetting.Location = new System.Drawing.Point(12, 50);
            this.gbx_paramsetting.Name = "gbx_paramsetting";
            this.gbx_paramsetting.Size = new System.Drawing.Size(696, 131);
            this.gbx_paramsetting.TabIndex = 0;
            this.gbx_paramsetting.TabStop = false;
            this.gbx_paramsetting.Text = "tfs parameter setting";
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(348, 99);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(16, 13);
            this.label8.TabIndex = 12;
            this.label8.Text = "to";
            // 
            // date_queryTo
            // 
            this.date_queryTo.Format = System.Windows.Forms.DateTimePickerFormat.Short;
            this.date_queryTo.Location = new System.Drawing.Point(381, 97);
            this.date_queryTo.Name = "date_queryTo";
            this.date_queryTo.Size = new System.Drawing.Size(108, 20);
            this.date_queryTo.TabIndex = 11;
            this.date_queryTo.ValueChanged += new System.EventHandler(this.date_queryTo_ValueChanged);
            // 
            // btn_zip
            // 
            this.btn_zip.Location = new System.Drawing.Point(535, 90);
            this.btn_zip.Name = "btn_zip";
            this.btn_zip.Size = new System.Drawing.Size(75, 30);
            this.btn_zip.TabIndex = 1;
            this.btn_zip.Text = "Zip Lunch";
            this.btn_zip.UseVisualStyleBackColor = true;
            this.btn_zip.Click += new System.EventHandler(this.btn_zip_Click);
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(197, 99);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(27, 13);
            this.label7.TabIndex = 10;
            this.label7.Text = "from";
            // 
            // date_queryFrom
            // 
            this.date_queryFrom.Format = System.Windows.Forms.DateTimePickerFormat.Short;
            this.date_queryFrom.Location = new System.Drawing.Point(230, 97);
            this.date_queryFrom.Name = "date_queryFrom";
            this.date_queryFrom.Size = new System.Drawing.Size(108, 20);
            this.date_queryFrom.TabIndex = 9;
            this.date_queryFrom.ValueChanged += new System.EventHandler(this.date_queryFrom_ValueChanged);
            // 
            // cmbox_queryUser
            // 
            this.cmbox_queryUser.Enabled = false;
            this.cmbox_queryUser.FormattingEnabled = true;
            this.cmbox_queryUser.Items.AddRange(new object[] {
            "All"});
            this.cmbox_queryUser.Location = new System.Drawing.Point(74, 96);
            this.cmbox_queryUser.Name = "cmbox_queryUser";
            this.cmbox_queryUser.Size = new System.Drawing.Size(86, 21);
            this.cmbox_queryUser.TabIndex = 8;
            this.cmbox_queryUser.Text = "All";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(15, 99);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(43, 13);
            this.label6.TabIndex = 7;
            this.label6.Text = "by User";
            // 
            // label5
            // 
            this.label5.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.label5.Location = new System.Drawing.Point(10, 75);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(23, 2);
            this.label5.TabIndex = 2;
            // 
            // label4
            // 
            this.label4.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.label4.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.label4.Location = new System.Drawing.Point(107, 75);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(577, 1);
            this.label4.TabIndex = 6;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(35, 68);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(70, 13);
            this.label3.TabIndex = 5;
            this.label3.Text = "Query History";
            // 
            // cmbox_collections
            // 
            this.cmbox_collections.Enabled = false;
            this.cmbox_collections.FormattingEnabled = true;
            this.cmbox_collections.Items.AddRange(new object[] {
            "hstprojects7.0"});
            this.cmbox_collections.Location = new System.Drawing.Point(327, 29);
            this.cmbox_collections.Name = "cmbox_collections";
            this.cmbox_collections.Size = new System.Drawing.Size(113, 21);
            this.cmbox_collections.TabIndex = 4;
            this.cmbox_collections.Text = "hstprojects7.0";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(268, 32);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(53, 13);
            this.label2.TabIndex = 3;
            this.label2.Text = "Collection";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(7, 33);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(61, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "TFS Server";
            // 
            // tbox_server
            // 
            this.tbox_server.Location = new System.Drawing.Point(74, 30);
            this.tbox_server.Name = "tbox_server";
            this.tbox_server.ReadOnly = true;
            this.tbox_server.Size = new System.Drawing.Size(166, 20);
            this.tbox_server.TabIndex = 0;
            this.tbox_server.Text = "http://192.168.1.201:8080/tfs";
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.文件ToolStripMenuItem,
            this.helpToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.RenderMode = System.Windows.Forms.ToolStripRenderMode.System;
            this.menuStrip1.Size = new System.Drawing.Size(720, 24);
            this.menuStrip1.TabIndex = 5;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // 文件ToolStripMenuItem
            // 
            this.文件ToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.menu_savepath,
            this.menu_openpath});
            this.文件ToolStripMenuItem.Name = "文件ToolStripMenuItem";
            this.文件ToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
            this.文件ToolStripMenuItem.Text = "File";
            // 
            // menu_savepath
            // 
            this.menu_savepath.Name = "menu_savepath";
            this.menu_savepath.Size = new System.Drawing.Size(152, 22);
            this.menu_savepath.Text = "Save";
            this.menu_savepath.Click += new System.EventHandler(this.menu_savepath_Click);
            // 
            // menu_openpath
            // 
            this.menu_openpath.Name = "menu_openpath";
            this.menu_openpath.Size = new System.Drawing.Size(152, 22);
            this.menu_openpath.Text = "Open";
            this.menu_openpath.Click += new System.EventHandler(this.menu_openpath_Click);
            // 
            // helpToolStripMenuItem
            // 
            this.helpToolStripMenuItem.Name = "helpToolStripMenuItem";
            this.helpToolStripMenuItem.Size = new System.Drawing.Size(44, 20);
            this.helpToolStripMenuItem.Text = "Help";
            // 
            // lbl_error
            // 
            this.lbl_error.AutoSize = true;
            this.lbl_error.BackColor = System.Drawing.SystemColors.Control;
            this.lbl_error.ForeColor = System.Drawing.Color.Red;
            this.lbl_error.Location = new System.Drawing.Point(252, 36);
            this.lbl_error.Name = "lbl_error";
            this.lbl_error.Size = new System.Drawing.Size(0, 13);
            this.lbl_error.TabIndex = 7;
            // 
            // gbox_detail
            // 
            this.gbox_detail.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.gbox_detail.AutoSize = true;
            this.gbox_detail.Controls.Add(this.lbox_detail);
            this.gbox_detail.Controls.Add(this.linklbl_showdetial);
            this.gbox_detail.Controls.Add(this.progressbar_task);
            this.gbox_detail.Location = new System.Drawing.Point(12, 188);
            this.gbox_detail.Name = "gbox_detail";
            this.gbox_detail.Size = new System.Drawing.Size(696, 348);
            this.gbox_detail.TabIndex = 6;
            this.gbox_detail.TabStop = false;
            this.gbox_detail.Visible = false;
            // 
            // lbox_detail
            // 
            this.lbox_detail.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lbox_detail.FormattingEnabled = true;
            this.lbox_detail.HorizontalScrollbar = true;
            this.lbox_detail.Location = new System.Drawing.Point(6, 65);
            this.lbox_detail.MinimumSize = new System.Drawing.Size(4, 250);
            this.lbox_detail.Name = "lbox_detail";
            this.lbox_detail.Size = new System.Drawing.Size(684, 238);
            this.lbox_detail.TabIndex = 7;
            this.lbox_detail.Visible = false;
            // 
            // linklbl_showdetial
            // 
            this.linklbl_showdetial.AutoSize = true;
            this.linklbl_showdetial.Location = new System.Drawing.Point(1, 45);
            this.linklbl_showdetial.Name = "linklbl_showdetial";
            this.linklbl_showdetial.Size = new System.Drawing.Size(64, 13);
            this.linklbl_showdetial.TabIndex = 6;
            this.linklbl_showdetial.TabStop = true;
            this.linklbl_showdetial.Text = "Show Detail";
            this.linklbl_showdetial.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linklbl_showdetial_LinkClicked);
            // 
            // progressbar_task
            // 
            this.progressbar_task.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.progressbar_task.Location = new System.Drawing.Point(6, 16);
            this.progressbar_task.Name = "progressbar_task";
            this.progressbar_task.Size = new System.Drawing.Size(684, 23);
            this.progressbar_task.TabIndex = 5;
            // 
            // Main
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSize = true;
            this.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.ClientSize = new System.Drawing.Size(720, 539);
            this.Controls.Add(this.lbl_error);
            this.Controls.Add(this.gbox_detail);
            this.Controls.Add(this.gbx_paramsetting);
            this.Controls.Add(this.menuStrip1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "Main";
            this.Text = "eChart Zip";
            this.Load += new System.EventHandler(this.Main_Load);
            this.gbx_paramsetting.ResumeLayout(false);
            this.gbx_paramsetting.PerformLayout();
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.gbox_detail.ResumeLayout(false);
            this.gbox_detail.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.GroupBox gbx_paramsetting;
        private System.Windows.Forms.ComboBox cmbox_collections;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox tbox_server;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox cmbox_queryUser;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.DateTimePicker date_queryFrom;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.DateTimePicker date_queryTo;
        private System.Windows.Forms.Button btn_zip;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem 文件ToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem menu_savepath;
        private System.Windows.Forms.ToolStripMenuItem menu_openpath;
        private System.Windows.Forms.ToolStripMenuItem helpToolStripMenuItem;
        private System.Windows.Forms.FolderBrowserDialog folder_open;
        private System.Windows.Forms.Label lbl_error;
        private System.Windows.Forms.GroupBox gbox_detail;
        private System.Windows.Forms.ListBox lbox_detail;
        private System.Windows.Forms.LinkLabel linklbl_showdetial;
        private System.Windows.Forms.ProgressBar progressbar_task;
    }
}

