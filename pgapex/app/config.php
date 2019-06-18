<?php

return [
  'settings' => [
    'db' => [
      // Default value are for CI to replace
      'driver' => env('driver', 'pgsql'),
      'host' => env('host', '127.0.0.1'),
      'port' => env('port', 5432),
      'dbname' => env('dbname', '#DB_DATABASE'),
      'username' => env('dbusername', '#DB_APP_USER'),
      'password' => env('dbpassword', '#DB_APP_USER_PASS')
    ]
  ]
];
