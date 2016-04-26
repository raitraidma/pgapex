<?php

namespace App\Models;

class Auth extends Model {
  public function isSuperuser($username, $password) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_is_superuser(:username, :password)');
    $statement->bindValue(':username', $username);
    $statement->bindValue(':password', $password);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }
}