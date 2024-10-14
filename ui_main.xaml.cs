using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Printing;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Forms;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using System.Xml;
using static System.Runtime.InteropServices.JavaScript.JSType;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TextBox;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.Window;


namespace xrToolkit
{
    /// <summary>
    /// Lógica de interacción para ui_main.xaml
    /// </summary>
    public partial class ui_main : Window
    {
        public ui_main()
        {
            InitializeComponent();
            combo_workspaces.Items.Clear();
            list_workspaces.Items.Clear();
            loadWorkspaces();
            
        }

        public void loadWorkspaces()
        {
            // Ruta del archivo XML
            string workspaces_index = System.IO.Path.GetFullPath(@"index_workspaces.xml");

            try
            {
                // Cargar el archivo XML
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(workspaces_index);

                // Obtener el nodo raíz
                XmlNode root = xmlDoc.DocumentElement;

                // Recorrer los nodos hijo
                foreach (XmlNode node in root.SelectNodes("value"))
                {
                    // Obtener el valor del nodo
                    string workspaceName = node.InnerText;

                    // Agregar el valor al ListBox
                    combo_workspaces.Items.Add(workspaceName);
                    list_workspaces.Items.Add(workspaceName);
                }
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btn_decompile_map_Click(object sender, RoutedEventArgs e)
        {
        }

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            dialog.SelectedPath = @"gamedata/meshes";
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_ogfobj_input.Text = path;
            }
        }

