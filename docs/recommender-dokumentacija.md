# ChargeNET Recommender Documentation

## Scope

This document describes the recommender implementation currently used by:

- `GET /api/recommendations?lat={lat}&lng={lng}&topN={n}`
- Backend classes in `ChargeNet.Services/Recommendation/*`
- Response contract `ChargeNet.Model/Responses/RecommendedStationResponse.cs`

The algorithm is content-based and uses the current user location plus historical charging behavior.

## Request and validation

- Authentication is required (`[Authorize]` on `RecommendationsController`).
- Query params:
  - `lat`: required, range `[-90, 90]`
  - `lng`: required, range `[-180, 180]`
  - `topN`: optional, default `10`, allowed range `[1, 50]`

Validation errors are returned from `RecommendationService.ValidateInput`.

## Candidate station selection

Stations are loaded with `City`, `Status`, `Connectors`, and `StationVector`.
Only active stations with at least one connector are considered:

- `StatusId == 1`
- `station.Connectors.Any()`

Connector preference and radius filtering are applied in fallback steps:

1. Preferred connector + within 50 km
2. Preferred connector + no radius constraint
3. Any connector + within 50 km
4. Any connector + no radius constraint

If all four passes return zero candidates, the endpoint returns an empty list.

## Features used for scoring

Each candidate station is represented by 3 normalized features:

- **Power**: max station power (`StationVector.MaxPowerKW`, fallback `ChargingStation.MaxPowerKW`, fallback max connector power)
- **Price**: resolved current tariff price (`ResolveCurrentPricePerKWh`)
- **Distance**: Haversine distance from user (`CalculateDistanceKm`)

Normalization is min-max clamped to `[0, 1]` with constants:

- `MaxPowerKw = 350`
- `MaxPricePerKWh = 1.50`
- `MaxDistanceKm = 50`

## User profile construction

`UserProfileService.GetProfileAsync` builds:

- preferred connector type (most frequent connector type in completed sessions)
- preferred day/hour slot (most frequent session start slot)
- average normalized power/price/distance over completed sessions

If user has no completed sessions, cold-start profile is used:

- preferred connector from user vehicles (most frequent `ConnectorTypeId`)
- average normalized station features across active stations
- preferred day/hour defaults to current UTC day/hour

## Score formula

For each candidate:

- Euclidean distance in normalized space:
  - `sqrt((uP-sP)^2 + (uC-sC)^2 + (uD-sD)^2)`
- Base score:
  - `baseScore = 1 / (1 + distance)`
- Occupancy penalty:
  - derived from historical session counts in the preferred day/hour slot
  - normalized by observed weeks and connector count
  - capped at `0.5`
- Final score:
  - `score = baseScore * (1 - occupancyPenalty)`

Results are sorted by:

1. `score` descending
2. `rating` descending
3. `distanceKm` ascending

Then truncated to `topN`.

## API output contract

Each recommendation returns:

- station identity and metadata: `Id`, `Name`, `Address`, `CityId`, `CityName`, `StatusId`, `StatusName`
- geo and capability fields: `Latitude`, `Longitude`, `HasCCS`, `HasCHAdeMO`, `HasType2`
- station characteristics: `MaxPowerKW`, `IsFastCharger`, `HasIndoor`, `Has24hAccess`, `Rating`, `ConnectorCount`
- economics and distance: `EstimatedPricePerKWh`, `DistanceKm`
- explainability fields: `BaseScore`, `OccupancyPenalty`, `Score`

`DistanceKm` is rounded to 2 decimals. Score-related values are rounded to 4 decimals.

## Caching and invalidation

Recommendations are cached by:

- user id
- latitude/longitude
- topN

Flow:

- read from cache before recomputation
- write to cache after scoring and sorting
- cache invalidation happens through `IRecommendationCacheService` consumers (for example when session/tariff events are processed)

## Notes and limitations

- The implementation currently uses fixed normalization ranges from `RecommendationConstants`.
- Price selection is heuristic-based (active tariff, time window checks, fast tariff naming, then cheapest fallback).
- Occupancy penalty uses session start times as an availability proxy; it is not a real-time occupancy feed.