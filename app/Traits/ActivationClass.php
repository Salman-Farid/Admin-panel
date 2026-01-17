<?php

namespace App\Traits;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Session;

trait ActivationClass
{
    // Constants for bypassed activation
    private const BYPASS_USERNAME = 'admin';
    private const BYPASS_PURCHASE_CODE = 'bypassed';

    public function dmvf($request)
    {
        // Purchase code verification bypassed - always return success
        Session::put('purchase_key', self::BYPASS_PURCHASE_CODE);
        Session::put('username', self::BYPASS_USERNAME);
        return 'step3';
    }

    public function actch()
    {
        // Activation check bypassed - always return true
        return true;
    }

    public function is_local(): bool
    {
        $whitelist = array(
            '127.0.0.1',
            '::1'
        );

        if (!in_array(request()->ip(), $whitelist)) {
            return false;
        }

        return true;
    }
}
