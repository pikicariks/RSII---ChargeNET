using ChargeNet.Model.Requests;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargeNet.WebAPI.Controllers
{
    public class ConnectorsController : BaseCRUDController<ConnectorResponse, ConnectorSearchObject, ConnectorInsertRequest, ConnectorUpdateRequest>
    {
        public ConnectorsController(IConnectorService service) : base(service)
        {
        }

        [Authorize(Roles = "Admin")]
        public override Task<IActionResult> Insert([FromBody] ConnectorInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override Task<IActionResult> Update(int id, [FromBody] ConnectorUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}
