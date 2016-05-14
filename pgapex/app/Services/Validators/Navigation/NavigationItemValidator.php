<?php

namespace App\Services\Validators\Navigation;


use App\Http\Request;
use App\Services\Validators\Validator;

class NavigationItemValidator extends Validator {
  private $database;

  function __construct($database) {
    $this->database = $database;
  }

  public function validate(Request $request) {
    $this->validateSequence($request);
    $this->validateParentNavigationItem($request);
    $this->validatePage($request);
  }

  protected function validateSequence(Request $request) {
    $navigationItemId = $request->getApiAttribute('navigationItemId');
    $navigationId = $request->getApiAttribute('navigationId');
    $parentNavigationItemId = $request->getApiAttribute('parentNavigationItem');
    $sequence = $request->getApiAttribute('sequence');
    if ($sequence === null || !is_int($sequence)) {
      $this->addError('navigation.sequenceIsMandatory', '/data/attributes/sequence');
    } elseif ($sequence < 0) {
      $this->addError('navigation.minValueIsZero', '/data/attributes/sequence');
    } elseif (!$this->navigationItemMayHaveASequence($navigationItemId, $navigationId, $parentNavigationItemId, $sequence)) {
      $this->addError('navigation.sequenceAlreadyExists', '/data/attributes/sequence');
    }
  }

  protected function validateParentNavigationItem(Request $request) {
    $navigationItemId = $request->getApiAttribute('navigationItemId');
    $parentNavigationItemId = $request->getApiAttribute('parentNavigationItem');
    if ($this->navigationItemCreatesCycle($navigationItemId, $parentNavigationItemId)) {
      $this->addError('navigation.selectingThisParentNavigationItemCreatesCycle', '/data/attributes/parentNavigationItem');
    }
  }

  protected function validatePage($request) {
    $navigationItemId = $request->getApiAttribute('navigationItemId');
    $navigationId = $request->getApiAttribute('navigationId');
    $pageId = $request->getApiAttribute('page');
    if (!$this->navigationItemMayReferToPage($navigationItemId, $navigationId, $pageId)) {
      $this->addError('navigation.pageIsAlreadyInUseInThisNavigation', '/data/attributes/page');
    }
  }

  private function navigationItemCreatesCycle($navigationItemId, $parentNavigationItemId) {
    $connection = $this->database->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_navigation_navigation_item_contains_cycle(:navigationItemId, :parentNavigationItemId)');
    $statement->bindValue(':navigationItemId', $navigationItemId);
    $statement->bindValue(':parentNavigationItemId', $parentNavigationItemId);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  private function navigationItemMayHaveASequence($navigationItemId, $navigationId, $parentNavigationItemId, $sequence) {
    $connection = $this->database->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_navigation_navigation_item_may_have_a_sequence '
                                    . ' (:navigationItemId, :navigationId, :parentNavigationItemId, :sequence)');
    $statement->bindValue(':navigationItemId', $navigationItemId);
    $statement->bindValue(':navigationId', $navigationId);
    $statement->bindValue(':parentNavigationItemId', $parentNavigationItemId);
    $statement->bindValue(':sequence', $sequence);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }

  private function navigationItemMayReferToPage($navigationItemId, $navigationId, $pageId) {
    $connection = $this->database->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_navigation_navigation_item_may_refer_to_page '
                                    . ' (:navigationItemId, :navigationId, :pageId)');
    $statement->bindValue(':navigationItemId', $navigationItemId);
    $statement->bindValue(':navigationId', $navigationId);
    $statement->bindValue(':pageId', $pageId);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }
}