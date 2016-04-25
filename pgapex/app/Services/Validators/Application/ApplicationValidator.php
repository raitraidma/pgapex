<?php

namespace App\Services\Validators\Application;


use App\Http\Request;
use App\Services\Validators\Validator;

class ApplicationValidator extends Validator {
  private $database;

  function __construct($database) {
    $this->database = $database;
  }

  public function validate(Request $request) {
    $id = $request->getApiAttribute('id', null);
    $name = trim($request->getApiAttribute('name', ''));
    $alias = trim($request->getApiAttribute('alias', ''));
    $database = trim($request->getApiAttribute('database', ''));
    $databaseUsername = trim($request->getApiAttribute('databaseUsername', ''));
    $databasePassword = trim($request->getApiAttribute('databasePassword', ''));

    if ($name === '') {
      $this->addError('application.applicationNameIsMandatory', '/data/attributes/name');
    }
    if ($alias !== '') {
      if (preg_match('/.*[a-z].*/', $alias) !== 1 || preg_match('/^\w*$/', $alias) !== 1) {
        $this->addError('application.applicationAliasMustContainCharacters', '/data/attributes/alias');
      } elseif(!$this->applicationMayHaveAnAlias($id, $alias)) {
        $this->addError('application.aliasAlreadyExists', '/data/attributes/alias');
      }
    }
    if ($database === '') {
      $this->addError('application.databaseIsMandatory', '/data/attributes/database');
    }
    if ($databaseUsername === '') {
      $this->addError('application.databaseUsernameIsMandatory', '/data/attributes/databaseUsername');
    }
    if ($databasePassword === '') {
      $this->addError('application.databasePasswordIsMandatory', '/data/attributes/databasePassword');
    }
    if ($databaseUsername !== '' && $databasePassword != '' && !$this->userExists($databaseUsername, $databasePassword)) {
      $this->addError('application.usernameAndPasswordDoNotMatch', '/data/attributes/databaseUsername');
    }
  }

  private function userExists($databaseUsername, $databasePassword) {
    $connection = $this->database->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_user_exists(:username, :password)');
    $statement->bindParam(':username', $databaseUsername);
    $statement->bindParam(':password', $databasePassword);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  private function applicationMayHaveAnAlias($id, $alias) {
    $connection = $this->database->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_application_may_have_an_alias(:id, :alias)');
    $statement->bindParam(':id', $id);
    $statement->bindParam(':alias', $alias);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }
}