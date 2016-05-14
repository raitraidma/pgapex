<?php

namespace App\Services\Validators\Page;


use App\Http\Request;
use App\Services\Validators\Validator;

class PageValidator extends Validator {
  private $database;

  function __construct($database) {
    $this->database = $database;
  }

  public function validate(Request $request) {
    $this->validateTitle($request);
    $this->validateAlias($request);
    $this->validateTemplate($request);
  }

  private function validateTitle($request) {
    $title = trim($request->getApiAttribute('title', ''));
    if ($title === '') {
      $this->addError('page.titleIsMandatory', '/data/attributes/title');
    }
  }

  private function validateTemplate($request) {
    $template = $request->getApiAttribute('template');
    if ($template === null || !is_int($template) || $template <= 0) {
      $this->addError('page.templateIsMandatory', '/data/attributes/template');
    }
  }

  protected function validateAlias(Request $request) {
    $pageId = $request->getApiAttribute('pageId');
    $applicationId = $request->getApiAttribute('applicationId');
    $alias = trim($request->getApiAttribute('alias', ''));
    if ($alias !== '' && !$this->pageMayHaveAnAlias($pageId, $applicationId, $alias)) {
      $this->addError('page.aliasAlreadyExists', '/data/attributes/alias');
    }
  }

  private function pageMayHaveAnAlias($pageId, $applicationId, $alias) {
    $connection = $this->database->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_page_page_may_have_an_alias(:pageId, :applicationId, :alias)');
    $statement->bindValue(':pageId', $pageId);
    $statement->bindValue(':applicationId', $applicationId);
    $statement->bindValue(':alias', $alias);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }
}