using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json; // Install-Package Newtonsoft.Json

namespace SocketTest
{
    internal class Program
    {
        class user
        {
            public string username;
            public string password;         
        }

        static async Task Main()
        {
            const string url = "http://192.168.16.18:3636/{0}?api={1}&data={2}";

            var u = new user();
            u.username = "aaaa";
            u.password = "123456";
            var json = JsonConvert.SerializeObject(u);
            var login = string.Format(url, "login", "login", json);

            var u2 = new user();
            u2.username = "bbbb";
            u2.password = "123456";
            json = JsonConvert.SerializeObject(u2);
            var reg = string.Format(url, "login", "register", json);

            login = string.Format(url, "login", "login", JsonConvert.SerializeObject(u2));

            var client = new HttpClient();
            var request = new HttpRequestMessage(HttpMethod.Post, login);
            var response = await client.SendAsync(request);
            var content = await response.Content.ReadAsStringAsync();
            Console.WriteLine(content);
        }

        /*static void Main(string[] args)
        {
            Net net = new Net();
            net.OnConnect();

            var line = Console.ReadLine();
            while (!string.IsNullOrEmpty(line))
            {
                if (line.Length > 5)
                {
                    net.SendMsg(line);
                }
                line = Console.ReadLine();
            }


            net.Disconnect();
            Console.ReadLine();
        }*/
    }
}