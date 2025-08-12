/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See LICENSE.md in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import basicSsl from "@vitejs/plugin-basic-ssl";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [react(), basicSsl()],
    define: {
        'process.env': {}
    },
    build: {
        // CDN optimization settings
        chunkSizeWarningLimit: 1000,
        rollupOptions: {
            output: {
                // Manual chunk splitting for better CDN caching
                manualChunks: {
                    vendor: ['react', 'react-dom'],
                    router: ['react-router-dom'],
                    ui: ['@fluentui/react-components', '@fluentui/react-icons']
                },
                // Consistent file naming for CDN cache efficiency
                chunkFileNames: 'assets/js/[name]-[hash].js',
                entryFileNames: 'assets/js/[name]-[hash].js',
                assetFileNames: (assetInfo) => {
                    const info = assetInfo.name?.split('.') ?? [];
                    let extType = info[info.length - 1];
                    if (/png|jpe?g|svg|gif|tiff|bmp|ico/i.test(extType)) {
                        extType = 'img';
                    } else if (/woff|woff2|eot|ttf|otf/i.test(extType)) {
                        extType = 'fonts';
                    }
                    return `assets/${extType}/[name]-[hash][extname]`;
                }
            }
        },
        // Enable source maps for better debugging
        sourcemap: true,
        // Optimize for CDN delivery
        minify: 'esbuild',
        cssMinify: true
    },
    // Configure for CDN asset serving
    base: '/',
    publicDir: 'public'
});
