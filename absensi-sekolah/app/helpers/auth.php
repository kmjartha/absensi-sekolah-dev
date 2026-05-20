<?php

if (!function_exists('user')) {
    function user(): ?array
    {
        return $_SESSION['user'] ?? null;
    }
}

if (!function_exists('auth_check')) {
    function auth_check(): bool
    {
        return !empty($_SESSION['user']);
    }
}

if (!function_exists('user_role')) {
    function user_role(): ?string
    {
        return $_SESSION['user']['role_name'] ?? null;
    }
}

if (!function_exists('has_role')) {
    function has_role(string ...$roles): bool
    {
        return in_array(user_role(), $roles, true);
    }
}

if (!function_exists('is_pegawai')) {
    function is_pegawai(): bool
    {
        return has_role('Guru', 'Staff', 'Security', 'Manajerial');
    }
}

if (!function_exists('csrf_field')) {
    function csrf_field(): string
    {
        return \App\Core\Csrf::field();
    }
}

if (!function_exists('csrf_token')) {
    function csrf_token(): string
    {
        return \App\Core\Csrf::token();
    }
}
