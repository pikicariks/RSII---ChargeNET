"# ChargeNET Project Context

## Project Overview
ChargeNET – RSII Seminar project. A content‑based recommendation system for EV charging stations with a full backend (.NET 8, EF Core, SQL Server, RabbitMQ, Stripe) and a planned Flutter frontend.

---

## Current Status (End of Session 1)

### Phase 1 – Setup: ✅ COMPLETE
- [x] Docker Compose (SQL Server 2022 + RabbitMQ 3 Management) configured and running
- [x] Solution structure with 5 projects created
- [x] All NuGet packages installed and compatible with `net8.0`
- [x] Git repository initialized and pushed to GitHub (`https://github.com/pikicariks/RSII---ChargeNET.git`)
- [x] `.gitkeep` files in all empty subfolders (commit `aea814f`)
- [x] `.gitignore` created at root
- [x] Database schema documented in `docs/database-schema.md`
- [x] Project context documented in `docs/project-context.md`

### Next Step (Start of Session 2): 🔴 **Implement Entity Classes**
Follow the instructions in `docs/database-schema.md` to:
1. Create all 22 C# entity classes in `ChargeNet.Services/Database/`
2. Create `ChargeNetDbContext` with `DbSet` properties and fluent configuration
3. Add connection string to `ChargeNet.WebAPI/appsettings.json`
4. Register DbContext in `ChargeNet.WebAPI/Program.cs`
5. Create seed class `ChargeNet.Services/Database/ChargeNetSeed.cs`
6. Run initial migration
7. Implement base services, exceptions, filters, JWT

---

## Solution Structure (5 Projects)

### 1. `ChargeNet.Model` (Class Library – `net8.0`)
**Path:** `ChargeNet.Model/`
**Already has:** FluentValidation 12.1.1

| Folder | Purpose |
|--------|---------|
| `Entities/` | DTOs/Models (empty – entities are in Services project) |
| `Requests/` | Request DTOs |
| `Responses/` | Response DTOs |
| `SearchObjects/` | Filter/search DTOs |
| `Access/` | Access manager interfaces/models |
| `Exceptions/` | Custom exception classes |
| `Enums/` | C# enums (where needed) |

### 2. `ChargeNet.Services` (Class Library – `net8.0`)
**Path:** `ChargeNet.Services/`
**References:** `ChargeNet.Model`
**NuGet packages:** EF Core 9.0.15 (SqlServer, Design), FluentValidation 12.1.1, Microsoft.Extensions.Caching.Abstractions 9.0.15

| Folder | Purpose |
|--------|---------|
| `Database/` | **← Entity classes and DbContext go here** |
| `Migrations/` | EF Core migrations (generated) |
| `Validators/` | FluentValidation validators |
| `StateMachines/` | State machine logic for reservations |
| `Recommendation/` | Content‑based recommendation algorithm |
| `Interfaces/` | Service interfaces |

### 3. `ChargeNet.WebAPI` (Web API – `net8.0`)
**Path:** `ChargeNet.WebAPI/`
**References:** `ChargeNet.Model`, `ChargeNet.Services`, `ChargeNet.Common.Services`
**NuGet packages:** JwtBearer 8.0.15, RabbitMQ.Client 7.1.2, Stripe.net 48.11.0, Swashbuckle 7.4.1

| Folder | Purpose |
|--------|---------|
| `Controllers/` | API controllers (including base) |
| `Filters/` | Exception filter, validation filter |
| `Middleware/` | Custom middleware |
| `Services/` | JWT access manager, DI registration |

### 4. `ChargeNet.Common.Services` (Class Library – `net8.0`)
**Path:** `ChargeNet.Common.Services/`
**References:** None

| Folder | Purpose |
|--------|---------|
| `CryptoService/` | Password hashing, crypto utilities |

### 5. `ChargeNet.Worker` (Worker Service – `net8.0`)
**Path:** `ChargeNet.Worker/`
**References:** `ChargeNet.Model`, `ChargeNet.Services`
**File:** `Worker.cs` (background service)

| Purpose |
|---------|
| RabbitMQ consumer for async invoice PDF generation |

---

## Infrastructure

### Docker Compose
**File:** `ChargeNet/docker-compose.yml`

```yaml
services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=Passw0rd!
    ports:
      - '1433:1433'

  rabbitmq:
    image: rabbitmq:3-management
    environment:
      - RABBITMQ_DEFAULT_USER=guest
      - RABBITMQ_DEFAULT_PASS=guest
    ports:
      - '5672:5672'
      - '15672:15672'
```

