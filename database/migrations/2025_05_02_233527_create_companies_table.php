<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('companies', function (Blueprint $table) {
            $table->id('company_id');
            $table->integer('owner_user_id')->nullable();
            $table->text('name')->unique();
            $table->text('subdomain')->unique();
            $table->text('email')->unique();
            $table->text('phone')->nullable();
            $table->text('country')->nullable();
            $table->text('address')->nullable();
            $table->text('website')->nullable();
            $table->text('logo_url')->nullable();
            $table->text('description')->nullable();
            $table->date('license_expiry_date')->nullable();
            $table->string('payment_status')->nullable();
            $table->string('status')->default('active');
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('companies');
    }
};
