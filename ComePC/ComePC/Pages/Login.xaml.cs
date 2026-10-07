using ComePC.DB;
using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace ComePC.Pages
{
    public partial class Login : Page
    {
        public Login(bool isnotUSER)
        {
            InitializeComponent();

            Properties.Settings.Default.IdUser = 0;
            Properties.Settings.Default.Save();

            if (isnotUSER)
            {
                Error_TX.Visibility = Visibility.Visible;
            }
        }

        private void Register_BT_Click(object sender, RoutedEventArgs e)
        {
            NavigationService?.Navigate(new Registers());
        }

        private void Login_BT_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(Login_TXB.Text) || string.IsNullOrWhiteSpace(Pas_PSB.Password))
            {
                MessageBox.Show("Введите логин и пароль", "Ошибка",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            NavigationService?.Navigate(new LoadAcc(Login_TXB.Text, Pas_PSB.Password));
        }
    }
}