### Git Repository
- **Local:** `RSII-seminarski`
- **Remote:** `https://github.com/pikicariks/RSII---ChargeNET.git`
- **Last commit:** `aea814f` (added .gitkeep files to all empty subdirectories)
- **Branch:** main (or master)

---

## NuGet Packages (Installed & Compatible)

| Package | Version | Installed In |
|---------|---------|-------------|
| `Microsoft.EntityFrameworkCore` | 9.0.15 | Services |
| `Microsoft.EntityFrameworkCore.SqlServer` | 9.0.15 | Services |
| `Microsoft.EntityFrameworkCore.Design` | 9.0.15 | Services |
| `Microsoft.Extensions.Caching.Abstractions` | 9.0.15 | Services |
| `FluentValidation` | 12.1.1 | Model, Services |
| `Microsoft.AspNetCore.Authentication.JwtBearer` | 8.0.15 | WebAPI |
| `Swashbuckle.AspNetCore` | 7.4.1 | WebAPI |
| `Stripe.net` | 48.11.0 | WebAPI |
| `RabbitMQ.Client` | 7.1.2 | WebAPI |

---

## Database Schema Reference

**File:** `docs/database-schema.md`

Contains:
- 22 tables with full column definitions, types, constraints
- Entity relationships diagram
- Implementation notes for entity classes

Key decisions documented in schema:
1. Entities go in `ChargeNet.Services/Database/` (not Model)
2. Use data annotations + Fluent API in DbContext
3. Soft delete on `Users` only (`IsDeleted`)
4. `IMemoryCache` for recommendations (no DB cache table)
5. `Invoice.InvoiceNumber` auto-generated in code
6. `NotificationType` is an nvarchar column
7. `Reservations.ConnectorID` nullable, `RejectionReason` nullable
8. Images as `byte[]`
9. Enum tables = regular entity classes

---

## Resolved Issues from Setup

| Issue | Resolution |
|-------|-----------|
| .NET 9 not supported by professor's SDK | Retargeted all projects to `net8.0` |
| JwtBearer 9.0.15 incompatible with .NET 8 | Downgraded to 8.0.15 |
| PowerShell `&&` operator not available | Use `;` or run commands separately |
| Docker-compose double‑escaped quotes | Replaced with single quotes |
| Git `refusing to merge unrelated histories` | Used `--allow-unrelated-histories` pull |
| Empty subfolders not tracked by Git | Added `.gitkeep` files to all empty directories |

---

## What's Left to Implement (Prioritized)

### Phase 2 – Core Infrastructure (NEXT SESSION)
1. **Entity classes** (22 classes) → `ChargeNet.Services/Database/`
2. **ChargeNetDbContext** → `ChargeNet.Services/Database/`
3. **Connection string** → `ChargeNet.WebAPI/appsettings.json`
4. **Register DbContext** → `ChargeNet.WebAPI/Program.cs`
5. **Seed class** → `ChargeNet.Services/Database/ChargeNetSeed.cs`
6. **Initial migration** → `dotnet ef migrations add InitialCreate`

### Phase 3 – Services & API
7. Base read service (`BaseReadService<T>`)
8. Base CRUD service (`BaseCRUDService<T>`)
9. Custom exceptions (`NotFoundException`, `BusinessException`)
10. Exception filter
11. JWT authentication (AccessManager)
12. User CRUD controller

### Phase 4 – Business Logic
13. Content‑based recommendation service (Euclidean distance, min‑max normalisation, re‑ranking)
14. Stripe webhook integration (payment verification, wallet update)
15. RabbitMQ consumer (async invoice PDF generation)
16. SignalR hub (real‑time notifications)

### Phase 5 – Frontend (Future)
17. Flutter mobile app (Android APK)
18. Flutter desktop app (Windows EXE)

---

## Key People & Context

- **Professor:** RSII seminar – follows specific patterns (base services, DbContext in Services project)
- **Student:** `pikicariks` on GitHub
- **Project type:** Content‑based recommendation system (not collaborative filtering)
- **Reference project:** Professor's eCommerce project (similar folder structure, base classes)

---

## File: docs/database-schema.md
Contains the full 22‑table schema. In the next session, say:
> *\"Follow the schema in docs/database-schema.md and implement the entity classes in ChargeNet.Services/Database/, then create the ChargeNetDbContext. Start with all 22 entities.\"*
"