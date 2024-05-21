using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace webapi;

[ApiController]
[Route("/api/[controller]")]
public class IcecreamController : ControllerBase
{

  private readonly ILogger<IcecreamController> _logger;

  public IcecreamController(ILogger<IcecreamController> logger)
  {
    _logger = logger;
  }

  [HttpGet(Name = "GetIcecream")]
  public IcecreamResponse Get()
  {
    var configFile = Environment.GetEnvironmentVariable("CONFIG_FILE");

    if (String.IsNullOrEmpty(configFile))
    {
      UseEnvs();
    }
    else
    {
      UseConfigFile(configFile);
    }
    return new IcecreamResponse()
    {
      Value = "App Services was able to connect to the database. Here is your icecream: 🍦"
    };
  }

  protected void UseEnvs()
  {
    var fqdn = Environment.GetEnvironmentVariable("MSSQL_FQDN");
    var databaseName = Environment.GetEnvironmentVariable("MSSQL_DB_NAME");

    Console.WriteLine($"FQDN: {fqdn}");
    Console.WriteLine($"Database Name: {databaseName}");

    SqlConnection connection = new SqlConnection($"Server=tcp:{fqdn};Database={databaseName};Authentication=Active Directory Default;TrustServerCertificate=True");

    // Open the SQL connection
    connection.Open();
  }

  protected void UseConfigFile(String configFile)
  {
    Console.WriteLine("Using config file");

    var config = new ConfigurationBuilder()
      .AddJsonFile(configFile)
      .Build();

    var fqdn = config["mssqlServer"];
    var databaseName = config["mssqlDatabase"];
    var appId = config["appId"];
    var secret = config["appPassword"];

    string ConnectionString = $"Server=tcp:{fqdn}; Authentication=Active Directory Service Principal; Encrypt=True; Database={databaseName}; User Id={appId}; Password={secret}";
    // Console.WriteLine(ConnectionString);

    SqlConnection connection = new SqlConnection(ConnectionString);

    // Open the SQL connection
    connection.Open();
  }
}
