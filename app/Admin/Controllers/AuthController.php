<?php

namespace App\Admin\Controllers;

use Encore\Admin\Controllers\AuthController as BaseAuthController;

class AuthController extends BaseAuthController
{
    /**
     * @var string
     */
    protected $title = 'Auth';

    /**
     * @return string
     */
    protected function title(): string
    {
        return $this->title;
    }

}
