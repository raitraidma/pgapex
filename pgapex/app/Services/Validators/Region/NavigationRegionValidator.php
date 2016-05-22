<?php

namespace App\Services\Validators\Region;


use App\Http\Request;

class NavigationRegionValidator extends RegionValidator {
  function __construct($database) {
    parent::__construct($database);
  }

  public function validate(Request $request) {
    parent::validate($request);
    $this->validateNavigationTemplate($request);
    $this->validateNavigationType($request);
    $this->validateNavigation($request);
  }

  private function validateNavigationTemplate($request) {
    $template = $request->getApiAttribute('navigationTemplate');
    if (!$this->isValidNumericId($template)) {
      $this->addError('region.navigationTemplateIsMandatory', '/data/attributes/navigationTemplate');
    }
  }

  private function validateNavigationType($request) {
    $navigationType = $request->getApiAttribute('navigationType');
    $pointer = '/data/attributes/navigationType';
    if (trim($navigationType) === '') {
      $this->addError('region.navigationTypeIsMandatory', $pointer);
    } elseif (!in_array($navigationType, ['MENU', 'BREADCRUMB', 'SITEMAP'])) {
      $this->addError('region.navigationTypeMustBeMenuBreadcrumbSitemap', $pointer);
    }
  }

  private function validateNavigation($request) {
    $navigationType = $request->getApiAttribute('navigation');
    if (!$this->isValidNumericId($navigationType)) {
      $this->addError('region.navigationIsMandatory', '/data/attributes/navigation');
    }
  }
}