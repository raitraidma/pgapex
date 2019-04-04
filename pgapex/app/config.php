<?php

return [
  'settings' => [
    'db' => [
      // Default value are for CI to replace
      'driver' => env('driver', 'pgsql'),
      'host' => env('host', '127.0.0.1'),
      'port' => env('port', 5432),
      'dbname' => env('dbname', 'pgapex'),
      'username' => env('dbusername', 'pgapex_app'),
      'password' => env('dbpassword', 'pgapex_app')
    ]
  ]
];