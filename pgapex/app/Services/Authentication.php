<?php

namespace App\Services;

class Authentication implements Service {
  private $session;
  const IS_LOGGED_IN = 'isLoggedIn';

  public function __construct($session) {
    $this->session = $session;
  }

  public function isLoggedIn() {
    $this->session->get(self::IS_LOGGED_IN, false);
  }

  public function login() {
    $this->session->set(self::IS_LOGGED_IN, true);
  }

  public function logout() {
    $this->session->set(self::IS_LOGGED_IN, false);
  }
}