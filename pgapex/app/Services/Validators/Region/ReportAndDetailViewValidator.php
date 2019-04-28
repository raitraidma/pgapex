<?php

namespace App\Services\Validators\Region;


use App\Http\Request;
use App\Services\Validators\Validator;

class ReportAndDetailViewValidator extends Validator {
  private $database;

  function __construct($database) {
    $this->database = $database;
  }

  public function validate(Request $request) {
    $this->validateView($request);
    $this->validateUniqueId($request);
    $this->validateReportName($request);
    $this->validateDetailViewName($request);
    $this->validateReportRegionTemplate($request);
    $this->validateDetailViewRegionTemplate($request);
    $this->validateReportSequence($request);
    $this->validateDetailViewSequence($request);
    $this->validateReportTemplate($request);
    $this->validateDetailViewTemplate($request);
    $this->validateItemsPerPage($request);
    $this->validatePaginationQueryParameter($request);
    $this->validateDetailViewPageId($request);
    $this->validateColumns($request->getApiAttribute('reportColumns'));
    $this->validateColumns($request->getApiAttribute('detailViewColumns'));
    $this->validateSubRegions($request);
  }

  private function validateView($request) {
    $viewSchema = trim($request->getApiAttribute('viewSchema'));
    $viewName = ($request->getApiAttribute('viewName'));
    if ($viewSchema === '' || $viewName === '') {
      $this->addError('region.viewIsMandatory', '/data/attributes/view');
    }
  }

  private function validateUniqueId($request) {
    $uniqueId = trim($request->getApiAttribute('uniqueId'));
    if ($uniqueId === '') {
      $this->addError('region.uniqueIdIsMandatory', '/data/attributes/uniqueId');
    }
  }

  private function validateReportName($request) {
    $name = trim($request->getApiAttribute('reportName', ''));
    if ($name === '') {
      $this->addError('region.nameIsMandatory', '/data/attributes/reportName');
    }
  }

  private function validateDetailViewName($request) {
    $name = trim($request->getApiAttribute('detailViewName', ''));
    if ($name === '') {
      $this->addError('region.nameIsMandatory', '/data/attributes/detailViewName');
    }
  }

  private function validateReportRegionTemplate($request) {
    $template = $request->getApiAttribute('reportRegionTemplate');
    if (!$this->isValidNumericId($template)) {
      $this->addError('page.regionTemplateIsMandatory', '/data/attributes/reportRegionTemplate');
    }
  }

  private function validateDetailViewRegionTemplate($request) {
    $template = $request->getApiAttribute('detailViewRegionTemplate');
    if (!$this->isValidNumericId($template)) {
      $this->addError('page.regionTemplateIsMandatory', '/data/attributes/detailViewRegionTemplate');
    }
  }

  private function validateReportSequence($request) {
    $regionId = $request->getApiAttribute('reportRegionId');
    $pageId = $request->getApiAttribute('reportPageId');
    $pageTemplateDisplayPointId = $request->getApiAttribute('pageTemplateDisplayPointId');
    $sequence = $request->getApiAttribute('reportSequence');

    if (!$this->isValidSequence($sequence)) {
      $this->addError('region.sequenceIsMandatory', '/data/attributes/reportSequence');
    } elseif ($sequence < 0) {
      $this->addError('region.minValueIsZero', '/data/attributes/reportSequence');
    } elseif (!$this->regionMayHaveASequence($regionId, $pageId, $pageTemplateDisplayPointId, $sequence)) {
      $this->addError('region.sequenceAlreadyExists', '/data/attributes/reportSequence');
    }
  }

