# ChargeNET Database Schema (22 Tables)

## Overview
Full database schema for the ChargeNET EV charging recommendation system.  
All tables use **SQL Server** with code‑first EF Core migrations.

---

## Enum Tables (Lookups)

### 1. `Countries`
| Column | Type | Constraints |
|--------|------|-------------|
| `CountryID` | `int` | PK, auto‑increment |
| `Name` | `nvarchar(100)` | NOT NULL, unique |
| `Code` | `nvarchar(3)` | NOT NULL, unique (ISO‑3166‑1 alpha‑3) |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 2. `Cities`
| Column | Type | Constraints |
|--------|------|-------------|
| `CityID` | `int` | PK, auto‑increment |
| `Name` | `nvarchar(100)` | NOT NULL |
| `PostalCode` | `nvarchar(20)` | NOT NULL |
| `CountryID` | `int` | FK → `Countries(CountryID)` |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 3. `Roles`
| Column | Type | Constraints |
|--------|------|-------------|
| `RoleID` | `int` | PK, auto‑increment |
| `Name` | `nvarchar(50)` | NOT NULL, unique |
| `Description` | `nvarchar(200)` | nullable |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 4. `StationStatuses`
| Column | Type | Constraints |
|--------|------|-------------|
| `StationStatusID` | `int` | PK, auto‑increment |
| `Name` | `nvarchar(50)` | NOT NULL, unique |
| `Description` | `nvarchar(200)` | nullable |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 5. `ConnectorTypes`
| Column | Type | Constraints |
|--------|------|-------------|
| `ConnectorTypeID` | `int` | PK, auto‑increment |
| `Name` | `nvarchar(50)` | NOT NULL, unique |
| `Description` | `nvarchar(200)` | nullable |
| `PowerRating` | `decimal(5,2)` | nullable (kW) |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 6. `ReservationStatuses`
| Column | Type | Constraints |
|--------|------|-------------|
| `ReservationStatusID` | `int` | PK, auto‑increment |
| `Name` | `nvarchar(50)` | NOT NULL, unique |
| `Description` | `nvarchar(200)` | nullable |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

---

## Core Entity Tables

### 7. `Users`
| Column | Type | Constraints |
|--------|------|-------------|
| `UserID` | `int` | PK, auto‑increment |
| `FirstName` | `nvarchar(50)` | NOT NULL |
| `LastName` | `nvarchar(50)` | NOT NULL |
| `Email` | `nvarchar(100)` | NOT NULL, unique |
| `PasswordHash` | `nvarchar(500)` | NOT NULL |
| `PhoneNumber` | `nvarchar(20)` | nullable |
| `RoleID` | `int` | FK → `Roles(RoleID)` |
| `CityID` | `int` | nullable, FK → `Cities(CityID)` |
| `Address` | `nvarchar(200)` | nullable |
| `ProfileImage` | `varbinary(max)` | nullable |
| `IsDeleted` | `bit` | NOT NULL, default `0` |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 8. `UserWallet`
| Column | Type | Constraints |
|--------|------|-------------|
| `UserWalletID` | `int` | PK, auto‑increment |
| `UserID` | `int` | FK → `Users(UserID)`, unique (1‑to‑1) |
| `Balance` | `decimal(18,2)` | NOT NULL, default `0.00` |
| `StripeCustomerId` | `nvarchar(100)` | nullable, unique |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 9. `Vehicles`
| Column | Type | Constraints |
|--------|------|-------------|
| `VehicleID` | `int` | PK, auto‑increment |
| `UserID` | `int` | FK → `Users(UserID)` |
| `Make` | `nvarchar(50)` | NOT NULL |
| `Model` | `nvarchar(50)` | NOT NULL |
| `Year` | `int` | nullable |
| `LicensePlate` | `nvarchar(20)` | nullable, unique |
| `BatteryCapacity` | `decimal(5,2)` | nullable (kWh) |
| `ConnectorTypeID` | `int` | nullable, FK → `ConnectorTypes(ConnectorTypeID)` |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 10. `ChargingStations`
| Column | Type | Constraints |
|--------|------|-------------|
| `ChargingStationID` | `int` | PK, auto‑increment |
| `Name` | `nvarchar(100)` | NOT NULL |
| `Address` | `nvarchar(200)` | NOT NULL |
| `CityID` | `int` | FK → `Cities(CityID)` |
| `Latitude` | `decimal(9,6)` | nullable |
| `Longitude` | `decimal(9,6)` | nullable |
| `StatusID` | `int` | FK → `StationStatuses(StationStatusID)` |
| `Image` | `varbinary(max)` | nullable |
| `HasCCS` | `bit` | NOT NULL, default `0` (recommender) |
| `HasCHAdeMO` | `bit` | NOT NULL, default `0` (recommender) |
| `HasType2` | `bit` | NOT NULL, default `0` (recommender) |
| `MaxPowerKW` | `decimal(5,2)` | nullable (recommender) |
| `IsFastCharger` | `bit` | NOT NULL, default `0` (recommender) |
| `HasIndoor` | `bit` | NOT NULL, default `0` (recommender) |
| `Has24hAccess` | `bit` | NOT NULL, default `0` (recommender) |
| `Rating` | `decimal(2,1)` | nullable (0.0–5.0) |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 11. `Connectors`
| Column | Type | Constraints |
|--------|------|-------------|
| `ConnectorID` | `int` | PK, auto‑increment |
| `ChargingStationID` | `int` | FK → `ChargingStations(ChargingStationID)` |
| `ConnectorTypeID` | `int` | FK → `ConnectorTypes(ConnectorTypeID)` |
| `Label` | `nvarchar(50)` | nullable |
| `IsAvailable` | `bit` | NOT NULL, default `1` |
| `PowerKW` | `decimal(5,2)` | NOT NULL |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

