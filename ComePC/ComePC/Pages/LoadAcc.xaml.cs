using ComePC.DB;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Controls;

namespace ComePC.Pages
{
    public partial class LoadAcc : Page
    {
        public LoadAcc(string log, string pas)
        {
            InitializeComponent();
            Loaded += async (s, e) => await CheckUserAsync(log, pas);
        }

        private async Task CheckUserAsync(string log, string pas)
        {
            await Task.Delay(1000);

            using (var context = new MaxPCEntities1())
            {
                var user = context.Users.FirstOrDefault(u => u.Login == log && u.Password == pas);

                if (user == null)
                {
                    NavigationService?.Navigate(new Login(true));
                    return;
                }

                Properties.Settings.Default.IdUser = user.Id;
                Properties.Settings.Default.Save();

                Info.Content += $"{user.First} {user.Name}";
            }

            await Task.Delay(1000);
            NavigationService?.Navigate(new Menu());
        }
    }
}