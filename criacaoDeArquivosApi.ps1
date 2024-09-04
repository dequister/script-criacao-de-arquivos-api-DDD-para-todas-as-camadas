param(
    [string]$entityName,
    [string]$entityNameSpace
)

$caminhoPai = "C:\Work\Meus projetos\ApiPedidos\"
# Diretórios base para cada camada
$controllerDir = "$caminhoPai`pedidos-api\Controllers"
$appServiceDir = "$caminhoPai$entityNameSpace.Application\AppService"
$serviceDir = "$caminhoPai$entityNameSpace.Domain\Service"
$repositoryDir = "$caminhoPai$entityNameSpace.Data.SqlServer\Repository"

# Criar arquivos de interface
$interfaceAppService = "$caminhoPai$entityNameSpace.Application\Interface\I$entityName`AppService.cs"
$interfaceService = "$caminhoPai$entityNameSpace.Domain\Interface\Service\I$entityName`Service.cs"
$interfaceRepository = "$caminhoPai$entityNameSpace.Domain\Interface\Repository\I$entityName`Repository.cs"
 
# Criar arquivos de implementação
$controller = "$controllerDir\$entityName`Controller.cs"
$appService = "$appServiceDir\$entityName`AppService.cs"
$service = "$serviceDir\$entityName`Service.cs"
$repository = "$repositoryDir\$entityName`Repository.cs"

# Conteúdo base para cada arquivo
$controllerContent = @"
using Microsoft.AspNetCore.Mvc;
using $entityNameSpace.Application.AppService;
using $entityNameSpace.Application.Interface;
using $entityNameSpace.Models;

namespace $entityNameSpace.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class $entityName`Controller : ControllerBase
    {
        private readonly I$entityName`AppService _$entityName`AppService;
        private readonly ILogger<$entityName`Controller> _logger;

        public $entityName`Controller(I$entityName`AppService $entityName`AppService, ILogger<$entityName`Controller> logger)
        {
            _$entityName`AppService = $entityName`AppService;
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
using $entityNameSpace.Application.Interface;
using $entityNameSpace.Domain.Interface.Service;
using $entityNameSpace.Models;

namespace $entityNameSpace.Application.AppService
{
    public class $entityName`AppService : I$entityName`AppService
    {
        private readonly I$entityName`Service _$entityName`Service;

        public $entityName`AppService(I$entityName`Service $entityName`Service)
        {
            _$entityName`Service = $entityName`Service;
        }

        // Métodos do AppService
    }
}
"@

$serviceContent = @"
using $entityNameSpace.Domain.Interface.Repository;
using $entityNameSpace.Domain.Interface.Service;
using $entityNameSpace.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace $entityNameSpace.Domain.Service
{
    public class $entityName`Service : I$entityName`Service
    {
        private readonly I$entityName`Repository _$entityName`Repository;

        public $entityName`Service(I$entityName`Repository $entityName`Repository)
        {
            _$entityName`Repository = $entityName`Repository;
        }

        // Métodos do Service
    }
}
"@

$repositoryContent = @"
using $entityNameSpace.Data.SqlServer.Context;
using $entityNameSpace.Domain.Interface.Repository;
using $entityNameSpace.Models;
using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace $entityNameSpace.Data.SqlServer.Repository
{
    public class $entityName`Repository : I$entityName`Repository
    {
        private readonly DbBaseOppContext _dbBaseOppContext;

        public $entityName`Repository(DbBaseOppContext dbBaseOppContext)
        {
            _dbBaseOppContext = dbBaseOppContext;
        }

        // Métodos do Repositório
    }
}
"@

$appServiceInterfaceContent = @"
using $entityNameSpace.Models;

namespace $entityNameSpace.Application.Interface
{
    public interface I$entityName`AppService
    {
        // Assinaturas dos métodos do AppService
    }
}
"@

$serviceInterfaceContent = @"
using $entityNameSpace.Models;

namespace $entityNameSpace.Domain.Interface.Service
{
    public interface I$entityName`Service
    {
        // Assinaturas dos métodos do Service
    }
}
"@

$repositoryInterfaceContent = @"
using $entityNameSpace.Models;

namespace $entityNameSpace.Domain.Interface.Repository
{
    public interface I$entityName`Repository
    {
        // Assinaturas dos métodos do Repositório
    }
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

Write-Host "Arquivos criados com sucesso para a entidade: $entityName"
