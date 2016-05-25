<?php

namespace App\Services\Validators\Region;


use App\Http\Request;

class ReportRegionValidator extends RegionValidator {
  function __construct($database) {
    parent::__construct($database);
  }

  public function validate(Request $request) {
    parent::validate($request);
    $this->validateReportTemplate($request);
    $this->validateView($request);
    $this->validateItemsPerPage($request);
    $this->validatePaginationQueryParameter($request);
    $this->validateColumns($request);
  }

  private function validateReportTemplate($request) {
    $template = $request->getApiAttribute('reportTemplate');
    if (!$this->isValidNumericId($template)) {
      $this->addError('region.reportTemplateIsMandatory', '/data/attributes/reportTemplate');
    }
  }

  private function validateView($request) {
    $viewSchema = trim($request->getApiAttribute('viewSchema'));
    $viewName = ($request->getApiAttribute('viewName'));
    if ($viewSchema === '' || $viewName === '') {
      $this->addError('region.viewIsMandatory', '/data/attributes/view');
    }
  }

  private function validateItemsPerPage($request) {
    $itemsPerPage = $request->getApiAttribute('itemsPerPage');
    $pointer = '/data/attributes/itemsPerPage';
    if ($itemsPerPage === null || !is_int($itemsPerPage)) {
      $this->addError('region.itemsPerPageIsMandatory', $pointer);
    } elseif ($itemsPerPage < 1) {
      $this->addError('region.minValueIsOne', $pointer);
    }
  }

  private function validatePaginationQueryParameter($request) {
    $paginationQueryParameter = $request->getApiAttribute('paginationQueryParameter');
    $pointer = '/data/attributes/paginationQueryParameter';
    if (trim($paginationQueryParameter) === '') {
      $this->addError('region.paginationQueryParameterIsMandatory', $pointer);
    } elseif (!$this->isValidPageItem($paginationQueryParameter)) {
      $this->addError('region.paginationQueryParameterMayConsistOfCharsAndUnderscores', $pointer);
    }
  }

  private function validateColumns($request) {
    $columns = $request->getApiAttribute('reportColumns');
    $sequences = [];

    for ($i = 0; $i < count($columns); $i++) {
      $column = $columns[$i]['attributes'];
      if (trim($column['heading']) === '') {
        $this->addError('region.headingIsMandatory', '/data/attributes/reportColumns/' . $i . '/heading');
      }
      if (!$this->isValidSequence($column['sequence'])) {
        $this->addError('region.sequenceIsMandatory', '/data/attributes/reportColumns/' . $i . '/sequence');
      } else {
        if (in_array($column['sequence'], $sequences)) {
          $this->addError('region.sequenceAlreadyExists', '/data/attributes/reportColumns/' . $i . '/sequence');
        }
        $sequences[] = $column['sequence'];
      }

      if ($column['type'] === 'COLUMN'){
        if (trim($column['column']) === '') {
          $this->addError('region.columnIsMandatory', '/data/attributes/reportColumns/' . $i . '/column');
        }
      } else {
        if (trim($column['linkUrl']) === '') {
          $this->addError('region.linkUrlIsMandatory', '/data/attributes/reportColumns/' . $i . '/linkUrl');
        }
        if (trim($column['linkText']) === '') {
          $this->addError('region.linkTextIsMandatory', '/data/attributes/reportColumns/' . $i . '/linkText');
        }
      }
    }
  }
}