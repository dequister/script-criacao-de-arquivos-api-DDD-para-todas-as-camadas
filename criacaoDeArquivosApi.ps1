param(
    [string]$caminhoPai,
    [string]$entidadeNome,
    [string]$nameSpace,
    [array]$metodos
)

# Diretórios base para cada camada
$controllerDir = "$caminhoPai`pedidos-api\Controllers"
$appServiceDir = "$caminhoPai$nameSpace.Application\AppService"
$serviceDir = "$caminhoPai$nameSpace.Domain\Service"
$repositoryDir = "$caminhoPai$nameSpace.Data.SqlServer\Repository"

# Criar arquivos de interface
$interfaceAppService = "$caminhoPai$nameSpace.Application\Interface\I$entidadeNome`AppService.cs"
$interfaceService = "$caminhoPai$nameSpace.Domain\Interface\Service\I$entidadeNome`Service.cs"
$interfaceRepository = "$caminhoPai$nameSpace.Domain\Interface\Repository\I$entidadeNome`Repository.cs"
 
# Criar arquivos de implementação
$controller = "$controllerDir\$entidadeNome`Controller.cs"
$appService = "$appServiceDir\$entidadeNome`AppService.cs"
$service = "$serviceDir\$entidadeNome`Service.cs"
$repository = "$repositoryDir\$entidadeNome`Repository.cs"

# Gera os métodos para as interfaces e implementações
$interfaceMethods = ""
$controllerMethods = ""
$appServiceMethods = ""
$serviceMethods = ""
$repositoryMethods = ""

if ($metodos) {
    foreach ($metodo in $metodos) {
        $nomeMetodo = $metodo.Nome
        $tipoHttp = $metodo.Http
        $proc = $metodo.Proc
        $parametroTipo = $metodo.ParametroTipo
        $parametroNome = $metodo.ParametroNome
        $paramentroRetornoTipo = $metodo.ParametroRetornoTipo

        # Adiciona o método na interface
        $interfaceMethods += "        Task<$paramentroRetornoTipo> $nomeMetodo($parametroTipo $parametroNome);`n"

        # Define o atributo HTTP e a anotação correta (se necessária)
        $httpAttribute = "[Http$tipoHttp(`"[action]`")]"
        $parametroComAnotacao = ""
        if ($tipoHttp -eq "Post" -or $tipoHttp -eq "Put") {
            $parametroComAnotacao = "[FromBody] $parametroTipo $parametroNome"
        } elseif ($tipoHttp -eq "Get" -or $tipoHttp -eq "Delete") {
            $parametroComAnotacao = "[FromQuery] $parametroTipo $parametroNome"
          elseif ($tipoHttp -eq "")
            $parametroComAnotacao = ""
        }

        # Controller
        $controllerMethods += @"
        $httpAttribute
        public async Task<IActionResult> $nomeMetodo($parametroComAnotacao)
        {
            return Ok(await this._$entidadeNome`AppService.$nomeMetodo($parametroNome));
        }
"@

        # AppService
        $appServiceMethods += @"
        public async Task<$paramentroRetornoTipo> $nomeMetodo($parametroTipo $parametroNome)
        {
            return await this._$entidadeNome`Service.$nomeMetodo($parametroNome);
        }
"@

        # Service
        $serviceMethods += @"
        public async Task<$paramentroRetornoTipo> $nomeMetodo($parametroTipo $parametroNome)
        {
            return await this._$entidadeNome`Repository.$nomeMetodo($parametroNome);
        }
