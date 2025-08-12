#!/bin/bash

# CDN Performance Testing Script
# Run this script to test your CDN configuration

echo "🚀 CDN Performance Testing Suite"
echo "================================="
echo ""

# Test endpoints
ENDPOINTS=(
    "https://salmon-ground-05f8dd903.2.azurestaticapps.net"
    "https://afd-ki-api-glb-001-apic-endpoint-craggrgufpaph6f2.a03.azurefd.net"
    "https://portal-uat.api.kantar.com"
)

echo "1. Response Header Analysis"
echo "---------------------------"
for endpoint in "${ENDPOINTS[@]}"; do
    echo "Testing: $endpoint"
    curl -I "$endpoint" 2>/dev/null | grep -E "(cache-control|etag|vary|x-cdn|x-azure|server|content-encoding)" || echo "No CDN headers found"
    echo ""
done

echo "2. Performance Timing Tests"
echo "---------------------------"
for endpoint in "${ENDPOINTS[@]}"; do
    echo "Testing: $endpoint"
    curl -o /dev/null -s -w "DNS: %{time_namelookup}s | Connect: %{time_connect}s | Transfer: %{time_total}s | Size: %{size_download} bytes\n" "$endpoint"
    echo ""
done

echo "3. Asset Loading Test"
echo "--------------------"
# Test specific asset types
ASSET_PATHS=(
    "/assets/js/"
    "/assets/css/"
    "/assets/img/"
    "/assets/fonts/"
)

for endpoint in "${ENDPOINTS[@]}"; do
    echo "Testing assets from: $endpoint"
    for path in "${ASSET_PATHS[@]}"; do
        # This would need actual asset URLs from your build
        echo "  Asset path: $path (test specific files after deployment)"
    done
    echo ""
done

echo "4. Compression Test"
echo "------------------"
for endpoint in "${ENDPOINTS[@]}"; do
    echo "Testing compression for: $endpoint"
    # Test with gzip
    size_uncompressed=$(curl -H "Accept-Encoding: identity" -s "$endpoint" | wc -c)
    size_compressed=$(curl -H "Accept-Encoding: gzip" -s "$endpoint" | wc -c)
    
    if [ $size_compressed -lt $size_uncompressed ]; then
        echo "✅ Compression working: $size_uncompressed -> $size_compressed bytes"
    else
        echo "⚠️ Compression may not be working properly"
    fi
    echo ""
done

echo "5. Cache Headers Validation"
echo "---------------------------"
for endpoint in "${ENDPOINTS[@]}"; do
    echo "Checking cache headers for: $endpoint"
    
    # Check for proper cache headers
    cache_control=$(curl -I "$endpoint" 2>/dev/null | grep -i "cache-control" | cut -d: -f2-)
    etag=$(curl -I "$endpoint" 2>/dev/null | grep -i "etag" | cut -d: -f2-)
    
    if [ ! -z "$cache_control" ]; then
        echo "✅ Cache-Control:$cache_control"
    else
        echo "❌ No Cache-Control header found"
    fi
    
    if [ ! -z "$etag" ]; then
        echo "✅ ETag:$etag"
    else
        echo "❌ No ETag header found"
    fi
    echo ""
done

echo "Testing complete! 🎉"
echo ""
echo "Next steps:"
echo "1. Deploy your app and run this script"
echo "2. Open cdn-test.html in your browser"
echo "3. Use browser dev tools to verify CDN performance"
echo "4. Test from different geographic locations"