  private function validateDetailViewSequence($request) {
    $regionId = $request->getApiAttribute('detailViewRegionId');
    $pageId = $request->getApiAttribute('detailViewPageId');
    $pageTemplateDisplayPointId = $request->getApiAttribute('pageTemplateDisplayPointId');
    $sequence = $request->getApiAttribute('detailViewSequence');

    if (!$this->isValidSequence($sequence)) {
      $this->addError('region.sequenceIsMandatory', '/data/attributes/detailViewSequence');
    } elseif ($sequence < 0) {
      $this->addError('region.minValueIsZero', '/data/attributes/detailViewSequence');
    } elseif (!$this->regionMayHaveASequence($regionId, $pageId, $pageTemplateDisplayPointId, $sequence)) {
      $this->addError('region.sequenceAlreadyExists', '/data/attributes/detailViewSequence');
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

  private function validateReportTemplate($request) {
    $template = $request->getApiAttribute('reportTemplate');
    if (!$this->isValidNumericId($template)) {
      $this->addError('region.reportTemplateIsMandatory', '/data/attributes/reportTemplate');
    }
  }

  private function validateDetailViewTemplate($request) {
    $template = $request->getApiAttribute('detailViewTemplate');
    if (!$this->isValidNumericId($template)) {
      $this->addError('region.detailViewTemplateIsMandatory', '/data/attributes/detailViewTemplate');
    }
  }

  private function validateItemsPerPage($request) {
    $itemsPerPage = $request->getApiAttribute('reportItemsPerPage');
    $pointer = '/data/attributes/reportItemsPerPage';
    if ($itemsPerPage === null || !is_int($itemsPerPage)) {
      $this->addError('region.itemsPerPageIsMandatory', $pointer);
    } elseif ($itemsPerPage < 1) {
      $this->addError('region.minValueIsOne', $pointer);
    }
  }

  private function validatePaginationQueryParameter($request) {
    $paginationQueryParameter = $request->getApiAttribute('reportPaginationQueryParameter');
    $pointer = '/data/attributes/reportPaginationQueryParameter';
    if (trim($paginationQueryParameter) === '') {
      $this->addError('region.paginationQueryParameterIsMandatory', $pointer);
    } elseif (!$this->isValidPageItem($paginationQueryParameter)) {
      $this->addError('region.paginationQueryParameterMayConsistOfCharsAndUnderscores', $pointer);
    }
  }

  public function validateDetailViewPageId($request) {
    $pageId = $request->getApiAttribute('detailViewPageId');
    if (!$this->isValidNumericId($pageId)) {
      $this->addError('region.pageIsMandatory', '/data/attributes/detailViewPageId');
    }
  }

  private function validateColumns($columns) {
    $sequences = [];

    for ($i = 0; $i < count($columns); $i++) {
      $column = $columns[$i]['attributes'];
      if (trim($column['heading']) === '') {
        $this->addError('region.headingIsMandatory', '/data/attributes/addColumnLink/' . $i . '/heading');
      }
      if (!$this->isValidSequence($column['sequence'])) {
        $this->addError('region.sequenceIsMandatory', '/data/attributes/addColumnLink' . $i . '/sequence');
      } else {
        if (in_array($column['sequence'], $sequences)) {
          $this->addError('region.sequenceAlreadyExists', '/data/attributes/addColumnLink/' . $i . '/sequence');
        }
        $sequences[] = $column['sequence'];
      }

      if ($column['type'] === 'COLUMN'){
        if (trim($column['column']) === '') {
          $this->addError('region.columnIsMandatory', '/data/attributes/addColumnLink/' . $i . '/column');
        }
      } else {
        if (trim($column['linkUrl']) === '') {
          $this->addError('region.linkUrlIsMandatory', '/data/attributes/addColumnLink/' . $i . '/linkUrl');
        }
        if (trim($column['linkText']) === '') {
          $this->addError('region.linkTextIsMandatory', '/data/attributes/addColumnLink/' . $i . '/linkText');
        }
      }
    }
  }

  private function validateSubRegions($request) {
    $subRegions = $request->getApiAttribute('subRegions');
    $sequences = [];
    $paginationQueryParameters = [];

    for ($i = 0; $i < count($subRegions); $i++) {
      $subRegion = $subRegions[$i]['attributes'];

      if ($subRegion['name'] === '') {
        $this->addError('region.nameIsMandatory', '/data/attributes/name');
      }

      if (!$this->isValidSequence($subRegion['sequence'])) {
        $this->addError('region.sequenceIsMandatory', '/data/attributes/sequence');
      } else {
        if (in_array($subRegion['sequence'], $sequences)) {
          $this->addError('region.sequenceAlreadyExists', '/data/attributes/sequence');
        }
        $sequences[] = $subRegion['sequence'];
      }

      $paginationQueryParameter = $subRegion['paginationQueryParameter'];
      $pointer = '/data/attributes/paginationQueryParameter';
      if (trim($paginationQueryParameter) === '') {
        $this->addError('region.paginationQueryParameterIsMandatory', $pointer);
      } elseif (!$this->isValidPageItem($paginationQueryParameter)) {
        $this->addError('region.paginationQueryParameterMayConsistOfCharsAndUnderscores', $pointer);
      }

      if (in_array($paginationQueryParameter, $paginationQueryParameters)) {
        $this->addError('region.paginationQueryParameterAlreadyExists', '/data/attributes/paginationQueryParameter');
      }
      $paginationQueryParameters[] = $paginationQueryParameter;

      if ($paginationQueryParameter === $request->getApiAttribute('reportPaginationQueryParameter')) {
        $this->addError('region.subreportQueryParameterNotSameAsReportParameter', '/data/attributes/paginationQueryParameter');
      }

      $itemsPerPage = $subRegion['itemsPerPage'];
      $pointer = '/data/attributes/itemsPerPage';
      if ($itemsPerPage === null || !is_int($itemsPerPage)) {
        $this->addError('region.itemsPerPageIsMandatory', $pointer);
      } elseif ($itemsPerPage < 1) {
        $this->addError('region.minValueIsOne', $pointer);
      }

      $viewSchema = trim($subRegion['viewSchema']);
      $viewName = ($subRegion['viewName']);
      if ($viewSchema === '' || $viewName === '') {
        $this->addError('region.viewIsMandatory', '/data/attributes/view');
      }

      if ($subRegion['linkedColumn'] === '') {
        $this->addError('region.linkedColumnIsMandatory', '/data/attributes/linkedColumn');
      }

      $this->validateColumns($subRegion['columns']);
    }
  }

}