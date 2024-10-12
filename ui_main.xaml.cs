using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
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
        }

        private void btn_decompile_map_Click(object sender, RoutedEventArgs e)
        {
            if(input_map_name.Text.Equals("") || input_map_name.Text.Equals(null))
            {
                System.Windows.MessageBox.Show("Insert the level name", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
            } else
            {
                string var_level_name = input_map_name.Text;
                // Ruta del archivo .exe
                string exePath = @"thirdtools/converter.exe";

                // Argumentos que deseas pasar al .exe
                string arguments = "-level sdk:" + var_level_name + " -mode le -with_lods";
                System.Windows.MessageBox.Show(exePath + " " + arguments);

                // Crear un nuevo proceso
                ProcessStartInfo startInfo = new ProcessStartInfo
                {
                    FileName = exePath,
                    Arguments = arguments,
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = false
                };

                try
                {
                    // Iniciar el proceso
                    using (Process process = Process.Start(startInfo))
                    {
                        // Leer la salida del proceso
                        using (StreamReader reader = process.StandardOutput)
                        {
                            string result = reader.ReadToEnd();
                            System.Windows.MessageBox.Show(result);
                        }
                    }
                }
                catch (Exception ex)
                {
                    {
                        System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }


                }
            }
            
        }

        private void Button_Click(object sender, RoutedEventArgs e)
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

        private void Button_Click_2(object sender, RoutedEventArgs e)
        {
            
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
            if (string.IsNullOrWhiteSpace(input_ogfobj_input.Text) || string.IsNullOrWhiteSpace(input_ogfobj_output.Text))
            {
                System.Windows.MessageBox.Show("Insert the paths", "Invalid action", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
            else
            {
                // Ruta del archivo .exe
                string exePath = System.IO.Path.GetFullPath(@"thirdtools\converter.exe");
                string inputPath = System.IO.Path.GetFullPath(input_ogfobj_input.Text);
                string outputPath = System.IO.Path.GetFullPath(input_ogfobj_output.Text);
                string[] ogfFiles = Directory.GetFiles(inputPath, "*.ogf").Select(System.IO.Path.GetFileNameWithoutExtension).ToArray();

                foreach (string file in ogfFiles)
                {
                    status_ogfobj.Text += "Converting " + file + "...\n";
                    // Argumentos que deseas pasar al .exe
                    string arguments = "-ogf -object " + inputPath + "\\" + file + ".ogf -out " + outputPath + "\\" + file + ".object";

                    // Crear un nuevo proceso
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
                        // Iniciar el proceso
                        using (Process process = Process.Start(startInfo))
                        {
                            // Leer la salida del proceso
                            using (StreamReader reader = process.StandardOutput)
                            {
                                status_ogfobj.Text += "Done!\n";
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        {
                            System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                    }
                }
                System.Windows.MessageBox.Show("Finished", "Done", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }
    }
}
