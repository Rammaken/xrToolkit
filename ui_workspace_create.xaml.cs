using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
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
using System.Xml;

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
            if(string.IsNullOrWhiteSpace(input_workcreate_gamedatapath.Text) || string.IsNullOrWhiteSpace(input_workcreate_rawdatapath.Text))
            {
                System.Windows.MessageBox.Show("Insert all the paths.", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
            } else
            {
                string workspace_name = input_workcreate_name.Text;
                string gamedata_path = System.IO.Path.GetFullPath(input_workcreate_gamedatapath.Text);
                string rawdata_path = System.IO.Path.GetFullPath(input_workcreate_rawdatapath.Text);
                string workspace_file_path = System.IO.Path.GetFullPath(@"workspace_" + workspace_name + ".xml");

                // Contenido que se va a escribir en el archivo
                string content = "<workspace>\r\n    <value name=\"gamedata_path\">" + gamedata_path + "</value>\r\n    <value name=\"rawdata_path\">" + rawdata_path + "</value>\r\n</workspace>";

                try
                {
                    // Crear y escribir en el archivo
                    File.WriteAllText(workspace_file_path, content);

                    try
                    {
                        // Cargar el documento XML
                        XmlDocument doc = new XmlDocument();
                        doc.Load(System.IO.Path.GetFullPath(@"index_workspaces.xml"));

                        // Crear un nuevo elemento
                        XmlElement nuevoElemento = doc.CreateElement("value");
                        nuevoElemento.InnerText = workspace_name;

                        // Seleccionar el nodo donde se agregará el nuevo elemento
                        XmlNode nodoPadre = doc.SelectSingleNode("workspaces");


                        // Agregar el nuevo elemento al nodo padre
                        nodoPadre.AppendChild(nuevoElemento);

                        // Guardar los cambios en el archivo XML
                        doc.Save(System.IO.Path.GetFullPath(@"index_workspaces.xml"));

                        try
                        {
                            string gamedataBase = System.IO.Path.GetFullPath(@"resources\gamedata_base.zip");
                            string rawdataBase = System.IO.Path.GetFullPath(@"resources\rawdata_base.zip");
                            // Extraer el archivo .zip
                            ZipFile.ExtractToDirectory(gamedataBase, gamedata_path);
                            ZipFile.ExtractToDirectory(rawdataBase, rawdata_path);
                            System.Windows.MessageBox.Show("Workspace " + workspace_name + " created sucessfully", "Done", MessageBoxButton.OK, MessageBoxImage.Question);
                            this.Close();
                        }
                        catch(Exception ex)
                        {
                            System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
                catch (Exception ex)
                {
                    System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
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
