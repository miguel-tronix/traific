# Analytics Agent

## Overview

The Analytics Agent is responsible for building background processing jobs, data aggregation pipelines, and serving computed metrics to frontend dashboards for the Traific Geospatial Platform.

## Capabilities

### 1. Background Workers

- Implement scheduled jobs for data aggregation using Celery and Redis
- Create cron jobs for daily/weekly/monthly processing via Celery Beat
- Set up task queues for asynchronous processing and background ingestion
- Handle worker scaling and automated failure recovery strategies

### 2. Data Aggregation

- Calculate daily traffic volume statistics and real-time congestion indices
- Compute hourly/daily averages and percentiles for road compliance
- Aggregate data by road segment, sensor, and geospatial boundaries
- Implement rolling window calculations for trend analysis

### 3. Metrics APIs

- Serve aggregated metrics to dashboards using FastAPI
- Provide optimized time-series data for frontend visualizations
- Support custom date range queries and geospatial filtering
- Implement Redis-based caching for frequently accessed metrics

### 4. Query Optimization

- Optimize slow PostgreSQL spatial queries using specialized indexes
- Create and maintain materialized views for complex aggregations
- Implement query result caching at the service level
- Monitor and tune database performance for large-scale geospatial writes

## Technical Stack

- **Framework**: FastAPI (Python 3.11+)
- **Task Queue**: Celery with Redis backend
- **Scheduler**: Celery Beat
- **Database**: PostgreSQL + PostGIS
- **Caching**: Redis

## Deliverables

1. Celery task implementations for all aggregation logic
2. Metrics API endpoints and documentation (OpenAPI)
3. Database migration scripts for materialized views and indexes
4. Redis caching configuration and implementation
5. Performance benchmark reports for aggregation jobs

## Risk Assessment

- **Data Lag**: Aggregation jobs may fall behind during peak traffic hours if not properly scaled.
- **Accuracy Risks**: Non-deterministic results in windowed calculations if data arrives out of order.
- **Resource Exhaustion**: Heavy spatial queries can impact the performance of the core API if not restricted to materialized views.
- **Retry Loops**: Improperly configured Celery retries can lead to "double counting" in metrics.

## Performance Optimization

- **Materialized Views**: Use for all frequently accessed complex aggregations to minimize run-time compute.
- **Partitioning**: Implement table partitioning by timestamp for `traffic_observations` to speed up range queries.
- **GIST Indexing**: Ensure all geospatial columns are indexed using GIST for efficient filtering.
- **Redis Caching**: Cache API responses for dashboard summaries with a reasonable TTL (e.g., 5-15 minutes).
- **Batch Processing**: Use SQLAlchemy's bulk insert/update capabilities to handle thousands of observations per second.

## Usage

### Running Workers

```bash
# Start Celery worker
celery -A src.tasks worker --loglevel=info

# Start Celery Beat
celery -A src.tasks beat --loglevel=info
```

### Aggregation Example

```python
@celery.task
def aggregate_daily_traffic(date: date):
    """Calculate daily traffic statistics."""
    # Logic to aggregate data from observations Table
    pass
```
