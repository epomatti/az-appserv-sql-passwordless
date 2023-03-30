using Microsoft.AspNetCore.Mvc;

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
    return new IcecreamResponse()
    {
      Value = "Test"
    };
  }
}
