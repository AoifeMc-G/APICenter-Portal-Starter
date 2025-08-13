document.addEventListener('DOMContentLoaded', function() {
    const currentHost = window.location.hostname;
    
    // Update connection info
    document.getElementById('current-host').textContent = currentHost;
    
    // Determine access method and update UI
    const isFrontDoorEndpoint = currentHost.includes('azurefd.net');
    const isCustomDomain = currentHost.includes('api.kantar.com');
    const isDirectAccess = currentHost.includes('azurestaticapps.net');
    
    const accessStatusEl = document.getElementById('access-status');
    const accessBadgeEl = document.getElementById('access-badge');
    const accessMethodEl = document.getElementById('access-method');
    const frontDoorIdEl = document.getElementById('frontdoor-id');
    const securityStatusEl = document.getElementById('security-status');
    
    if (isFrontDoorEndpoint) {
        accessMethodEl.textContent = '🚀 Azure Front Door CDN';
        frontDoorIdEl.textContent = '38a9b306-7e71-45d7-affa-5a101cef5445';
        securityStatusEl.textContent = '🛡️ Fully Secured';
        accessBadgeEl.textContent = '✅ Optimal';
        accessBadgeEl.className = 'badge success';
        accessStatusEl.className = 'status-item success';
    } else if (isCustomDomain) {
        accessMethodEl.textContent = '🌐 Custom Domain via Front Door';
        frontDoorIdEl.textContent = '38a9b306-7e71-45d7-affa-5a101cef5445';
        securityStatusEl.textContent = '🛡️ Fully Secured';
        accessBadgeEl.textContent = '✅ Secure';
        accessBadgeEl.className = 'badge success';
        accessStatusEl.className = 'status-item success';
    } else if (isDirectAccess) {
        accessMethodEl.textContent = '⚠️ Direct Static Web App Access';
        frontDoorIdEl.textContent = 'N/A (Direct Access)';
        securityStatusEl.textContent = '⚠️ Not Recommended';
        accessBadgeEl.textContent = '⚠️ Bypassed';
        accessBadgeEl.className = 'badge warning';
        accessStatusEl.className = 'status-item warning';
    } else {
        accessMethodEl.textContent = '🔍 Unknown Access Method';
        frontDoorIdEl.textContent = 'Unknown';
        securityStatusEl.textContent = '❓ Needs Investigation';
        accessBadgeEl.textContent = '❓ Unknown';
        accessBadgeEl.className = 'badge warning';
    }
});