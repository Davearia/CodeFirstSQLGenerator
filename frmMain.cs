using System;
using System.Windows.Forms;

namespace CodeFirstSQLGenerator
{
    public partial class frmMain : Form
    {
        public frmMain()
        {
            InitializeComponent();
        }

        private void btnBrowse_Click(object sender, System.EventArgs e)
        {
            if (ofdFile.ShowDialog() == DialogResult.OK)
            {
                string line;
                var sbLit = new System.Text.StringBuilder();
                var file = new System.IO.StreamReader(ofdFile.FileName);

                sbLit.AppendLine("var sqlBuilder = new StringBuilder();");
                sbLit.AppendLine();

                while ((line = file.ReadLine()) != null)
                {
                    if (!string.IsNullOrEmpty(line))
                    {
                        sbLit.AppendLine("sqlBuilder.AppendLine(\"" + line + "\");");
                    }
                    else
                    {
                        sbLit.AppendLine("sqlBuilder.AppendLine();");
                    }
                }

                file.Close();

                sbLit.AppendLine();
                sbLit.AppendLine("migrationBuilder.Sql(sqlBuilder.ToString());");

                rtbSQL.Text = sbLit.ToString();

            }
        }
    }
}
