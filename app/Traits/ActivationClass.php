<?php

namespace App\Traits;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Session;

trait ActivationClass
{
    public function dmvf($request)
    {
        // Purchase code verification bypassed - always return success
        Session::put('purchase_key', 'bypassed');
        Session::put('username', 'admin');
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
