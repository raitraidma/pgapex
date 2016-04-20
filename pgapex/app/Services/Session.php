<?php

namespace App\Services;

class Session implements Service {
  public function __construct() {
    $this->startSession();
  }

  protected function startSession() {
    if (session_status() === PHP_SESSION_NONE) {
      session_start();
    }
  }

  public function get($name, $defaultValue = null) {
    $this->startSession();
    return isset($_SESSION[$name]) ? $_SESSION[$name] : $defaultValue;
  }

  public function set($name, $value) {
    $this->startSession();
    return $_SESSION[$name] = $value;
  }

  public function destroy() {
    unset($_SESSION);
    session_unset();
    session_destroy();
  }
}