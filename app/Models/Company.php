<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Company extends Model
{
    protected $fillable = [
        'name'
        // Add other fillable fields
        // 'owner_user_id',
        // 'subdomain',
        // 'email',
    ];
}
