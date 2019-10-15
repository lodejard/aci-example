using Microsoft.AspNetCore.Mvc;

namespace HelloWorld.Controllers
{
    [Route("-")]
    public class ProbeController : Controller
    {
        [HttpGet("ready")]
        public string Ready()
        {
            return "OK";
        }

        [HttpGet("alive")]
        public string Alive()
        {
            return "OK";
        }
    }
}
