using ComePC.DB;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace ComePC.Pages
{
    public partial class Menu : Page
    {
        public class CP
        {
            // готовая картинка для биндинга
            public ImageSource ImagePath { get; set; }
            public string Name { get; set; }
            public string Info { get; set; }
            public decimal Price { get; set; }
        }

        public Menu()
        {
            InitializeComponent();

            using (MaxPCEntities1 context = new MaxPCEntities1())
            {
                var items = context.Computer
                    .Select(c => new
                    {
                        c.Name,
                        c.Info,
                        c.Price,
                        c.Baner      
                    })
                    .ToList()
                    .Select(c => new CP
                    {
                        Name = c.Name,
                        Info = c.Info,
                        Price = c.Price,
                        ImagePath = Base64ToImage(c.Baner)
                    })
                    .ToList();

                DataContext = new { Items = items };
            }
        }

        // base64 -> ImageSource
        private static BitmapImage Base64ToImage(string base64)
        {
            if (string.IsNullOrWhiteSpace(base64)) return null;

            try
            {
                byte[] bytes = Convert.FromBase64String(base64);
                var image = new BitmapImage();
                using (var ms = new MemoryStream(bytes))
                {
                    image.BeginInit();
                    image.CacheOption = BitmapCacheOption.OnLoad;
                    image.StreamSource = ms;
                    image.EndInit();
                }
                image.Freeze();
                return image;
            }
            catch
            {
                return null;
            }
        }

        private void Loguot_BT_Click(object sender, RoutedEventArgs e)
        {
            Properties.Settings.Default.IdUser = 0;
            Properties.Settings.Default.Save();
            NavigationService?.Navigate(new Login(false));
        }

        private void Acc_BT_Click(object sender, RoutedEventArgs e)
        {
            NavigationService?.Navigate(new UserAcc());
        }
    }
}