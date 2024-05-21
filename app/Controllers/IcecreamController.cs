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
    var serverName = "sqlspassworldless789";
    var databaseName = "sqldbpassworldless789";

    SqlConnection connection = new SqlConnection($"Server=tcp:{serverName}.database.windows.net;Database={databaseName};Authentication=Active Directory Default;TrustServerCertificate=True");

    // Open the SQL connection
    connection.Open();

    return new IcecreamResponse()
    {
      Value = "App Services was able to connect to the database. Here is your icecream: 🍦"
    };
  }
}
