<?php

namespace App\Models;

class Database extends Model {
  public function getDatabases() {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_database_object_get_databases()');
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function getAuthenticationFunctions($applicationId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_database_object_get_authentication_functions(:applicationId)');
    $statement->bindParam(':applicationId', $applicationId);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function refreshDatabaseObjects() {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_refresh_database_objects()');
    $statement->execute();
    return $statement->fetchColumn();
  }
}