        private void btn_output_db_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_db_output.Text = path;
            }
        }

        private void btn_input_ogfobj_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_ogfobj_input.Text = path;
            }
        }

        private void btn_output_ogfobj_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_ogfobj_output.Text = path;
            }
        }

        private void btn_ogfobj_convert_Click_2(object sender, RoutedEventArgs e)
        {
            // Paths validation
            if (string.IsNullOrWhiteSpace(input_ogfobj_input.Text))
            {
                // If paths are empty...
                System.Windows.MessageBox.Show("Insert the paths", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
            else
            {
                if (check_ogfobj_autostore.IsChecked == true)
                {
                    convertOGFtoOBJECT();
                }
                else
                {
                    if (string.IsNullOrWhiteSpace(input_ogfobj_output.Text))
                    {
                        System.Windows.MessageBox.Show("Insert the paths", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
                    }
                    else
                    {
                        convertOGFtoOBJECT();
                    }
                }
            }
        }

        public void convertOGFtoOBJECT()
        {
            // If paths are filled:

            // Declaring and getting paths
            string exePath = System.IO.Path.GetFullPath(@"thirdtools\converter.exe");
            string inputPath = System.IO.Path.GetFullPath(input_ogfobj_input.Text);
            string outputPath = System.IO.Path.GetFullPath(input_ogfobj_output.Text);

            // Stores all files in input path
            string[] ogfFiles = Directory.GetFiles(inputPath, "*.ogf").Select(System.IO.Path.GetFileNameWithoutExtension).ToArray();

            // Loop for converting all files found
            foreach (string file in ogfFiles)
            {
                // Status output
                status_ogfobj.Text += "Converting " + file + "...\n";

                // Arguments declaration
                string arguments;

                if (check_ogfobj_autostore.IsChecked == true)
                {
                    arguments = "-ogf -object " + inputPath + "\\" + file + ".ogf -out " + System.IO.Path.GetFullPath("rawdata\\objects\\converter_output") + "\\" + file + ".object";
                }
                else
                {
                    arguments = "-ogf -object " + inputPath + "\\" + file + ".ogf -out " + outputPath + "\\" + file + ".object";
                }

                // Declaring process with collected data
                ProcessStartInfo startInfo = new ProcessStartInfo
                {
                    FileName = exePath,
                    Arguments = arguments,
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                };

                try
                {
                    // Starts process
                    using (Process process = Process.Start(startInfo))
                    {
                        // Status output
                        using (StreamReader reader = process.StandardOutput)
                        {
                            status_ogfobj.Text += "Done!\n";
                        }
                    }
                }
                catch (Exception ex)
                {
                    // If something fails...
                    {
                        System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
            // FINISH
            System.Windows.MessageBox.Show("Finished", "Done", MessageBoxButton.OK, MessageBoxImage.Information);
        }


        private void disable_ogfobj_output(object sender, RoutedEventArgs e)
        {
            // Disables or enables output path
            if (check_ogfobj_autostore.IsChecked == true)
            {
                input_ogfobj_output.IsEnabled = false;
                btn_output_ogfobj.IsEnabled = false;
            }
            else
            {
                input_ogfobj_output.IsEnabled = true;
                btn_output_ogfobj.IsEnabled = true;
            }
        }

        private void set_input_db(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_db_input.Text = path;
            }
        }

        private void set_output_db(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_db_output.Text = path;
            }
        }

        private void btn_unpack_db_Click(object sender, RoutedEventArgs e)
        {
            
        }

        private void decompile_level(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(input_map_name.Text))
            {
                System.Windows.MessageBox.Show("Insert the level name", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
            else
            {
                string var_level_name = input_map_name.Text;
                string decompilation_code = "converter.exe -level sdk:" + var_level_name + " -mode le -with_lods";

                status_level.Text += "Decompiling " + var_level_name + " map...\n";

                // Ruta del archivo .bat
                string batFilePath = System.IO.Path.GetFullPath(@"thirdtools\decompile_level.bat");

                // Contenido del archivo .bat
                string batContent = decompilation_code + "\npause";

                // Crear y escribir en el archivo .bat
                File.WriteAllText(batFilePath, batContent);

                // Configurar el proceso para ejecutar el archivo .bat
                ProcessStartInfo processInfo = new ProcessStartInfo("cmd.exe", "/c " + batFilePath);
                processInfo.RedirectStandardOutput = true;
                processInfo.CreateNoWindow = false;
                processInfo.UseShellExecute = false;

                // Ejecutar el archivo .bat
                Process process = Process.Start(processInfo);
                process.WaitForExit();
            }
            System.Windows.MessageBox.Show("Finished", "Done", MessageBoxButton.OK, MessageBoxImage.Exclamation);
            status_level.Text += "Finished...";
        }

        private void btn_workspace_gamedata_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_workspace_gamedata.Text = path;
            }

        }

        private void btn_workspace_rawdata_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_workspace_rawdata.Text = path;
            }
        }

        private void load_workspace_data(object sender, SelectionChangedEventArgs e)
        {
            if (list_workspaces.SelectedItem != null)
            {
                // Obtener el texto del elemento seleccionado
                string selectedWorkspace = list_workspaces.SelectedItem.ToString();
                // Ruta del archivo XML
                string workspace_file = System.IO.Path.GetFullPath(@"workspace_" + selectedWorkspace + ".xml");

                try
                {
                    // Cargar el archivo XML
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.Load(workspace_file);

                    // Obtener el nodo raíz
                    XmlNode root = xmlDoc.DocumentElement;

                    // Recorrer los nodos hijo
                    foreach (XmlNode node in root.SelectNodes("value[@name='gamedata_path']"))
                    {
                        // Obtener el valor del nodo
                        string gamedataPath = node.InnerText;

                        input_workspace_gamedata.Text = gamedataPath;
                    }

                    // Recorrer los nodos hijo
                    foreach (XmlNode node in root.SelectNodes("value[@name='rawdata_path']"))
                    {
                        // Obtener el valor del nodo
                        string rawdataPath = node.InnerText;

                        input_workspace_rawdata.Text = rawdataPath;
                    }
                }
                catch (Exception ex)
                {
                    System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            } else
            {

            }
        }

        private void create_workspace(object sender, RoutedEventArgs e)
        {
            ui_workspace_create WorkspaceCreatorWindow = new ui_workspace_create();
            WorkspaceCreatorWindow.ShowDialog();
            combo_workspaces.Items.Clear();
            list_workspaces.Items.Clear();
            loadWorkspaces();
        }

        private void btn_save_workspace_Click(object sender, RoutedEventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(list_workspaces.SelectedItem.ToString()))
            {
                string selectedWorkspace = list_workspaces.SelectedItem.ToString();
                string newGamedataPath = System.IO.Path.GetFullPath(input_workspace_gamedata.Text);
                string newRawdataPath = System.IO.Path.GetFullPath(input_workspace_rawdata.Text);

                try
                {
                    // Cargar el archivo XML
                    XmlDocument doc = new XmlDocument();
                    doc.Load(System.IO.Path.GetFullPath(@"workspace_" + selectedWorkspace + ".xml"));

                    // Seleccionar el nodo que deseas modificar
                    XmlNode gamedataNode = doc.SelectSingleNode("//value[@name='gamedata_path']");
                    XmlNode rawdataNode = doc.SelectSingleNode("//value[@name='rawdata_path']");

                    // Reemplazar el valor del nodo
                    gamedataNode.InnerText = newGamedataPath;
                    rawdataNode.InnerText = newRawdataPath;

                    // Guardar los cambios en el archivo XML
                    doc.Save(System.IO.Path.GetFullPath(@"workspace_" + selectedWorkspace + ".xml"));
                    System.Windows.MessageBox.Show("Changes applied successfully to the workspace.", "Done", MessageBoxButton.OK, MessageBoxImage.Exclamation);
                }
                catch (Exception ex)
                {
                    System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            System.Windows.MessageBox.Show("Select a workspace first.", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
        }

        private void open_levelcompiler(object sender, RoutedEventArgs e)
        {
            try
            {
                Process levelcompiler_process = new Process();
                levelcompiler_process.StartInfo.FileName = System.IO.Path.GetFullPath(@"bin\compilers_sky_x64\xrCompiler.exe");
                levelcompiler_process.StartInfo.UseShellExecute = false;
                levelcompiler_process.Start();
            } catch(Exception ex)
            {
                System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btn_tool_omfeditor_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                Process levelcompiler_process = new Process();
                levelcompiler_process.StartInfo.FileName = System.IO.Path.GetFullPath(@"thirdtools\OMFEditor.exe");
                levelcompiler_process.StartInfo.UseShellExecute = false;
                levelcompiler_process.Start();
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btn_tool_iconeditor_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                Process levelcompiler_process = new Process();
                levelcompiler_process.StartInfo.FileName = System.IO.Path.GetFullPath(@"thirdtools\SIE.exe");
                levelcompiler_process.StartInfo.UseShellExecute = false;
                levelcompiler_process.Start();
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btn_tool_thmeditor_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                Process levelcompiler_process = new Process();
                levelcompiler_process.StartInfo.FileName = System.IO.Path.GetFullPath(@"thirdtools\THMEditor.exe");
                levelcompiler_process.StartInfo.UseShellExecute = false;
                levelcompiler_process.Start();
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btn_tool_oggeditor_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                Process levelcompiler_process = new Process();
                levelcompiler_process.StartInfo.FileName = System.IO.Path.GetFullPath(@"thirdtools\SAVandT.exe");
                levelcompiler_process.StartInfo.UseShellExecute = false;
                levelcompiler_process.Start();
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}
   

