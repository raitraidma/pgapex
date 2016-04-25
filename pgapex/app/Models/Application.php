<?php

namespace App\Models;

use App\Http\Request;

class Application extends Model {
  public function getApplications() {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_get_applications()');
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function saveApplication(Request $request) {
    $id = $request->getApiAttribute('id');
    $name = $request->getApiAttribute('name');
    $alias = $request->getApiAttribute('alias');
    $database = $request->getApiAttribute('database');
    $databaseUsername = $request->getApiAttribute('databaseUsername');
    $databasePassword = $request->getApiAttribute('databasePassword');

    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_save_application(:id, :name, :alias, :database, :databaseUsername, :databasePassword)');
    $statement->bindParam(':id', $id);
    $statement->bindParam(':name', $name);
    $statement->bindParam(':alias', $alias);
    $statement->bindParam(':database', $database);
    $statement->bindParam(':databaseUsername', $databaseUsername);
    $statement->bindParam(':databasePassword', $databasePassword);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  public function getApplication($id) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_get_application(:id)');
    $statement->bindParam(':id', $id);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function deleteApplication($id) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_delete_application(:id)');
    $statement->bindParam(':id', $id);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function getApplicationAuthentication($id) {
    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_get_application_authentication(:id)');
    $statement->bindParam(':id', $id);
    $statement->execute();
    return $statement->fetchColumn();
  }

  public function saveApplicationAuthentication(Request $request) {
    $id = $request->getApiAttribute('id');
    $authenticationScheme = $request->getApiAttribute('authenticationScheme');
    $authenticationFunctionSchema = $request->getApiAttribute('authenticationFunction')['schema'];
    $authenticationFunction = $request->getApiAttribute('authenticationFunction')['function'];
    $loginPageTemplate = $request->getApiAttribute('loginPageTemplate');

    $connection = $this->getDb()->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_save_application_authentication(:id, :authScheme, :authFunSchema, :authFun, :loginPageTemplate)');
    $statement->bindParam(':id', $id);
    $statement->bindParam(':authScheme', $authenticationScheme);
    $statement->bindParam(':authFunSchema', $authenticationFunctionSchema);
    $statement->bindParam(':authFun', $authenticationFunction);
    $statement->bindParam(':loginPageTemplate', $loginPageTemplate);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }
}