**Unique constraint:** (`ChargingStationID`, `ConnectorTypeID`, `Label`)

### 12. `Tariffs`
| Column | Type | Constraints |
|--------|------|-------------|
| `TariffID` | `int` | PK, auto‑increment |
| `Name` | `nvarchar(100)` | NOT NULL, unique |
| `PricePerKWh` | `decimal(10,4)` | NOT NULL |
| `PricePerMinute` | `decimal(10,4)` | nullable |
| `Currency` | `nvarchar(3)` | NOT NULL, default 'EUR' |
| `StartHour` | `time` | nullable |
| `EndHour` | `time` | nullable |
| `IsActive` | `bit` | NOT NULL, default `1` |
| `ValidFrom` | `datetime2` | nullable |
| `ValidTo` | `datetime2` | nullable |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 13. `Reservations`
| Column | Type | Constraints |
|--------|------|-------------|
| `ReservationID` | `int` | PK, auto‑increment |
| `UserID` | `int` | FK → `Users(UserID)` |
| `ChargingStationID` | `int` | FK → `ChargingStations(ChargingStationID)` |
| `ConnectorID` | `int` | nullable, FK → `Connectors(ConnectorID)` |
| `ReservationStart` | `datetime2` | NOT NULL |
| `ReservationEnd` | `datetime2` | NOT NULL |
| `StatusID` | `int` | FK → `ReservationStatuses(ReservationStatusID)` |
| `RejectionReason` | `nvarchar(500)` | nullable |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

**Index:** (`UserID`, `StatusID`)

### 14. `ChargingSessions`
| Column | Type | Constraints |
|--------|------|-------------|
| `ChargingSessionID` | `int` | PK, auto‑increment |
| `ReservationID` | `int` | nullable, FK → `Reservations(ReservationID)` |
| `UserID` | `int` | FK → `Users(UserID)` |
| `ConnectorID` | `int` | FK → `Connectors(ConnectorID)` |
| `StartTime` | `datetime2` | NOT NULL |
| `EndTime` | `datetime2` | nullable |
| `EnergyConsumedKWh` | `decimal(10,2)` | nullable |
| `Cost` | `decimal(18,2)` | nullable |
| `TariffID` | `int` | FK → `Tariffs(TariffID)` |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 15. `FaultReports`
| Column | Type | Constraints |
|--------|------|-------------|
| `FaultReportID` | `int` | PK, auto‑increment |
| `UserID` | `int` | FK → `Users(UserID)` |
| `ChargingStationID` | `int` | FK → `ChargingStations(ChargingStationID)` |
| `ConnectorID` | `int` | nullable, FK → `Connectors(ConnectorID)` |
| `Description` | `nvarchar(1000)` | NOT NULL |
| `ReportedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ResolvedAt` | `datetime2` | nullable |
| `IsResolved` | `bit` | NOT NULL, default `0` |

