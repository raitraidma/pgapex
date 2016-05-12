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
    $this->validateName($request);
    $this->validateAlias($request);
    $this->validateDatabase($request);
    $this->validateDatabaseUsername($request);
    $this->validateDatabasePassword($request);
    $this->validateDatabaseUserCredentials($request);
  }

  protected function validateName(Request $request) {
    $id = $request->getApiAttribute('id');
    $name = trim($request->getApiAttribute('name', ''));
    if ($name === '') {
      $this->addError('application.applicationNameIsMandatory', '/data/attributes/name');
    } else if (!$this->applicationMayHaveAName($id, $name)) {
      $this->addError('application.applicationNameAlreadyExists', '/data/attributes/name');
    }
  }

  protected function validateAlias(Request $request) {
    $id = $request->getApiAttribute('id');
    $alias = trim($request->getApiAttribute('alias', ''));
    if ($alias !== '') {
      if (!$this->aliasContainsCharactersAndMayContainNumbersAndUnderscores($alias)) {
        $this->addError('application.applicationAliasMustContainCharacters', '/data/attributes/alias');
      } elseif(!$this->applicationMayHaveAnAlias($id, $alias)) {
        $this->addError('application.aliasAlreadyExists', '/data/attributes/alias');
      }
    }
  }

  protected function validateDatabase(Request $request) {
    if (trim($request->getApiAttribute('database', '')) === '') {
      $this->addError('application.databaseIsMandatory', '/data/attributes/database');
    }
  }

  protected function validateDatabaseUsername(Request $request) {
    if (trim($request->getApiAttribute('databaseUsername', '')) === '') {
      $this->addError('application.databaseUsernameIsMandatory', '/data/attributes/databaseUsername');
    }
  }

  protected function validateDatabasePassword(Request $request) {
    if (trim($request->getApiAttribute('databasePassword', '')) === '') {
      $this->addError('application.databasePasswordIsMandatory', '/data/attributes/databasePassword');
    }
  }

  protected function validateDatabaseUserCredentials(Request $request) {
    $databaseUsername = trim($request->getApiAttribute('databaseUsername', ''));
    $databasePassword = trim($request->getApiAttribute('databasePassword', ''));
    if ($databaseUsername !== '' && $databasePassword != '' && !$this->userExists($databaseUsername, $databasePassword)) {
      $this->addError('application.usernameAndPasswordDoNotMatch', '/data/attributes/databaseUsername');
    }
  }

  protected function userExists($databaseUsername, $databasePassword) {
    $connection = $this->database->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_user_exists(:username, :password)');
    $statement->bindValue(':username', $databaseUsername);
    $statement->bindValue(':password', $databasePassword);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  protected function applicationMayHaveAnAlias($id, $alias) {
    $connection = $this->database->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_application_may_have_an_alias(:id, :alias)');
    $statement->bindValue(':id', $id);
    $statement->bindValue(':alias', $alias);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  protected function applicationMayHaveAName($id, $name) {
    $connection = $this->database->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_application_application_may_have_a_name(:id, :name)');
    $statement->bindValue(':id', $id);
    $statement->bindValue(':name', $name);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  protected function aliasContainsCharactersAndMayContainNumbersAndUnderscores($alias) {
    $alias = trim($alias);
    return $alias !== '' && preg_match('/.*[a-z].*/', $alias) == 1 && preg_match('/^\w*$/', $alias) == 1;
  }
}