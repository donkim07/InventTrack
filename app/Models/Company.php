<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Company extends Model
{
    protected $fillable = [
        'name',
        // Add other fillable fields
        'owner_user_id',
        'subdomain',
        'email',
        'phone',
        'country',
        'address',
        'website',
        'logo_url',
        'description',
        'license_expiry_date',
        'payment_status',
        'status',
    ];
}