### 16. `ServiceOrders`
| Column | Type | Constraints |
|--------|------|-------------|
| `ServiceOrderID` | `int` | PK, auto‑increment |
| `FaultReportID` | `int` | nullable, FK → `FaultReports(FaultReportID)` |
| `ChargingStationID` | `int` | FK → `ChargingStations(ChargingStationID)` |
| `AssignedTo` | `nvarchar(100)` | nullable |
| `Status` | `nvarchar(50)` | NOT NULL |
| `Notes` | `nvarchar(1000)` | nullable |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 17. `Transactions`
| Column | Type | Constraints |
|--------|------|-------------|
| `TransactionID` | `int` | PK, auto‑increment |
| `UserID` | `int` | FK → `Users(UserID)` |
| `ChargingSessionID` | `int` | nullable, FK → `ChargingSessions(ChargingSessionID)` |
| `Amount` | `decimal(18,2)` | NOT NULL |
| `Currency` | `nvarchar(3)` | NOT NULL, default 'EUR' |
| `Type` | `nvarchar(50)` | NOT NULL ('Payment', 'Refund', 'TopUp') |
| `Status` | `nvarchar(50)` | NOT NULL ('Pending', 'Completed', 'Failed') |
| `StripePaymentIntentId` | `nvarchar(100)` | nullable, unique |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

### 18. `Invoices`
| Column | Type | Constraints |
|--------|------|-------------|
| `InvoiceID` | `int` | PK, auto‑increment |
| `InvoiceNumber` | `nvarchar(50)` | NOT NULL, unique (auto‑generated) |
| `TransactionID` | `int` | FK → `Transactions(TransactionID)` |
| `UserID` | `int` | FK → `Users(UserID)` |
| `InvoiceDate` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `DueDate` | `datetime2` | NOT NULL |
| `TotalAmount` | `decimal(18,2)` | NOT NULL |
| `Currency` | `nvarchar(3)` | NOT NULL, default 'EUR' |
| `PdfUrl` | `nvarchar(500)` | nullable |
| `Status` | `nvarchar(50)` | NOT NULL, default 'Pending' |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

**Index:** (`UserID`, `Status`)

### 19. `Notifications`
| Column | Type | Constraints |
|--------|------|-------------|
| `NotificationID` | `int` | PK, auto‑increment |
| `UserID` | `int` | FK → `Users(UserID)` |
| `Title` | `nvarchar(200)` | NOT NULL |
| `Message` | `nvarchar(1000)` | NOT NULL |
| `NotificationType` | `nvarchar(50)` | NOT NULL |
| `IsRead` | `bit` | NOT NULL, default `0` |
| `RelatedEntityType` | `nvarchar(50)` | nullable |
| `RelatedEntityID` | `int` | nullable |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |

### 20. `LoyaltyProgram`
| Column | Type | Constraints |
|--------|------|-------------|
| `LoyaltyProgramID` | `int` | PK, auto‑increment |
| `UserID` | `int` | FK → `Users(UserID)`, unique (1‑to‑1) |
| `Points` | `int` | NOT NULL, default `0` |
| `Tier` | `nvarchar(50)` | nullable |
| `TotalChargedKWh` | `decimal(10,2)` | NOT NULL, default `0` |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

---

## Recommendation Tables

