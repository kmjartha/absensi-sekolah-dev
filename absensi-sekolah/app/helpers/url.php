<?php

use App\Core\App;

if (!function_exists('url')) {
    function url(string $path = ''): string
    {
        $base = rtrim(App::$config['url'] ?? '', '/');
        if ($base === '') {
            $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
            $host   = $_SERVER['HTTP_HOST'] ?? 'localhost';
            $requestPath = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
            $scriptDir   = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');

            $appDir = $scriptDir;
            if (str_ends_with($scriptDir, '/public')) {
                $appDir = substr($scriptDir, 0, -strlen('/public')) ?: '/';
            }

            if ($scriptDir !== $appDir && (str_starts_with($requestPath, $scriptDir . '/') || $requestPath === $scriptDir)) {
                $base = $scheme . '://' . $host . ($scriptDir === '/' ? '' : $scriptDir);
            } elseif ($requestPath === '/' || str_starts_with($requestPath, $appDir . '/') || $requestPath === $appDir) {
                $base = $scheme . '://' . $host . ($appDir === '/' ? '' : $appDir);
            } else {
                $base = $scheme . '://' . $host . ($scriptDir === '/' ? '' : $scriptDir);
            }
            $base = rtrim($base, '/');
        }

        return $base . '/' . ltrim($path, '/');
    }
}

if (!function_exists('asset')) {
    function asset(string $path): string
    {
        return url('assets/' . ltrim($path, '/'));
    }
}

if (!function_exists('upload_url')) {
    function upload_url(string $path): string
    {
        if (!$path) return asset('images/default-avatar.png');

        $rel = ltrim($path, '/');
        $rootPath = UPLOADS_PATH . '/' . $rel;
        $legacyPath = BASE_PATH . '/public/uploads/' . $rel;

        if (is_file($rootPath)) {
            return url('uploads/' . $rel);
        }

        if (is_file($legacyPath)) {
            return url('absensi-sekolah/public/uploads/' . $rel);
        }

        return url('uploads/' . $rel);
    }
}

if (!function_exists('profile_photo_url')) {
    function profile_photo_url(?string $path): string
    {
        if (!$path) return asset('images/default-avatar.png');

        $rel = trim((string)$path);
        $rel = str_replace('\\', '/', $rel);
        $rel = preg_replace('#^https?://[^/]+#i', '', $rel);
        $rel = preg_replace('#^/+#', '', $rel);
        $rel = preg_replace('#^.*?/uploads/profile/+#', '', $rel);
        $rel = preg_replace('#^.*?/profile/+#', '', $rel);
        $rel = preg_replace('#^uploads/+#', '', $rel);
        $rel = basename($rel);

        $candidates = [
            UPLOADS_PATH . '/profile/' . $rel,
            BASE_PATH . '/public/uploads/profile/' . $rel,
            BASE_PATH . '/public/uploads/' . $rel,
        ];

        foreach ($candidates as $candidate) {
            if (is_file($candidate)) {
                if (str_starts_with($candidate, BASE_PATH . '/public/uploads/')) {
                    return url('absensi-sekolah/public/uploads/' . ltrim(str_replace(BASE_PATH . '/public/uploads/', '', $candidate), '/'));
                }
                return url('uploads/profile/' . $rel);
            }
        }

        return url('uploads/profile/' . $rel);
    }
}

if (!function_exists('current_url')) {
    function current_url(): string
    {
        return ($_SERVER['REQUEST_URI'] ?? '/');
    }
}

if (!function_exists('is_active')) {
    function is_active(string $pattern, string $class = 'active'): string
    {
        $uri = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
        // Remove script directory prefix so routes work when app is in subfolder
        $scriptDir = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
        if ($scriptDir !== '' && $scriptDir !== '/' && str_starts_with($uri, $scriptDir)) {
            $uri = substr($uri, strlen($scriptDir));
            if ($uri === '') $uri = '/';
        }
        return str_starts_with($uri, $pattern) ? $class : '';
    }
}

if (!function_exists('is_active_exact')) {
    function is_active_exact(string $pattern, string $class = 'active'): string
    {
        $uri = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
        // Remove script directory prefix (same logic as is_active)
        $scriptDir = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
        if ($scriptDir !== '' && $scriptDir !== '/' && str_starts_with($uri, $scriptDir)) {
            $uri = substr($uri, strlen($scriptDir));
            if ($uri === '') $uri = '/';
        }
        // Normalize by trimming trailing slashes so "/absensi" and "/absensi/" match
        $u = rtrim($uri, '/');
        $p = rtrim($pattern, '/');
        if ($u === '') $u = '/';
        if ($p === '') $p = '/';
        return $u === $p ? $class : '';
    }
}
