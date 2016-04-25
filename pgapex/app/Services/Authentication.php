<?php

namespace App\Services;

use App\Models\Auth;

class Authentication implements Service {
  private $session;
  private $database;
  const IS_LOGGED_IN = 'isLoggedIn';

  public function __construct($session, $database) {
    $this->session = $session;
    $this->database = $database;
  }

  public function isLoggedIn() {
    return $this->session->get(self::IS_LOGGED_IN, false);
  }

  public function login($username, $password) {
    $auth = new Auth($this->database);
    if($auth->isSuperuser($username, $password)) {
      $this->session->set(self::IS_LOGGED_IN, true);
      return true;
    }
    return false;
  }

  public function logout() {
    $this->session->set(self::IS_LOGGED_IN, false);
  }
}