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
    var fqdn = Environment.GetEnvironmentVariable("MSSQL_FQDN");
    var databaseName = Environment.GetEnvironmentVariable("MSSQL_DB_NAME");

    Console.WriteLine($"FQDN: {fqdn}");
    Console.WriteLine($"Database Name: {databaseName}");

    SqlConnection connection = new SqlConnection($"Server=tcp:{fqdn};Database={databaseName};Authentication=Active Directory Default;TrustServerCertificate=True");

    // Open the SQL connection
    connection.Open();

    return new IcecreamResponse()
    {
      Value = "App Services was able to connect to the database. Here is your icecream: 🍦"
    };
  }
}
