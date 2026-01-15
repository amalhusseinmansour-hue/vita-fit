<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;

class SettingController extends Controller
{
    /**
     * Get all app settings
     */
    public function index()
    {
        $settings = Setting::getAllSettings();

        return response()->json([
            'success' => true,
            'settings' => $settings,
        ]);
    }

    /**
     * Get settings by group
     */
    public function getByGroup($group)
    {
        $settings = Setting::getByGroup($group);

        return response()->json([
            'success' => true,
            'group' => $group,
            'settings' => $settings,
        ]);
    }

    /**
     * Get a specific setting
     */
    public function get($key)
    {
        $value = Setting::getValue($key);

        if ($value === null) {
            return response()->json([
                'success' => false,
                'message' => 'Setting not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'key' => $key,
            'value' => $value,
        ]);
    }
}
