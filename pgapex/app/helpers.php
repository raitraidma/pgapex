<?php

function env($key, $defaultValue = null) {
  static $envSettings = null;

  if (isset($_ENV[$key])) {
    return $_ENV[$key];
  }

  $envFilePath = __DIR__ . '/.env';
  if ($envSettings === null && file_exists($envFilePath)) {
    $envSettings = parse_ini_file($envFilePath);
    if ($envSettings === false) {
      $envSettings = [];
    }
  }

  if (isset($envSettings[$key])) {
    return $envSettings[$key];
  }

  return $defaultValue;
}