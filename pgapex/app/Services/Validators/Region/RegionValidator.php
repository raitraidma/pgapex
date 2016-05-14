<?php

namespace App\Services\Validators\Region;


use App\Http\Request;
use App\Services\Validators\Validator;

abstract class RegionValidator extends Validator {
  private $database;

  function __construct($database) {
    $this->database = $database;
  }

  public function validate(Request $request) {
    $this->validateName($request);
    $this->validateSequence($request);
    $this->validateRegionTemplate($request);
  }

  private function validateName($request) {
    $name = trim($request->getApiAttribute('name', ''));
    if ($name === '') {
      $this->addError('region.nameIsMandatory', '/data/attributes/name');
    }
  }

  private function validateRegionTemplate($request) {
    $template = $request->getApiAttribute('regionTemplate');
    if ($template === null || !is_int($template) || $template <= 0) {
      $this->addError('page.regionTemplateIsMandatory', '/data/attributes/regionTemplate');
    }
  }

  private function validateSequence($request) {
    $regionId = $request->getApiAttribute('regionId');
    $pageId = $request->getApiAttribute('pageId');
    $pageTemplateDisplayPointId = $request->getApiAttribute('pageTemplateDisplayPointId');
    $sequence = $request->getApiAttribute('sequence');

    if ($sequence === null || !is_int($sequence)) {
      $this->addError('region.sequenceIsMandatory', '/data/attributes/sequence');
    } elseif ($sequence < 0) {
      $this->addError('region.minValueIsZero', '/data/attributes/sequence');
    } elseif (!$this->regionMayHaveASequence($regionId, $pageId, $pageTemplateDisplayPointId, $sequence)) {
      $this->addError('region.sequenceAlreadyExists', '/data/attributes/sequence');
    }
  }

  private function regionMayHaveASequence($regionId, $pageId, $pageTemplateDisplayPointId, $sequence) {
    $connection = $this->database->getConnection();
    $statement = $connection->prepare('SELECT pgapex.f_region_region_may_have_a_sequence(:regionId, :pageId, :pageTemplateDisplayPointId, :sequence)');
    $statement->bindValue(':regionId', $regionId);
    $statement->bindValue(':pageId', $pageId);
    $statement->bindValue(':pageTemplateDisplayPointId', $pageTemplateDisplayPointId);
    $statement->bindValue(':sequence', $sequence);
    $statement->execute();
    return $statement->fetchColumn() === true;
  }
}