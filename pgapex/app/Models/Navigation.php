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

  public function getNavigationItems($navigationId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_navigation_get_navigation_items(:navigationId)');
    $statement->bindValue(':navigationId', $navigationId, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function deleteNavigationItem($navigationItemId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_navigation_delete_navigation_item(:navigationItemId)');
    $statement->bindValue(':navigationItemId', $navigationItemId, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  public function getNavigationItem($navigationItemId) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_navigation_get_navigation_item(:navigationItemId)');
    $statement->bindValue(':navigationItemId', $navigationItemId, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function saveNavigationItem(Request $request) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_navigation_save_navigation_item(:navigationItemId, :parentNavigationItem, :navigationId, :name, :sequence, :page, :url)');
    $statement->bindValue(':navigationItemId',     $request->getApiAttribute('navigationItemId'),     PDO::PARAM_INT);
    $statement->bindValue(':parentNavigationItem', $request->getApiAttribute('parentNavigationItem'), PDO::PARAM_INT);
    $statement->bindValue(':navigationId',         $request->getApiAttribute('navigationId'),         PDO::PARAM_INT);
    $statement->bindValue(':name',                 $request->getApiAttribute('name'),                 PDO::PARAM_STR);
    $statement->bindValue(':sequence',             $request->getApiAttribute('sequence'),             PDO::PARAM_INT);
    $statement->bindValue(':page',                 $request->getApiAttribute('page'),                 PDO::PARAM_INT);
    $statement->bindValue(':url',                  $request->getApiAttribute('url'),                  PDO::PARAM_STR);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }
}