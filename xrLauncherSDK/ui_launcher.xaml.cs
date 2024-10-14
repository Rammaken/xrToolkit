using System.Diagnostics;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Xml;

namespace xrLauncherSDK
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class ui_launcher : Window
    {
        public ui_launcher()
        {
            InitializeComponent();
            combo_workspace.Items.Clear();
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
                    combo_workspace.Items.Add(workspaceName);
                }
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btn_actor_Click(object sender, RoutedEventArgs e)
        {
            string editorBin = System.IO.Path.GetFullPath(@"bin\designer\mixed\ActorEditor.exe");
            string arguments = "-nocache -dsound -editor";

            try
            {
                ProcessStartInfo startInfo = new ProcessStartInfo(editorBin, arguments);
                startInfo.UseShellExecute = false;

                Process process = Process.Start(startInfo);
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}