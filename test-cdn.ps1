# CDN Performance Testing Script for PowerShell
# Test your Azure Static Web App CDN configuration

Write-Host "🚀 CDN Performance Testing Suite" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

# Test endpoints
$endpoints = @(
    "https://salmon-ground-05f8dd903.2.azurestaticapps.net",
    "https://afd-ki-api-glb-001-apic-endpoint-craggrgufpaph6f2.a03.azurefd.net",
    "https://portal-uat.api.kantar.com"
)

Write-Host "1. Response Header Analysis" -ForegroundColor Yellow
Write-Host "---------------------------" -ForegroundColor Yellow

foreach ($endpoint in $endpoints) {
    Write-Host "Testing: $endpoint" -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri $endpoint -Method Head -UseBasicParsing
        
        # Check for CDN-specific headers
        $cdnHeaders = @("Cache-Control", "ETag", "Vary", "X-CDN-Optimized", "X-Azure-Ref", "Server")
        
        foreach ($header in $cdnHeaders) {
            if ($response.Headers.$header) {
                Write-Host "  ✅ $header : $($response.Headers.$header)" -ForegroundColor Green
            }
        }
        
        # Check status
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✅ Status: OK ($($response.StatusCode))" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ Status: $($response.StatusCode)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "2. Performance Timing Tests" -ForegroundColor Yellow
Write-Host "---------------------------" -ForegroundColor Yellow

foreach ($endpoint in $endpoints) {
    Write-Host "Testing: $endpoint" -ForegroundColor Cyan
    
    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $response = Invoke-WebRequest -Uri $endpoint -UseBasicParsing
        $stopwatch.Stop()
        
        $responseTime = $stopwatch.ElapsedMilliseconds
        $contentLength = $response.Content.Length
        
        Write-Host "  ⏱️ Response Time: ${responseTime}ms" -ForegroundColor White
        Write-Host "  📦 Content Size: $contentLength bytes" -ForegroundColor White
        
        if ($responseTime -lt 500) {
            Write-Host "  ✅ Excellent performance (<500ms)" -ForegroundColor Green
        } elseif ($responseTime -lt 1000) {
            Write-Host "  ✅ Good performance (<1000ms)" -ForegroundColor Yellow
        } else {
            Write-Host "  ⚠️ Slow performance (>1000ms)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "  ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "3. Cache Headers Validation" -ForegroundColor Yellow
Write-Host "---------------------------" -ForegroundColor Yellow

foreach ($endpoint in $endpoints) {
    Write-Host "Testing: $endpoint" -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri $endpoint -Method Head -UseBasicParsing
        
        # Validate cache headers
        $cacheControl = $response.Headers["Cache-Control"]
        $etag = $response.Headers["ETag"]
        $vary = $response.Headers["Vary"]
        
        if ($cacheControl) {
            Write-Host "  ✅ Cache-Control: $cacheControl" -ForegroundColor Green
            
            if ($cacheControl -match "max-age=\d+") {
                Write-Host "    ✅ Max-age directive found" -ForegroundColor Green
            }
            if ($cacheControl -match "public") {
                Write-Host "    ✅ Public caching enabled" -ForegroundColor Green
            }
        } else {
            Write-Host "  ❌ No Cache-Control header" -ForegroundColor Red
        }
        
        if ($etag) {
            Write-Host "  ✅ ETag: $etag" -ForegroundColor Green
        } else {
            Write-Host "  ❌ No ETag header" -ForegroundColor Red
        }
        
        if ($vary) {
            Write-Host "  ✅ Vary: $vary" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "4. Compression Test" -ForegroundColor Yellow
Write-Host "-------------------" -ForegroundColor Yellow

foreach ($endpoint in $endpoints) {
    Write-Host "Testing: $endpoint" -ForegroundColor Cyan
    
    try {
        # Test with gzip encoding
        $headers = @{"Accept-Encoding" = "gzip, deflate, br"}
        $response = Invoke-WebRequest -Uri $endpoint -Headers $headers -UseBasicParsing
        
        $contentEncoding = $response.Headers["Content-Encoding"]
        $contentLength = $response.Headers["Content-Length"]
        
        if ($contentEncoding) {
            Write-Host "  ✅ Compression: $contentEncoding" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ No compression detected" -ForegroundColor Yellow
        }
        
        if ($contentLength) {
            Write-Host "  📦 Compressed size: $contentLength bytes" -ForegroundColor White
        }
    }
    catch {
        Write-Host "  ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}
