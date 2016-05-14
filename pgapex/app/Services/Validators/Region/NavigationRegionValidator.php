<?php

namespace App\Services\Validators\Region;


use App\Http\Request;

class NavigationRegionValidator extends RegionValidator {
  function __construct($database) {
    parent::__construct($database);
  }

  public function validate(Request $request) {
    parent::validate($request);
  }
}