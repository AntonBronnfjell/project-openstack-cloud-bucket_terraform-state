# Fix iron.graphicsforge.net 502 Error

## Problem
Getting "502 Bad Gateway" when accessing `https://iron.graphicsforge.net`

## Root Cause
Traefik was routing to `http://192.168.2.4:4442` but Swift runs on `http://192.168.2.3:8080`

## Fixes Applied

### ✅ 1. Updated Port Configuration
- Changed `TARGET_PORT_IRON` from `4442` to `8080` in:
  - `dynamic/graphicsforge.net/.env.domain`
  - `services/graphicsforge.net/.env.domain`

### ✅ 2. Updated Traefik Output Files
- Updated `dynamic/graphicsforge.net/output/iron.yml`:
  - Changed from: `http://192.168.2.4:4442`
  - Changed to: `http://192.168.2.3:8080`

- Updated `services/graphicsforge.net/output/iron.yml`:
  - Changed from: `http://192.168.2.4:4442`
  - Changed to: `http://192.168.2.3:8080`

## Next Steps

### 1. Restart Traefik
The Traefik configuration needs to be reloaded. You can:

**Option A: Restart Traefik container**
```bash
# SSH to Traefik host (192.168.2.4 or wherever Traefik runs)
docker restart traefik
# or
systemctl restart traefik
```

**Option B: Use Traefik's API to reload**
```bash
# If Traefik API is enabled
curl -X POST http://traefik-host:8080/api/rawdata
```

**Option C: Regenerate configs and restart**
```bash
cd project-traefik-container-yaml_domain-reverse-proxy
./scripts/generate-configs.sh  # If this script exists
./scripts/restart-traefik.sh   # If this script exists
```

### 2. Verify Swift is Running
Before restarting Traefik, verify Swift is accessible:

```bash
# Test Swift directly
curl http://192.168.2.3:8080

# Test with authentication
curl -X GET http://192.168.2.3:8080/auth/v1.0 \
  -H "X-Auth-User: admin" \
  -H "X-Auth-Key: your-password"
```

### 3. Test the Domain
After restarting Traefik:

```bash
# Test HTTPS
curl -k https://iron.graphicsforge.net

# Should return Swift API response, not 502
```

## Verification

After fixes:
1. ✅ Port changed to 8080
2. ✅ Server IP changed to 192.168.2.3 (OpenStack host)
3. ⚠️ Traefik needs restart to pick up changes
4. ⚠️ Swift must be running on 192.168.2.3:8080

## Troubleshooting

If still getting 502:

1. **Check Swift is running:**
   ```bash
   ssh root@192.168.2.3
   systemctl status swift-proxy
   # or
   docker ps | grep swift
   ```

2. **Check Traefik can reach backend:**
   ```bash
   # From Traefik host
   curl http://192.168.2.3:8080
   ```

3. **Check Traefik logs:**
   ```bash
   docker logs traefik | grep iron
   # or
   journalctl -u traefik | grep iron
   ```

4. **Verify Traefik config loaded:**
   ```bash
   # Check if Traefik picked up the new config
   docker exec traefik cat /path/to/iron.yml
   ```

## Expected Result

After restart, `https://iron.graphicsforge.net` should:
- Return Swift API responses (not 502)
- Support S3-compatible operations
- Work with Terraform backend configuration
