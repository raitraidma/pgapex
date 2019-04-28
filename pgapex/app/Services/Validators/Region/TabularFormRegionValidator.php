<?php

namespace App\Services\Validators\Region;


use App\Http\Request;

class TabularFormRegionValidator extends RegionValidator {
  function __construct($database) {
    parent::__construct($database);
  }

  public function validate(Request $request) {
    parent::validate($request);
    $this->validateTabularFormTemplate($request);
    $this->validateView($request);
    $this->validateItemsPerPage($request);
    $this->validatePaginationQueryParameter($request);
    $this->validateButtons($request);
    $this->validateColumns($request);
  }

  private function validateTabularFormTemplate($request) {
    $template = $request->getApiAttribute('tabularFormTemplate');
    if (!$this->isValidNumericId($template)) {
      $this->addError('region.tabularFormTemplateIsMandatory', '/data/attributes/tabularFormTemplate');
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

  private function validateButtons($request) {
    $buttons = $request->getApiAttribute('tabularFormButtons');
    $sequences = [];

    for ($i = 0; $i < count($buttons); $i++) {
      $button = $buttons[$i];
      if (!$this->isValidNumericId($button['templateId'])) {
        $this->addError('region.buttonTemplateIsMandatory', '/data/attributes/addButton' . $i . '/buttonTemplate');
      }

      if (!$this->isValidSequence($button['sequence'])) {
        $this->addError('region.sequenceIsMandatory', '/data/attributes/addButton' . $i . '/sequence');
      } else {
        if (in_array($button['sequence'], $sequences)) {
          $this->addError('region.sequenceAlreadyExists', '/data/attributes/addButton/' . $i . '/sequence');
        }
        $sequences[] = $button['sequence'];
      }

      if ($button['label'] === null || trim($button['label']) === '') {
        $this->addError('region.buttonLabelIsMandatory', '/data/attributes/buttonLabel');
      }

      if ($button['functionName'] === null || trim($button['functionName']) === '') {
        $this->addError('region.functionIsMandatory', '/data/attributes/addButton' . $i . '/function');
      }

      if ($button['successMessage'] === null || trim($button['successMessage']) === '') {
        $this->addError('region.successMessageIsMandatory', '/data/attributes/addButton' . $i . '/successMessage');
      }

      if ($button['errorMessage'] === null || trim($button['errorMessage']) === '') {
        $this->addError('region.errorMessageIsMandatory', '/data/attributes/addButton' . $i . '/errorMessage');
      }
    }
  }

  private function validateColumns($request) {
    $columns = $request->getApiAttribute('tabularFormColumns');
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
}