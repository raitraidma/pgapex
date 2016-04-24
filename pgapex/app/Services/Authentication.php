<?php

namespace App\Services;

class Authentication implements Service {
  private $session;
  private $database;
  const IS_LOGGED_IN = 'isLoggedIn';

  public function __construct($session, $database) {
    $this->session = $session;
    $this->database = $database;
  }

  public function isLoggedIn() {
    $this->session->get(self::IS_LOGGED_IN, false);
  }

  public function login($username, $password) {
    $connection = $this->database->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_is_superuser(:username, :password)');
    $statement->bindParam(':username', $username);
    $statement->bindParam(':password', $password);
    $statement->execute();
    if($statement->fetchColumn() === true) {
      $this->session->set(self::IS_LOGGED_IN, true);
      return true;
    }
    return false;
  }

  public function logout() {
    $this->session->set(self::IS_LOGGED_IN, false);
  }
}