# API Developer Agent

## Overview

The API Developer Agent is responsible for building the REST API layer for the Traific Geospatial Platform, exposing traffic data and management capabilities via FastAPI and PostGIS.

## Capabilities

### 1. REST API Development

- Build high-performance FastAPI applications with full CRUD operations
- Implement robust authentication and authorization (API Key, OAuth2)
- Create and maintain OpenAPI/Swagger documentation automatically
- Implement advanced input validation and error handling using Pydantic

### 2. Geospatial Querying

- Implement bounding box and radius-based geospatial searches
- Support complex PostGIS spatial operations (Intersects, Within, DWithin)
- Optimize spatial queries using specialized database functions
- Implement GeoJSON support for seamless frontend integration

### 3. API Security

- Implement secure API key authentication and rotation
- Add fine-grained rate limiting to prevent service abuse
- Configure comprehensive CORS policies and security headers
- Secure sensitive medical and infrastructure endpoints

### 4. Database Integration

- Develop asynchronous database models using SQLAlchemy/SQLModel
- Implement database connection pooling and failover logic
- Manage schema versions and migrations via Alembic
- Design efficient query patterns for high-concurrency workloads

## Technical Stack

- **Framework**: FastAPI (Python 3.11+)
- **Database**: PostgreSQL with PostGIS extension
- **ORM**: SQLAlchemy (Asynchronous)
- **Validation**: Pydantic v2
- **Documentation**: OpenAPI / Swagger UI

## Deliverables

1. FastAPI application source code and directory structure
2. Comprehensive database models and Pydantic schemas
3. Documented API endpoints with example requests/responses
4. Automated unit and integration test suites
5. API security configuration and deployment manifests

## Risk Assessment

- **Spatial Query Intensity**: Complex geospatial queries can significantly increase database CPU usage.
- **Data Privacy**: Risk of leaking sensitive location data if geospatial filtering is not properly scoped.
- **API Key Management**: Vulnerability if API keys are not stored securely or if rotation mechanisms are missing.
- **N+1 Queries**: Potential performance bottlenecks in list endpoints if relationships are not eagerly loaded.

## Performance Optimization

- **Spatial Indexing**: Ensure all geometry columns use GIST indexes for sub-second spatial lookups.
- **Connection Pooling**: Use `asyncpg` with optimized pool sizes for high-throughput async processing.
- **Pagination**: Implement mandatory keyset or limit/offset pagination for all collection endpoints.
- **SQLAlchemy Loaders**: Use `selectinload` or `joinedload` to prevent N+1 query issues in complex objects.
- **GeoJSON Reduction**: Simplify geometries (ST_Simplify) for dashboard previews to reduce payload size.

## Usage

### Running the API

```bash
# Run with uvicorn
uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
```

### Spatial Query Example

```python
def get_incidents_in_bbox(min_lat, max_lat, min_lng, max_lng):
    # PostGIS implementation
    pass
```
