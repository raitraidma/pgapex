<?php

namespace App\Models;

abstract class Model {
  private $database;

  public function __construct($database) {
    $this->database = $database;
  }

  protected function getDb() {
    return $this->database;
  }
}