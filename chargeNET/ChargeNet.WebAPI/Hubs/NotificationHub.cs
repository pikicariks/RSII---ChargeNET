using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace ChargeNet.WebAPI.Hubs
{
    [Authorize]
    public class NotificationHub : Hub
    {
        public override async Task OnConnectedAsync()
        {
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (userId != null)
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, $"user:{userId}");
            }

            await base.OnConnectedAsync();
        }
    }
}
