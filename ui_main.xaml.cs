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
using System.Xml.Linq;
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

        public void applyWorkspace()
        {
            try
            {
                string workspaceName = combo_workspaces.SelectedItem.ToString();
                string workspace_file = System.IO.Path.GetFullPath(@"workspace_" + workspaceName + ".xml");

                XDocument xmlDoc = XDocument.Load(workspace_file);

                // Obtener el valor del nodo gamedata_path
                string gamedataPath = xmlDoc.Root.Element("value")?.Attribute("name")?.Value == "gamedata_path" ? xmlDoc.Root.Element("value")?.Value : null;

                string rawdataPath = xmlDoc.Root.Elements("value").FirstOrDefault(e => e.Attribute("name")?.Value == "rawdata_path")?.Value;

                try
                {
                    string fsPath = System.IO.Path.GetFullPath(@"fs.ltx");
                    string fsgamePath = System.IO.Path.GetFullPath(@"fsgame.ltx");
                    string fsfactoryPath = System.IO.Path.GetFullPath(@"fsfactory.ltx");
                    string converterPath = System.IO.Path.GetFullPath(@"converter.ini");
                    string fsconverterPath = System.IO.Path.GetFullPath(@"fsconverter.ltx");

                    //======== fs.ltx block ========
                    string[] fsLines = File.ReadAllLines(fsPath);

                    for (int i = 0; i < fsLines.Length; i++)
                    {
                        if (fsLines[i].Contains("$server_data_root$"))
                        {
                            fsLines[i] = "$server_data_root$          = false| false| " + rawdataPath + "\\";
                            break;
                        }
                    }

                    for (int i = 0; i < fsLines.Length; i++)
                    {
                        if (fsLines[i].Contains("$game_data$"))
                        {
                            fsLines[i] = "$game_data$                 = false| true| " + gamedataPath + "\\";
                            break;
                        }
                    }

                    File.WriteAllLines(fsPath, fsLines);

                    //======== fsgame.ltx block ========
                    string[] fsgameLines = File.ReadAllLines(fsgamePath);

                    for (int i = 0; i < fsgameLines.Length; i++)
                    {
                        if (fsgameLines[i].Contains("$game_data$"))
                        {
                            fsgameLines[i] = "$game_data$                 = false| true| " + gamedataPath + "\\";
                            break;
                        }
                    }

                    File.WriteAllLines(fsgamePath, fsgameLines);

                    //======== fsfactory.ltx block ========
                    string[] fsfactoryLines = File.ReadAllLines(fsfactoryPath);

                    for (int i = 0; i < fsfactoryLines.Length; i++)
                    {
                        if (fsfactoryLines[i].Contains("$server_data_root$"))
                        {
                            fsfactoryLines[i] = "$server_data_root$          = false| false| " + rawdataPath + "\\";
                            break;
                        }
                    }

                    for (int i = 0; i < fsfactoryLines.Length; i++)
                    {
                        if (fsfactoryLines[i].Contains("$game_data$"))
                        {
                            fsfactoryLines[i] = "$game_data$                 = false| true| " + gamedataPath + "\\";
                            break;
                        }
                    }

                    File.WriteAllLines(fsfactoryPath, fsfactoryLines);

                    //======== converter.ini block ========
                    string[] converterLines = File.ReadAllLines(converterPath);

                    for (int i = 0; i < converterLines.Length; i++)
                    {
                        if (converterLines[i].Contains("$game_data$"))
                        {
                            converterLines[i] = "$game_data$\t\t\t= " + gamedataPath + "\\";
                            break;
                        }
                    }

                    for (int i = 0; i < converterLines.Length; i++)
                    {
                        if (converterLines[i].Contains("$game_levels$"))
                        {
                            converterLines[i] = "$game_levels$\t\t\t= " + gamedataPath + "\\levels\\";
                            break;
                        }
                    }

                    File.WriteAllLines(converterPath, converterLines);

                    //======== fsconverter.ltx block ========
                    string[] fsconverterLines = File.ReadAllLines(fsconverterPath);

                    for (int i = 0; i < fsconverterLines.Length; i++)
                    {
                        if (fsconverterLines[i].Contains("$sdk_root_raw$"))
                        {
                            fsconverterLines[i] = "$sdk_root_raw$          = false| false| " + rawdataPath + "\\";
                            break;
                        }
                    }

                    for (int i = 0; i < fsconverterLines.Length; i++)
                    {
                        if (fsconverterLines[i].Contains("server_data_root"))
                        {
                            fsconverterLines[i] = "$server_data_root$          = false| false| " + rawdataPath + "\\";
                            break;
                        }
                    }

                    for (int i = 0; i < fsconverterLines.Length; i++)
                    {
                        if (fsconverterLines[i].Contains("$game_data$"))
                        {
                            fsconverterLines[i] = "$game_data$                 = false| true| " + gamedataPath + "\\";
                            break;
                        }
                    }

                    File.WriteAllLines(fsconverterPath, fsconverterLines);
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
            string workspaceName = combo_workspaces.SelectedItem.ToString();
            string workspace_file = System.IO.Path.GetFullPath(@"workspace_" + workspaceName + ".xml");

            XDocument xmlDoc = XDocument.Load(workspace_file);

            string rawdataPath = xmlDoc.Root.Elements("value").FirstOrDefault(e => e.Attribute("name")?.Value == "rawdata_path")?.Value;

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
                    arguments = "-ogf -object " + inputPath + "\\" + file + ".ogf -out " + System.IO.Path.GetFullPath(rawdataPath + "\\converter_output") + "\\" + file + ".object";
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
            System.Windows.MessageBox.Show("Finished", "Done", MessageBoxButton.OK, MessageBoxImage.Information);
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
                btn_save_workspace.IsEnabled = true;
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
                btn_save_workspace.IsEnabled = false;
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
            if(string.IsNullOrWhiteSpace(input_workspace_gamedata.Text) || string.IsNullOrWhiteSpace(input_workspace_rawdata.Text))
            {
                System.Windows.MessageBox.Show("Insert all the paths.", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
            } else
            {
                if (list_workspaces.SelectedItem != null)
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
                        System.Windows.MessageBox.Show("Changes applied successfully to the workspace.", "Done", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    catch (Exception ex)
                    {
                        System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
                else
                {
                    System.Windows.MessageBox.Show("Select a workspace first.", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
                }
                
            }
            
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

        private void delete_workspace_Click(object sender, RoutedEventArgs e)
        {

            MessageBoxResult validation = System.Windows.MessageBox.Show("Are you sure you want to delete this workspace?","Warning",MessageBoxButton.YesNo,MessageBoxImage.Warning);

            switch (validation)
            {
                case MessageBoxResult.Yes:
                    string selectedWorkspace = list_workspaces.SelectedItem.ToString();
                    string workspacePath = System.IO.Path.GetFullPath(@"workspace_" + selectedWorkspace + ".xml");
                    string workspacesIndex = System.IO.Path.GetFullPath(@"index_workspaces.xml");

                    try
                    {
                        XDocument xdoc = XDocument.Load(workspacesIndex);

                        var elementsToRemove = xdoc.Descendants().Where(e => e.Value == selectedWorkspace).ToList();

                        foreach (var element in elementsToRemove)
                        {
                            element.Remove();
                        }

                        xdoc.Save(workspacesIndex);

                        try
                        {
                            if (File.Exists(workspacePath))
                            {
                                // Elimina el archivo
                                File.Delete(workspacePath);
                            }
                            else
                            {
                                System.Windows.MessageBox.Show("Couldn't find workspace info file.", "Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                            }

                            System.Windows.MessageBox.Show(selectedWorkspace + " workspace deleted sucessfully.", "Done", MessageBoxButton.OK, MessageBoxImage.Information);
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

                    
                    break;
                case MessageBoxResult.No:
                    
                    break;
            }
        }

        private void changeWorkspace(object sender, SelectionChangedEventArgs e)
        {
            applyWorkspace();
        }

        private void check_ogfobj_autostore_Checked(object sender, RoutedEventArgs e)
        {

        }

        private void btn_input_omfskls_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_omfskls_input.Text = path;
            }
        }

        private void btn_output_omfskls_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_omfskls_output.Text = path;
            }
        }

        private void btn_omfskls_convert_Click_2(object sender, RoutedEventArgs e)
        {
            // Paths validation
            if (string.IsNullOrWhiteSpace(input_omfskls_input.Text))
            {
                // If paths are empty...
                System.Windows.MessageBox.Show("Insert the paths", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
            else
            {
                if (check_omfskls_autostore.IsChecked == true)
                {
                    convertOMFtoSKLS();
                }
                else
                {
                    if (string.IsNullOrWhiteSpace(input_omfskls_output.Text))
                    {
                        System.Windows.MessageBox.Show("Insert the paths", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
                    }
                    else
                    {
                        convertOMFtoSKLS();
                    }
                }
            }
        }

        public void convertOMFtoSKLS()
        {
            string workspaceName = combo_workspaces.SelectedItem.ToString();
            string workspace_file = System.IO.Path.GetFullPath(@"workspace_" + workspaceName + ".xml");

            XDocument xmlDoc = XDocument.Load(workspace_file);

            string rawdataPath = xmlDoc.Root.Elements("value").FirstOrDefault(e => e.Attribute("name")?.Value == "rawdata_path")?.Value;

            // Declaring and getting paths
            string exePath = System.IO.Path.GetFullPath(@"thirdtools\converter.exe");
            string inputPath = System.IO.Path.GetFullPath(input_omfskls_input.Text);
            string outputPath = System.IO.Path.GetFullPath(input_omfskls_output.Text);

            // Stores all files in input path
            string[] omfFiles = Directory.GetFiles(inputPath, "*.omf").Select(System.IO.Path.GetFileNameWithoutExtension).ToArray();

            // Loop for converting all files found
            foreach (string file in omfFiles)
            {
                // Status output
                status_omfskls.Text += "Converting " + file + "...\n";

                // Arguments declaration
                string arguments;

                if (check_omfskls_autostore.IsChecked == true)
                {
                    arguments = "-omf -skls " + inputPath + "\\" + file + ".omf -out " + System.IO.Path.GetFullPath(rawdataPath + "\\converter_output") + "\\" + file + ".skls";
                }
                else
                {
                    arguments = "-omf -skls " + inputPath + "\\" + file + ".omf -out " + outputPath + "\\" + file + ".skls";
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
                            status_omfskls.Text += "Done!\n";
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


        private void disable_omfskls_output(object sender, RoutedEventArgs e)
        {
            // Disables or enables output path
            if (check_omfskls_autostore.IsChecked == true)
            {
                input_omfskls_output.IsEnabled = false;
                btn_output_omfskls.IsEnabled = false;
            }
            else
            {
                input_omfskls_output.IsEnabled = true;
                btn_output_omfskls.IsEnabled = true;
            }
        }

        private void btn_input_ddstga_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_ddstga_input.Text = path;
            }
        }

        private void btn_output_ddstga_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new System.Windows.Forms.FolderBrowserDialog();
            System.Windows.Forms.DialogResult result = dialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
            {
                string path = dialog.SelectedPath;
                input_ddstga_output.Text = path;
            }
        }

        private void btn_ddstga_convert_Click_2(object sender, RoutedEventArgs e)
        {
            // Paths validation
            if (string.IsNullOrWhiteSpace(input_ddstga_input.Text))
            {
                // If paths are empty...
                System.Windows.MessageBox.Show("Insert the paths", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
            else
            {
                if (check_ddstga_autostore.IsChecked == true)
                {
                    convertDDStoTGA();
                }
                else
                {
                    if (string.IsNullOrWhiteSpace(input_ddstga_output.Text))
                    {
                        System.Windows.MessageBox.Show("Insert the paths", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
                    }
                    else
                    {
                        convertDDStoTGA();
                    }
                }
            }
        }

        public void convertDDStoTGA()
        {
            string workspaceName = combo_workspaces.SelectedItem.ToString();
            string workspace_file = System.IO.Path.GetFullPath(@"workspace_" + workspaceName + ".xml");

            XDocument xmlDoc = XDocument.Load(workspace_file);

            string rawdataPath = xmlDoc.Root.Elements("value").FirstOrDefault(e => e.Attribute("name")?.Value == "rawdata_path")?.Value;

            // Declaring and getting paths
            string exePath = System.IO.Path.GetFullPath(@"thirdtools\magick.exe");
            string inputPath = System.IO.Path.GetFullPath(input_ddstga_input.Text);
            string outputPath = System.IO.Path.GetFullPath(input_ddstga_output.Text);

            // Stores all files in input path
            string[] ddsFiles = Directory.GetFiles(inputPath, "*.dds").Select(System.IO.Path.GetFileNameWithoutExtension).ToArray();

            // Loop for converting all files found
            foreach (string file in ddsFiles)
            {
                // Status output
                status_ddstga.Text += "Converting " + file + "...\n";

                // Arguments declaration
                string arguments;

                if (check_ddstga_autostore.IsChecked == true)
                {
                    arguments = inputPath + "\\" + file + ".dds " + System.IO.Path.GetFullPath(rawdataPath + "\\converter_output") + "\\" + file + ".tga";
                }
                else
                {
                    arguments = inputPath + "\\" + file + ".dds " + outputPath + "\\" + file + ".tga";
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
                            status_ddstga.Text += "Done!\n";
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


        private void disable_ddstga_output(object sender, RoutedEventArgs e)
        {
            // Disables or enables output path
            if (check_ddstga_autostore.IsChecked == true)
            {
                input_ddstga_output.IsEnabled = false;
                btn_output_ddstga.IsEnabled = false;
            }
            else
            {
                input_ddstga_output.IsEnabled = true;
                btn_output_ddstga.IsEnabled = true;
            }
        }
    }
}
   

