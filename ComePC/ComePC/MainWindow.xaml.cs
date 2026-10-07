using MahApps.Metro.Controls;

namespace ComePC
{
    public partial class MainWindow : MetroWindow
    {
        public MainWindow()
        {
            InitializeComponent();
            From.NavigationService.Navigate(new Pages.Login(false));
        }
    }
}
