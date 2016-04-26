<?php

namespace App\Models;

use App\Http\Request;
use PDO;

class Navigation extends Model {
  public function getNavigations($applicationId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_navigation_get_navigations(:applicationId)');
    $statement->bindValue(':applicationId', $applicationId, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function saveNavigation(Request $request) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_navigation_save_navigation(:navigationId, :applicationId, :name)');
    $statement->bindValue(':navigationId',  $request->getApiAttribute('navigationId'),  PDO::PARAM_INT);
    $statement->bindValue(':applicationId', $request->getApiAttribute('applicationId'), PDO::PARAM_INT);
    $statement->bindValue(':name',          $request->getApiAttribute('name'),         PDO::PARAM_STR);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  public function getNavigation($navigationId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_navigation_get_navigation(:navigationId)');
    $statement->bindValue(':navigationId', $navigationId, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function deleteNavigation($navigationId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_navigation_delete_navigation(:navigationId)');
    $statement->bindValue(':navigationId', $navigationId, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }
}