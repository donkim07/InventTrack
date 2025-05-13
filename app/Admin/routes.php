<?php

use Illuminate\Routing\Router;

Admin::routes();

Route::group([
    'prefix'        => config('admin.route.prefix'),
    'namespace'     => config('admin.route.namespace'),
    'middleware'    => config('admin.route.middleware'),
    'as'            => config('admin.route.prefix') . '.',
], function (Router $router) {

    $router->get('/', 'HomeController@index')->name('home');
    $router->resource('companies', CompanyController::class);
    $router->resource('users', UserController::class);
    $router->resource('auth', AuthController::class);
    $router->resource('roles', RoleController::class);
    $router->resource('permissions', PermissionController::class);
    $router->resource('admins', AdminController::class);
    $router->resource('settings', SettingController::class);
    $router->resource('logs', LogController::class);
    $router->resource('activity-logs', ActivityLogController::class);
    $router->resource('notifications', NotificationController::class);
    $router->resource('audit-logs', AuditLogController::class);
    $router->resource('backups', BackupController::class);
    $router->resource('translations', TranslationController::class);
    $router->resource('menus', MenuController::class);
    $router->resource('widgets', WidgetController::class);
    $router->resource('themes', ThemeController::class);
    $router->resource('languages', LanguageController::class);
    $router->resource('files', FileController::class);
    $router->resource('media', MediaController::class);
    

});
