<?php

namespace App\Services\Validators\Navigation;


use App\Http\Request;
use App\Services\Validators\Validator;

class NavigationValidator extends Validator {
  private $database;

  function __construct($database) {
    $this->database = $database;
  }

  public function validate(Request $request) {
    $this->validateName($request);
  }

  protected function validateName(Request $request) {
    $navigationId = $request->getApiAttribute('navigationId');
    $applicationId = $request->getApiAttribute('applicationId');
    $name = trim($request->getApiAttribute('name', ''));
    if ($name === '') {
      $this->addError('navigation.nameIsMandatory', '/data/attributes/name');
    } else if (!$this->navigationMayHaveAName($navigationId, $applicationId, $name)) {
      $this->addError('navigation.nameAlreadyExists', '/data/attributes/name');
    }
  }

  private function navigationMayHaveAName($navigationId, $applicationId, $name) {
    $connection = $this->database->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_navigation_navigation_may_have_a_name(:navigationId, :applicationId, :name)');
    $statement->bindValue(':navigationId', $navigationId);
    $statement->bindValue(':applicationId', $applicationId);
    $statement->bindValue(':name', $name);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }
}