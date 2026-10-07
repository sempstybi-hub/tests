using ComePC.DB;
using Microsoft.Win32;
using System;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media.Imaging;

namespace ComePC.Pages
{
    public partial class Registers : Page
    {
        // base64 выбранного, но ещё не сохранённого аватара
        private string _selectedAvatarBase64;

        public Registers()
        {
            InitializeComponent();
        }

        // === Выбор фото ===
        private void AvatarFolder_BT_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new OpenFileDialog
            {
                Title = "Выберите изображение",
                Filter = "Изображения|*.png;*.jpg;*.jpeg"
            };

            if (dialog.ShowDialog() != true) return;

            string ext = Path.GetExtension(dialog.FileName).ToLower();
            if (ext != ".png" && ext != ".jpg" && ext != ".jpeg")
            {
                MessageBox.Show("Только png / jpg / jpeg");
                return;
            }

            // читаем файл и конвертируем в base64
            byte[] bytes = File.ReadAllBytes(dialog.FileName);
            _selectedAvatarBase64 = Convert.ToBase64String(bytes);

            // Превью
            Avatar_IMG.Source = Base64ToImage(_selectedAvatarBase64);
        }

        // === Регистрация ===
        private void Register_BT_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(Name_TXB.Text) ||
                string.IsNullOrWhiteSpace(First_TXB.Text) ||
                string.IsNullOrWhiteSpace(Login_TXB.Text) ||
                string.IsNullOrWhiteSpace(Pas_PSB.Password))
            {
                MessageBox.Show("Заполните обязательные поля");
                return;
            }

            if (Pas_PSB.Password != Pas2_PSB.Password)
            {
                MessageBox.Show("Пароли не совпадают");
                return;
            }

            try
            {
                using (MaxPCEntities1 context = new MaxPCEntities1())
                {
                    if (context.Users.Any(u => u.Login == Login_TXB.Text))
                    {
                        MessageBox.Show("Такой логин уже занят");
                        return;
                    }

                    long phone = 0;
                    long.TryParse(Phone_TXB.Text, out phone);

                    var user = new Users
                    {
                        Name = Name_TXB.Text,
                        First = First_TXB.Text,
                        Login = Login_TXB.Text,
                        Password = Pas_PSB.Password,
                        Email = Email_TXB.Text,
                        IsTrueEmail = EmailTrue_CHB.IsChecked == true,
                        Phone = phone,
                        IsTruePhone = PhoneTrue_CHB.IsChecked == true,
                        Avatar = _selectedAvatarBase64 // строка base64
                    };

                    context.Users.Add(user);
                    context.SaveChanges();
                }

                NavigationService?.Navigate(new LoadAcc(Login_TXB.Text, Pas_PSB.Password));
            }
            catch (System.Data.Entity.Validation.DbEntityValidationException ex)
            {
                var msg = string.Join("\n",
                    ex.EntityValidationErrors
                      .SelectMany(err => err.ValidationErrors)
                      .Select(v => $"{v.PropertyName}: {v.ErrorMessage}"));
                MessageBox.Show(msg);
            }
        }

        // === Вспомогательный метод: base64 -> BitmapImage ===
        public static BitmapImage Base64ToImage(string base64)
        {
            if (string.IsNullOrEmpty(base64)) return null;

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

        private void Login_BT_Click(object sender, RoutedEventArgs e)
        {
            NavigationService?.Navigate(new Login(false));
        }
    }
}