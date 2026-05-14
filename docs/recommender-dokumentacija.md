# ChargeNET Recommendation System Documentation

## Recommender System Overview

The **ChargeNET recommendation engine** uses **content-based filtering** to suggest charging stations to users. The system learns from a user's historical charging behavior and compares station attributes to deliver personalized, relevant recommendations.

---

## 1. Core Concept: Representing Stations as Vectors

Each charging station is represented as a vector of three key numeric attributes:

| Attribute | Symbol | Description | Unit | Example |
|-----------|--------|-------------|------|---------|
| Charging power | \( P \) | Maximum power output of the connector | kW | 50, 150, 350 |
| Price per kWh | \( C \) | Current tariff price for the user's session time | € / kWh | 0.15, 0.30 |
| Distance deviation | \( D \) | How far the station is from the user's typical route or current location | km | 2, 15, 45 |

Additionally, each station has a **categorical attribute** – **connector type** (Type 2, CCS, CHAdeMO) – which is used as a **mandatory filter** (a station without a matching connector is excluded from recommendations).

Thus, the vector representation of a station \( S \) is:

\[
\vec{S} = (P, C, D)
\]

---

## 2. Normalization

All three numeric attributes are **normalized** to a [0, 1] range using **min-max scaling** to ensure equal weight during similarity computation.

\[
\text{norm}(x) = \frac{x - x_{\min}}{x_{\max} - x_{\min}}
\]

- For **power** and **price**, the min/max values are taken from all stations in the system.
- For **distance**, the min is 0 (same location as user) and the max is a configurable radius (e.g., 50 km).

Normalized values are **precomputed** and stored in the `StationVectors` table for efficient retrieval.

---

## 3. User Profile Vector

A **user profile** is built from their past charging sessions. For each session, we extract the normalized attributes of the station used. The profile vector \( \vec{U} \) is the **weighted average** of those session vectors:

\[
\vec{U} = \frac{\sum_{i=1}^{n} w_i \cdot \vec{S}_i}{\sum_{i=1}^{n} w_i}
\]

Where:
- \( n \) = number of completed charging sessions by the user
- \( \vec{S}_i \) = normalized vector of the station used in session \( i \)
- \( w_i \) = weight (currently 1 for all sessions, but can be adjusted to favor recent behavior)

The user's **preferred connector type** is determined by the connector type they use most frequently.

The user profile is stored in the `UserStationProfile` table (in normalized form).

---

## 4. Similarity Metric: Euclidean Distance

The similarity between a user's profile and a candidate station is measured by **inverse Euclidean distance**:

\[
\text{dist}( \vec{U}, \vec{S} ) = \sqrt{ (U_P - S_P)^2 + (U_C - S_C)^2 + (U_D - S_D)^2 }
\]

A smaller distance means a station is more similar to the user's preferences. The final **similarity score** is:

\[
\text{score} = 1 / (1 + \text{dist})
\]

Only stations with a matching connector type are considered.

---

## 5. Re‑ranking Based on Historical Occupancy

To improve the probability that the recommended station will be available, we apply a **re‑ranking penalty** based on the station's occupancy history during the user's preferred time slots.

For each candidate station, we calculate:

\[
\text{adjustedScore} = \text{score} \times (1 - \text{occupancyPenalty})
\]

Where:
- `occupancyPenalty` is the fraction of time the station was occupied during the same day-of-week and hour-of-day as the user's typical charging times (derived from historical session data).

The penalty is capped at 0.5 (50% reduction). If no occupancy data exists, penalty = 0.

---

## 6. Cold‑Start Handling

For new users with no charging history, the system falls back to:

- **Default profile**: Global average of all station vectors (neutral preference).
- **Fallback order**: Stations with the highest rating (if available) or nearest stations (by distance).
- **Connector type** is taken from the user's registered vehicle.

The cold-start vector is stored temporarily in `UserStationProfile` and is replaced as soon as the first session is completed.

---

## 7. Algorithm Workflow (Pseudo‑Code)

```plaintext
function GetRecommendations(userId, userLocation):
    # 1. Retrieve or compute user profile
    profile = db.UserStationProfile.Find(userId)
    if profile is null:
        profile = coldStartProfile(db, user.vehicle.connectorTypeId)

    # 2. Get stations with matching connector type
    candidates = db.StationVectors
        .Where(sv => sv.ConnectorTypeID == profile.PreferredConnectorTypeID)
        .ToList()

    # 3. Apply distance filter (e.g., within 50 km)
    candidates = filterByDistance(candidates, userLocation)

    # 4. Compute Euclidean distance and score
    for each station in candidates:
        dist = sqrt(
            pow(profile.AvgPower - station.NormPower, 2) +
            pow(profile.AvgPrice - station.NormPrice, 2) +
            pow(profile.AvgDistance - station.NormDistance, 2)
        )
        station.Score = 1 / (1 + dist)

    # 5. Apply re‑ranking
    occupancy = getHistoricalOccupancy(userId, dayOfWeek, hourOfDay)
    for each station in candidates:
        penalty = occupancy.GetValueOrDefault(station.StationID, 0)
        station.AdjustedScore = station.Score * (1 - penalty)

    # 6. Sort by adjusted score descending, take top N
    recommendations = candidates
        .OrderByDescending(s => s.AdjustedScore)
        .Take(10)
        .Select(s => s.StationID)
        .ToList()

    return recommendations
```

---

## 8. Database Tables Used

| Table | Purpose |
|-------|---------|
| `StationVectors` | Precomputed normalized station attributes (power, price, distance, connector type). Updated when tariffs change or stations are added. |
| `UserStationProfile` | User preference vector (normalized averages) + preferred connector type. Updated after each completed session. |
| `RecommendationsCache` | Optional cache for top‑N recommendations per user, refreshed on session completion or on explicit request. |
| `ChargingSessions` | Source of historical data for user profiles and occupancy statistics. |
| `Tariffs` | Current prices used to compute station price attribute. |
| `Connectors` | Provides power and connector type per station. |

---

## 9. Refresh Triggers

The recommendation data is refreshed upon:

- **Completion of a charging session** → updates user profile and invalidates cache.
- **Tariff change** → updates station vectors and invalidates affected caches.
- **New station added or status changed** → update station vectors.
- **Explicit user request** (pull‑to‑refresh in mobile app).

---

## 10. Performance Considerations

- **Station vectors** are recomputed on tariff/station changes only (background job).
- **User profiles** are lightweight – recomputed on session completion.
- **RecommendationsCache** is used to serve the top‑10 list instantly for frequent users.
- **Occupancy statistics** can be pre‑aggregated hourly and stored in a separate table for fast lookup.

---

## 11. Future Enhancements

- Implement **collaborative filtering** alongside content‑based for hybrid recommendations.
- Add more attributes: station rating, amenities (café, restroom), user reviews.
- Use **cosine similarity** if the vector becomes high‑dimensional.
- Integrate with a mapping service (OpenStreetMap, Google Maps) to compute real‑time route distance.

---

## Appendix: Data Source for Normalization Ranges

The following values are used for min‑max scaling:

| Attribute | Min | Max |
|-----------|-----|-----|
| Power (kW) | 0 | 350 |
| Price (€/kWh) | 0 | 1.50 |
| Distance (km) | 0 | 50 |

*Note: These ranges can be configured via environment variables.*