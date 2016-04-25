<?php

namespace App\Models;

use App\Http\Request;
use PDO;

class Application extends Model {
  public function getApplications() {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_get_applications()');
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function saveApplication(Request $request) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_save_application(:id, :name, :alias, :database, :databaseUsername, :databasePassword)');
    $statement->bindValue(':id',               $request->getApiAttribute('id'),               PDO::PARAM_INT);
    $statement->bindValue(':name',             $request->getApiAttribute('name'),             PDO::PARAM_STR);
    $statement->bindValue(':alias',            $request->getApiAttribute('alias'),            PDO::PARAM_STR);
    $statement->bindValue(':database',         $request->getApiAttribute('database'),         PDO::PARAM_STR);
    $statement->bindValue(':databaseUsername', $request->getApiAttribute('databaseUsername'), PDO::PARAM_STR);
    $statement->bindValue(':databasePassword', $request->getApiAttribute('databasePassword'), PDO::PARAM_STR);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  public function getApplication($id) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_get_application(:id)');
    $statement->bindValue(':id', $id);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function deleteApplication($id) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_delete_application(:id)');
    $statement->bindValue(':id', $id);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  public function getApplicationAuthentication($id) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_get_application_authentication(:id)');
    $statement->bindValue(':id', $id);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function saveApplicationAuthentication(Request $request) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_save_application_authentication(:id, :authScheme, :authFunSchema, :authFun, :loginPageTemplate)');
    $statement->bindValue(':id',                $request->getApiAttribute('id'),                                 PDO::PARAM_INT);
    $statement->bindValue(':authScheme',        $request->getApiAttribute('authenticationScheme'),               PDO::PARAM_STR);
    $statement->bindValue(':authFunSchema',     $request->getApiAttribute('authenticationFunction')['schema'],   PDO::PARAM_STR);
    $statement->bindValue(':authFun',           $request->getApiAttribute('authenticationFunction')['function'], PDO::PARAM_STR);
    $statement->bindValue(':loginPageTemplate', $request->getApiAttribute('loginPageTemplate'),                  PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }
}