"@

        # Repository
        $repositoryMethods += @"
        public async Task<$paramentroRetornoTipo> $nomeMetodo($parametroTipo $parametroNome)
        {
            var p = this.Parametros($parametroNome);

            try
            {
                using (SqlConnection connection = this._dbOppContext._connection)
                    await connection.ExecuteAsync(`"$proc`", p, commandType: CommandType.StoredProcedure, commandTimeout: this._dbOppContext._timeOut);

                return p.Get<$paramentroRetornoTipo>(`"@inSuccess`");
            }
            catch (Exception ex)
            {
                throw new Exception(`"Erro: `", ex);
            }
        }
"@
    }
}

# Conteúdo base para cada arquivo
$controllerContent = @"
using Microsoft.AspNetCore.Mvc;
using $nameSpace.Application.AppService;
using $nameSpace.Application.Interface;
using $nameSpace.Models;

namespace $nameSpace.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class $entidadeNome`Controller : ControllerBase
    {
        private readonly I$entidadeNome`AppService _$entidadeNome`AppService;
        private readonly ILogger<$entidadeNome`Controller> _logger;

        public $entidadeNome`Controller(I$entidadeNome`AppService $entidadeNome`AppService, ILogger<$entidadeNome`Controller> logger)
        {
            _$entidadeNome`AppService = $entidadeNome`AppService;
            _logger = logger;
        }

$controllerMethods
    }
}
"@

$appServiceContent = @"
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using $nameSpace.Application.Interface;
using $nameSpace.Domain.Interface.Service;
using $nameSpace.Models;

namespace $nameSpace.Application.AppService
{
    public class $entidadeNome`AppService : I$entidadeNome`AppService
    {
        private readonly I$entidadeNome`Service _$entidadeNome`Service;

        public $entidadeNome`AppService(I$entidadeNome`Service $entidadeNome`Service)
        {
            _$entidadeNome`Service = $entidadeNome`Service;
        }

$appServiceMethods
    }
}
"@

$serviceContent = @"
using $nameSpace.Domain.Interface.Repository;
using $nameSpace.Domain.Interface.Service;
using $nameSpace.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace $nameSpace.Domain.Service
{
    public class $entidadeNome`Service : I$entidadeNome`Service
    {
        private readonly I$entidadeNome`Repository _$entidadeNome`Repository;

        public $entidadeNome`Service(I$entidadeNome`Repository $entidadeNome`Repository)
        {
            _$entidadeNome`Repository = $entidadeNome`Repository;
        }

$serviceMethods
    }
}
"@

$repositoryContent = @"
using $nameSpace.Data.SqlServer.Context;
using $nameSpace.Domain.Interface.Repository;
using $nameSpace.Models;
using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using System.Data.SqlClient;

namespace $nameSpace.Data.SqlServer.Repository
{
    public class $entidadeNome`Repository : I$entidadeNome`Repository
    {
        private readonly DbOppContext _dbOppContext;

        public $entidadeNome`Repository(DbOppContext dbOppContext)
        {
            _dbOppContext = $dbOppContext;
        }

$repositoryMethods
    }
}
"@

$appServiceInterfaceContent = @"
using $nameSpace.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace $nameSpace.Application.Interface
{
    public interface I$entidadeNome`AppService
    {
$interfaceMethods    }
}
"@

$serviceInterfaceContent = @"
using $nameSpace.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace $nameSpace.Domain.Interface.Service
{
    public interface I$entidadeNome`Service
    {
$interfaceMethods    }
}
"@

$repositoryInterfaceContent = @"
using $nameSpace.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace $nameSpace.Domain.Interface.Repository
{
    public interface I$entidadeNome`Repository
    {
$interfaceMethods    }
}
"@

# Criação dos arquivos com o conteúdo
@($interfaceAppService, $interfaceService, $interfaceRepository, $controller, $appService, $service, $repository) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType File -Path $_
    }
}

Set-Content -Path $interfaceAppService -Value $appServiceInterfaceContent
Set-Content -Path $interfaceService -Value $serviceInterfaceContent
Set-Content -Path $interfaceRepository -Value $repositoryInterfaceContent

Set-Content -Path $controller -Value $controllerContent
Set-Content -Path $appService -Value $appServiceContent
Set-Content -Path $service -Value $serviceContent
Set-Content -Path $repository -Value $repositoryContent

Write-Host "Arquivos criados com sucesso para a entidade: $entidadeNome"
