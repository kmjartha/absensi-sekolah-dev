<?php

namespace App\Controllers;

use App\Core\Controller;
use App\Core\Csrf;
use App\Core\Session;
use App\Core\Validator;
use App\Models\User;

class AuthController extends Controller
{
    public function showLogin(): string
    {
        if (auth_check()) {
            return $this->redirect('/dashboard');
        }
        return $this->render('auth.login', [
            'title' => 'Masuk',
            'error' => Session::flash('error'),
            'old_niy' => $_COOKIE['remember_niy'] ?? '',
        ], 'auth');
    }

    public function login(): string
    {
        $token = Csrf::fromRequest();
        if (!Csrf::check($token)) {
            $this->flash('error', 'Sesi kedaluwarsa. Silakan coba lagi.');
            return $this->redirect('/login');
        }

        $v = new Validator($_POST);
        $v->required('niy', 'NIY')->required('password', 'Password');
        if ($v->fails()) {
            $this->flash('error', $v->firstError());
            return $this->redirect('/login');
        }

        $niy      = trim((string)($_POST['niy'] ?? ''));
        $password = (string)($_POST['password'] ?? '');
        $remember = !empty($_POST['remember']);

        $userModel = new User();
        $u = $userModel->findByNiy($niy);

        if (!$u || !password_verify($password, $u['password'])) {
            $this->flash('error', 'NIY atau password salah.');
            return $this->redirect('/login');
        }

        if ((int)$u['is_active'] !== 1) {
            $this->flash('error', 'Akun Anda dinonaktifkan. Hubungi HRD.');
            return $this->redirect('/login');
        }

        // Set session
        Session::regenerate();
        $_SESSION['user'] = [
            'id'           => (int)$u['id'],
            'niy'          => $u['niy'],
            'nama'         => $u['nama'],
            'jabatan'      => $u['jabatan'],
            'role_id'      => (int)$u['role_id'],
            'role_name'    => $u['role_name'],
            'foto_profile' => $u['foto_profile'],
        ];

        // Remember-me cookie (30 hari) — hanya simpan NIY untuk pre-fill
        if ($remember) {
            setcookie('remember_niy', $niy, [
                'expires'  => time() + 60*60*24*30,
                'path'     => '/',
                'httponly' => true,
                'samesite' => 'Lax',
            ]);
        } else {
            setcookie('remember_niy', '', time()-3600, '/');
        }

        return $this->redirect('/dashboard');
    }

    public function logout(): string
    {
        Session::destroy();
        return $this->redirect('/login');
    }
}
