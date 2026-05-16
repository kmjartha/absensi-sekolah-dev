<?php

namespace App\Middleware;

class AuthMiddleware
{
    public function handle(): void
    {
        if (empty($_SESSION['user'])) {
            header('Location: ' . url('/login'));
            exit;
        }
    }
}
