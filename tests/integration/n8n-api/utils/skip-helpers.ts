/**
 * Skip Helpers for Integration Tests
 * 
 * Provides utilities to gracefully skip tests when external
 * dependencies (n8n API, webhook URLs) are not available.
 * This prevents CI failures when secrets are not configured.
 */

import { describe, it, beforeAll } from 'vitest';

/**
 * Check if n8n API is reachable with a lightweight health check
 * 
 * @returns true if API responds, false otherwise
 */
export async function isN8nApiAvailable(): Promise<boolean> {
  const url = process.env.N8N_API_URL;
  const apiKey = process.env.N8N_API_KEY;

  // If env vars are missing or still have mock/default values, API is not available
  if (!url || !apiKey) return false;
  if (url.includes('localhost:3001/mock-api')) return false;
  if (apiKey === 'test-api-key-12345') return false;

  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 5000);

    const response = await fetch(`${url}/api/v1/workflows?limit=1`, {
      headers: { 'X-N8N-API-KEY': apiKey },
      signal: controller.signal,
    });

    clearTimeout(timeout);
    return response.ok;
  } catch {
    return false;
  }
}

/**
 * Conditionally skip a test suite if n8n API is not available.
 * 
 * Usage:
 * ```ts
 * describe('My API Test', () => {
 *   skipIfNoN8nApi();
 *   // ... tests ...
 * });
 * ```
 */
export function skipIfNoN8nApi(): void {
  let apiAvailable = false;

  beforeAll(async () => {
    apiAvailable = await isN8nApiAvailable();
    if (!apiAvailable) {
      console.warn(
        '[SKIP] n8n API not available — skipping integration tests.\n' +
        '  N8N_API_URL: ' + (process.env.N8N_API_URL || 'not set') + '\n' +
        '  To run these tests, configure GitHub Secrets or .env file.'
      );
    }
  });

  // This is a workaround: vitest doesn't have a clean "skip suite" API
  // from inside beforeAll. Instead we check in each test.
  // The caller should use `describeIfN8nApi` instead for cleaner skipping.
}

/**
 * Wrapper around describe() that only runs if n8n API is available.
 * Tests are skipped (not failed) when API is unreachable.
 * 
 * Usage:
 * ```ts
 * describeIfN8nApi('My API Test', () => {
 *   it('should create workflow', async () => { ... });
 * });
 * ```
 */
export function describeIfN8nApi(name: string, fn: () => void): void {
  const url = process.env.N8N_API_URL;
  const apiKey = process.env.N8N_API_KEY;

  // Quick sync check — if env vars are clearly mock/missing, skip immediately
  const hasMockUrl = !url || url.includes('localhost:3001/mock-api');
  const hasMockKey = !apiKey || apiKey === 'test-api-key-12345';

  if (hasMockUrl || hasMockKey) {
    describe.skip(`${name} (n8n API not configured)`, fn);
  } else {
    describe(name, fn);
  }
}
