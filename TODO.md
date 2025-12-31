# TODO

## Production Environment Configuration

Please manually add the `API_URL` to the `.env.prod` file.

The `.env.prod` file currently contains:
- ENABLE_CRASHLYTICS=true
- ENABLE_ANALYTICS=true

You need to add:
- API_URL=<your-production-api-url>

Example:
```
ENABLE_CRASHLYTICS=true
ENABLE_ANALYTICS=true

API_URL=https://api.edubadges.nl
```