### 21. `UserStationProfile`
| Column | Type | Constraints |
|--------|------|-------------|
| `UserStationProfileID` | `int` | PK, auto‑increment |
| `UserID` | `int` | FK → `Users(UserID)` |
| `ChargingStationID` | `int` | FK → `ChargingStations(ChargingStationID)` |
| `VisitedCount` | `int` | NOT NULL, default `0` |
| `TotalRating` | `decimal(2,1)` | nullable (0.0–5.0) |
| `LastVisitedAt` | `datetime2` | nullable |
| `LikeStatus` | `nvarchar(20)` | nullable ('Liked', 'Disliked', null) |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

**Unique constraint:** (`UserID`, `ChargingStationID`)

### 22. `StationVectors`
| Column | Type | Constraints |
|--------|------|-------------|
| `StationVectorID` | `int` | PK, auto‑increment |
| `ChargingStationID` | `int` | FK → `ChargingStations(ChargingStationID)`, unique (1‑to‑1) |
| `HasCCS` | `bit` | NOT NULL, default `0` |
| `HasCHAdeMO` | `bit` | NOT NULL, default `0` |
| `HasType2` | `bit` | NOT NULL, default `0` |
| `MaxPowerKW` | `decimal(5,2)` | nullable |
| `IsFastCharger` | `bit` | NOT NULL, default `0` |
| `HasIndoor` | `bit` | NOT NULL, default `0` |
| `Has24hAccess` | `bit` | NOT NULL, default `0` |
| `Rating` | `decimal(2,1)` | nullable |
| `LastComputedAt` | `datetime2` | nullable |
| `CreatedAt` | `datetime2` | NOT NULL, default `GETUTCDATE()` |
| `ModifiedAt` | `datetime2` | nullable |

---

## Entity Relationships Summary

```
Countries   1──N  Cities
Cities     1──N  Users
Cities     1──N  ChargingStations
Roles      1──N  Users
Users      1──1  UserWallet         (unique FK)
Users      1──1  LoyaltyProgram     (unique FK)
Users      1──N  Vehicles
Users      1──N  Reservations
Users      1──N  ChargingSessions
Users      1──N  Transactions
Users      1──N  Invoices
Users      1──N  Notifications
Users      1──N  FaultReports

ChargingStations  1──N  Connectors
ChargingStations  1──N  Reservations
ChargingStations  1──N  FaultReports
ChargingStations  1──N  ServiceOrders
ChargingStations  1──1  StationVectors

Connectors  1──N  Reservations
Connectors  1──N  ChargingSessions
Connectors  1──N  FaultReports

Reservations  0N──1  ChargingSessions   (nullable FK)
Reservations  N──1  ReservationStatuses

ChargingSessions  N──1  Tariffs
ChargingSessions  0N──1  Transactions     (nullable FK)

Transactions  1──1  Invoices
FaultReports  0N──1  ServiceOrders       (nullable FK)

Users  N──M  ChargingStations  (via UserStationProfile, with extra fields)
```

---

## Implementation Notes (for Entity Classes)

1. **All entities go in** `ChargeNet.Services/Database/` (not in `ChargeNet.Model/Entities/`).
2. **Use data annotations** for simple attributes (e.g., regular columns, `[Key]`, `[Required]`, `[StringLength]`).
3. **Use Fluent API** in `DbContext.OnModelCreating` for composite keys, unique constraints, and cascade behavior.
4. **Navigation properties** – add both `virtual` navigation properties and the FK columns (e.g., `UserID` int + `virtual User User`).
5. **Soft delete** on `Users` only (`IsDeleted` bit). Other tables use hard delete.
6. **Timestamps** – `CreatedAt` should be auto-set on insert, `ModifiedAt` null on insert and set on update.
7. **`Invoice.InvoiceNumber`** – auto-generated in code (e.g., `INV-{year}-{sequential}`), stored as nvarchar(50).
8. **`IMemoryCache`** will be used for recommendation caching – **do not create** a `RecommendationsCache` table.
9. **Enum tables** (Roles, StationStatuses, ConnectorTypes, ReservationStatuses) – use regular entity classes, not C# enums.
10. **`Reservations`** – `ConnectorID` is nullable (reservation can be station-level). `RejectionReason` nullable string.

---

## Documentation File

This file is located at `docs/database-schema.md` in the project repository.  
Last updated: 2025