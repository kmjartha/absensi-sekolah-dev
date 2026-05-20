<?php

namespace App\Controllers;

use App\Core\Controller;
use App\Core\Validator;
use App\Models\Announcement;

class PengumumanController extends Controller
{
    private function guard(): void
    {
        if (!has_role('HRD', 'Kepsek')) {
            http_response_code(403);
            echo $this->view->render('errors/403', ['title' => '403'], 'auth');
            exit;
        }
    }

    private function guardView(): void
    {
        if (!has_role('HRD', 'Kepsek', 'Supervisor')) {
            http_response_code(403);
            echo $this->view->render('errors/403', ['title' => '403'], 'auth');
            exit;
        }
    }

    public function index(): string
    {
        $this->guardView();
        return $this->render('pengumuman.index', [
            'title' => 'Pengumuman',
            'items' => (new Announcement())->allWithCreator(),
        ]);
    }

    public function create(): string
    {
        $this->guard();
        return $this->render('pengumuman.create', [
            'title' => 'Tambah Pengumuman',
        ]);
    }

    public function store(): string
    {
        $this->guard();
        $v = Validator::make($_POST, [
            'judul' => 'required|max:180',
            'isi'   => 'required',
        ]);
        if ($v->fails()) {
            $_SESSION['_old']    = $_POST;
            $_SESSION['_errors'] = $v->errors();
            $this->flash('error', 'Lengkapi judul & isi pengumuman.');
            return $this->redirect('/pengumuman/create');
        }
        (new Announcement())->create([
            'judul'        => trim($_POST['judul']),
            'isi'          => trim($_POST['isi']),
            'is_published' => isset($_POST['is_published']) ? 1 : 0,
            'created_by'   => (int)(user()['id'] ?? 0) ?: null,
        ]);
        $this->flash('success', 'Pengumuman ditambahkan.');
        return $this->redirect('/pengumuman');
    }

    public function edit(string $id): string
    {
        $this->guard();
        $m = (new Announcement())->find((int)$id);
        if (!$m) return $this->redirect('/pengumuman');
        return $this->render('pengumuman.edit', [
            'title' => 'Edit Pengumuman',
            'item'  => $m,
        ]);
    }

    public function update(string $id): string
    {
        $this->guard();
        $am = new Announcement();
        if (!$am->find((int)$id)) return $this->redirect('/pengumuman');
        $am->update((int)$id, [
            'judul'        => trim($_POST['judul']),
            'isi'          => trim($_POST['isi']),
            'is_published' => isset($_POST['is_published']) ? 1 : 0,
        ]);
        $this->flash('success', 'Pengumuman diperbarui.');
        return $this->redirect('/pengumuman');
    }

    public function toggle(string $id): string
    {
        $this->guard();
        (new Announcement())->togglePublish((int)$id);
        $this->flash('success', 'Status publikasi diubah.');
        return $this->redirect('/pengumuman');
    }

    public function destroy(string $id): string
    {
        $this->guard();
        (new Announcement())->delete((int)$id);
        $this->flash('success', 'Pengumuman dihapus.');
        return $this->redirect('/pengumuman');
    }
}
