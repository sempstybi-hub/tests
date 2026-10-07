using ComePC.DB;
using System.Linq;
using System.Windows.Controls;

namespace ComePC.Pages
{
    /// <summary>
    /// Логика взаимодействия для UserAcc.xaml
    /// </summary>
    public partial class UserAcc : Page
    {
        public UserAcc()
        {
            InitializeComponent();

            using (MaxPCEntities1 context = new MaxPCEntities1())
            {
                var user = context.Users.FirstOrDefault(u => u.Id == Properties.Settings.Default.IdUser);

                NamesAcc_TX.Content = $"{user.First} {user.Name}";
            }
        }

        private void Back_BT_Click(object sender, System.Windows.RoutedEventArgs e)
        {
            NavigationService?.Navigate(new Menu());
        }
    }
}
