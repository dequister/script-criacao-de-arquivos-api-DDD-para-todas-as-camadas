param(
    [string]$caminhoPai,
    [string]$entidadeNome,
    [string]$nameSpace,
    [string[]]$metodos
)

#$caminhoPai = "C:\Work\Meus projetos\ApiPedidos\"
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

# Gera os métodos para as interfaces
$method = ""
if ($metodos) {
    $metodos | ForEach-Object {
        $method += "        $_;`n"
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

        // Métodos do controller
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

        // Métodos do AppService
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

        // Métodos do Service
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

namespace $nameSpace.Data.SqlServer.Repository
{
    public class $entidadeNome`Repository : I$entidadeNome`Repository
    {
        private readonly DbBaseOppContext _dbBaseOppContext;

        public $entidadeNome`Repository(DbBaseOppContext dbBaseOppContext)
        {
            _dbBaseOppContext = dbBaseOppContext;
        }

        // Métodos do Repositório
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
$method    }
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
$method    }
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
$method    }
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
