using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace xrToolkit
{

    public partial class ui_workspace_create : Window
    {
        public ui_workspace_create()
        {
            InitializeComponent();
        }

        private void create_workspace(object sender, RoutedEventArgs e)
        {
            string workspace_name = input_workcreate_name.Text;
            string gamedata_path = System.IO.Path.GetFullPath(input_workcreate_gamedatapath.Text);
            string rawdata_path = System.IO.Path.GetFullPath(input_workcreate_rawdatapath.Text);
            string workspace_file_path = System.IO.Path.GetFullPath(@"workspace_");

            // Contenido que se va a escribir en el archivo
            string content = "<workspace>\r\n    <value name=\"gamedata_path\">" + gamedata_path + "</value>\r\n    <value name=\"rawdata_path\">" + rawdata_path + "</value>\r\n</workspace>";

            try
            {
                // Crear y escribir en el archivo
                File.WriteAllText(workspace_file_path, content);
            } catch(Exception ex)
            {
                System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btn_workcreate_gamedata_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_workcreate_gamedatapath.Text = path;
            }
        }

        private void btn_workcreate_rawdata_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_workcreate_rawdatapath.Text = path;
            }
        }
    }
}
